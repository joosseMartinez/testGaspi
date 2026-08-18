//
//  APIClientTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
import Testing
@testable import testGaspi

/// Serialized: cases share the process-wide `URLProtocolStub.requestHandler`.
@Suite(.serialized)
struct APIClientTests {
    private struct DummyDTO: Codable, Equatable {
        let value: String
    }

    private func makeSUT(baseURL: URL? = URL(string: "https://example.com"), headers: [String: String] = [:]) -> APIClient {
        APIClient(baseURL: baseURL, session: URLProtocolStub.makeStubbedSession(), defaultHeaders: headers)
    }

    private func stubResponse(statusCode: Int = 200, data: Data) {
        URLProtocolStub.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
    }

    @Test func decodesThePayloadOnASuccessfulResponse() async throws {
        stubResponse(data: try JSONEncoder().encode(DummyDTO(value: "ok")))
        let sut = makeSUT()

        let result: DummyDTO = try await sut.request(APIEndpoint(path: "/foo"))

        #expect(result == DummyDTO(value: "ok"))
    }

    @Test func buildsTheURLFromBaseURLPathAndQueryItems() async throws {
        var capturedURL: URL?
        URLProtocolStub.requestHandler = { request in
            capturedURL = request.url
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, try JSONEncoder().encode(DummyDTO(value: "ok")))
        }
        let sut = makeSUT()

        let _: DummyDTO = try await sut.request(
            APIEndpoint(path: "/wlm/walmart-search-by-keyword", queryItems: [URLQueryItem(name: "keyword", value: "nintendo")])
        )

        #expect(capturedURL?.absoluteString == "https://example.com/wlm/walmart-search-by-keyword?keyword=nintendo")
    }

    @Test func mergesDefaultHeadersWithPerRequestHeaders() async throws {
        var capturedRequest: URLRequest?
        URLProtocolStub.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, try JSONEncoder().encode(DummyDTO(value: "ok")))
        }
        let sut = makeSUT(headers: ["x-rapidapi-key": "abc123"])

        let _: DummyDTO = try await sut.request(APIEndpoint(path: "/foo", headers: ["x-custom": "1"]))

        #expect(capturedRequest?.value(forHTTPHeaderField: "x-rapidapi-key") == "abc123")
        #expect(capturedRequest?.value(forHTTPHeaderField: "x-custom") == "1")
    }

    @Test func throwsInvalidURLWhenNoBaseURLIsConfigured() async throws {
        let sut = makeSUT(baseURL: nil)

        await #expect(throws: APIError.self) {
            let _: DummyDTO = try await sut.request(APIEndpoint(path: "/foo"))
        }
    }

    @Test func throwsHTTPErrorForANonSuccessStatusCode() async throws {
        stubResponse(statusCode: 404, data: Data())
        let sut = makeSUT()

        do {
            let _: DummyDTO = try await sut.request(APIEndpoint(path: "/foo"))
            Issue.record("Expected APIError.httpError to be thrown")
        } catch let error as APIError {
            guard case .httpError(let statusCode) = error else {
                Issue.record("Expected .httpError, got \(error)")
                return
            }
            #expect(statusCode == 404)
        }
    }

    @Test func throwsDecodingFailedForMalformedJSON() async throws {
        stubResponse(data: Data("not json".utf8))
        let sut = makeSUT()

        do {
            let _: DummyDTO = try await sut.request(APIEndpoint(path: "/foo"))
            Issue.record("Expected APIError.decodingFailed to be thrown")
        } catch let error as APIError {
            guard case .decodingFailed = error else {
                Issue.record("Expected .decodingFailed, got \(error)")
                return
            }
        }
    }
}
