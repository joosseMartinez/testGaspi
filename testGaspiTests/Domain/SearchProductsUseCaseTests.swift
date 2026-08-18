//
//  SearchProductsUseCaseTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Testing
@testable import testGaspi

struct SearchProductsUseCaseTests {
    @Test func blankQueryReturnsEmptyWithoutCallingTheRepository() async throws {
        let repository = MockProductRepository()
        let sut = SearchProductsUseCase(repository: repository)

        let result = try await sut.execute(query: "   ", page: 1)

        #expect(result.isEmpty)
        #expect(repository.receivedQueries.isEmpty)
    }

    @Test func trimsTheQueryAndForwardsThePageToTheRepository() async throws {
        let repository = MockProductRepository()
        repository.result = .success([
            Product(id: "1", title: "Nintendo Switch", price: 299, currencyId: "USD", thumbnailURL: nil)
        ])
        let sut = SearchProductsUseCase(repository: repository)

        let result = try await sut.execute(query: "  nintendo  ", page: 3)

        #expect(repository.receivedQueries.count == 1)
        #expect(repository.receivedQueries.first?.query == "nintendo")
        #expect(repository.receivedQueries.first?.page == 3)
        #expect(result.count == 1)
    }

    @Test func propagatesErrorsThrownByTheRepository() async throws {
        struct StubError: Error {}
        let repository = MockProductRepository()
        repository.result = .failure(StubError())
        let sut = SearchProductsUseCase(repository: repository)

        await #expect(throws: StubError.self) {
            _ = try await sut.execute(query: "nintendo", page: 1)
        }
    }
}
