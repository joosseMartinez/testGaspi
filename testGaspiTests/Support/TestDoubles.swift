//
//  TestDoubles.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
@testable import testGaspi

// MARK: - Domain use case mocks

final class MockProductRepository: ProductRepositoryProtocol {
    var result: Result<[Product], Error> = .success([])
    private(set) var receivedQueries: [(query: String, page: Int)] = []

    func searchProducts(query: String, page: Int) async throws -> [Product] {
        receivedQueries.append((query, page))
        return try result.get()
    }
}

final class MockSearchHistoryRepository: SearchHistoryRepositoryProtocol {
    var historyToReturn: [SearchTerm] = []
    private(set) var savedQueries: [String] = []
    private(set) var clearHistoryCallCount = 0

    func fetchHistory() -> [SearchTerm] { historyToReturn }

    func save(query: String) {
        savedQueries.append(query)
    }

    func clearHistory() {
        clearHistoryCallCount += 1
    }
}

final class MockSearchProductsUseCase: SearchProductsUseCaseProtocol {
    var result: Result<[Product], Error> = .success([])
    /// Simulates network latency. Uses `Task.sleep`, which — like `URLSession`'s async API —
    /// throws `CancellationError` as soon as the enclosing `Task` is cancelled.
    var delay: Duration = .zero
    private(set) var receivedQueries: [(query: String, page: Int)] = []

    func execute(query: String, page: Int) async throws -> [Product] {
        receivedQueries.append((query, page))
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        return try result.get()
    }
}

final class MockSearchHistoryUseCase: SearchHistoryUseCaseProtocol {
    var historyToReturn: [SearchTerm] = []
    private(set) var savedQueries: [String] = []
    private(set) var clearCallCount = 0

    func fetchHistory() -> [SearchTerm] { historyToReturn }

    func save(query: String) {
        savedQueries.append(query)
    }

    func clearHistory() {
        clearCallCount += 1
    }
}

// MARK: - Data layer mocks

final class MockSearchHistoryLocalDataSource: SearchHistoryLocalDataSourceProtocol {
    var historyToReturn: [SearchTerm] = []
    private(set) var savedTerms: [SearchTerm] = []
    private(set) var clearCallCount = 0

    func fetchHistory() -> [SearchTerm] { historyToReturn }

    func save(_ term: SearchTerm) {
        savedTerms.append(term)
    }

    func clear() {
        clearCallCount += 1
    }
}

final class MockAPIClient: APIClientProtocol {
    enum Stub {
        case success(Decodable)
        case failure(Error)
    }

    var stub: Stub = .success(EmptyDTO())
    private(set) var receivedEndpoints: [APIEndpoint] = []

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        receivedEndpoints.append(endpoint)
        switch stub {
        case .success(let value):
            guard let typed = value as? T else {
                throw APIError.decodingFailed(NSError(domain: "MockAPIClient", code: 0))
            }
            return typed
        case .failure(let error):
            throw error
        }
    }
}

struct EmptyDTO: Decodable {}

// MARK: - URLSession stubbing for APIClient tests

final class URLProtocolStub: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    static func makeStubbedSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = URLProtocolStub.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
