//
//  SearchHistoryRepositoryTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Testing
@testable import testGaspi

struct SearchHistoryRepositoryTests {
    @Test func fetchHistoryDelegatesToTheLocalDataSource() {
        let localDataSource = MockSearchHistoryLocalDataSource()
        localDataSource.historyToReturn = [SearchTerm(query: "nintendo")]
        let sut = SearchHistoryRepository(localDataSource: localDataSource)

        #expect(sut.fetchHistory().map(\.query) == ["nintendo"])
    }

    @Test func saveWrapsTheQueryIntoASearchTermAndDelegates() {
        let localDataSource = MockSearchHistoryLocalDataSource()
        let sut = SearchHistoryRepository(localDataSource: localDataSource)

        sut.save(query: "sony")

        #expect(localDataSource.savedTerms.map(\.query) == ["sony"])
    }

    @Test func clearHistoryDelegatesToTheLocalDataSource() {
        let localDataSource = MockSearchHistoryLocalDataSource()
        let sut = SearchHistoryRepository(localDataSource: localDataSource)

        sut.clearHistory()

        #expect(localDataSource.clearCallCount == 1)
    }
}
