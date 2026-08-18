//
//  SearchHistoryUseCaseTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Testing
@testable import testGaspi

struct SearchHistoryUseCaseTests {
    @Test func fetchHistoryDelegatesToTheRepository() {
        let repository = MockSearchHistoryRepository()
        repository.historyToReturn = [SearchTerm(query: "nintendo")]
        let sut = SearchHistoryUseCase(repository: repository)

        #expect(sut.fetchHistory().map(\.query) == ["nintendo"])
    }

    @Test func saveTrimsTheQueryBeforeDelegating() {
        let repository = MockSearchHistoryRepository()
        let sut = SearchHistoryUseCase(repository: repository)

        sut.save(query: "  sony  ")

        #expect(repository.savedQueries == ["sony"])
    }

    @Test func saveIgnoresABlankQuery() {
        let repository = MockSearchHistoryRepository()
        let sut = SearchHistoryUseCase(repository: repository)

        sut.save(query: "   ")

        #expect(repository.savedQueries.isEmpty)
    }

    @Test func clearHistoryDelegatesToTheRepository() {
        let repository = MockSearchHistoryRepository()
        let sut = SearchHistoryUseCase(repository: repository)

        sut.clearHistory()

        #expect(repository.clearHistoryCallCount == 1)
    }
}
