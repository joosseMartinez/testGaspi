//
//  ProductRepositoryTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
import Testing
@testable import testGaspi

struct ProductRepositoryTests {
    @Test func buildsTheWalmartSearchEndpointAndMapsTheResults() async throws {
        let apiClient = MockAPIClient()
        apiClient.stub = .success(try WalmartSearchFixture.decode())
        let sut = ProductRepository(apiClient: apiClient)

        let products = try await sut.searchProducts(query: "nintendo", page: 2)

        let endpoint = try #require(apiClient.receivedEndpoints.first)
        #expect(endpoint.path == "/wlm/walmart-search-by-keyword")
        #expect(endpoint.queryItems.contains(URLQueryItem(name: "keyword", value: "nintendo")))
        #expect(endpoint.queryItems.contains(URLQueryItem(name: "page", value: "2")))
        #expect(endpoint.queryItems.contains(URLQueryItem(name: "sortBy", value: "best_match")))

        #expect(products.count == 2)
        #expect(products.first?.title == "Nintendo Switch OLED")
    }

    @Test func propagatesErrorsThrownByTheAPIClient() async throws {
        struct StubError: Error {}
        let apiClient = MockAPIClient()
        apiClient.stub = .failure(StubError())
        let sut = ProductRepository(apiClient: apiClient)

        await #expect(throws: StubError.self) {
            _ = try await sut.searchProducts(query: "nintendo", page: 1)
        }
    }
}
