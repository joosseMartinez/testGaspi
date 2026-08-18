//
//  SearchHistoryLocalDataSourceTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
import Testing
@testable import testGaspi

struct SearchHistoryLocalDataSourceTests {
    private func makeSUT() -> (sut: SearchHistoryLocalDataSource, defaults: UserDefaults, suiteName: String) {
        let suiteName = "testGaspi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        return (SearchHistoryLocalDataSource(userDefaults: defaults), defaults, suiteName)
    }

    @Test func fetchHistoryIsEmptyByDefault() {
        let (sut, defaults, suiteName) = makeSUT()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        #expect(sut.fetchHistory().isEmpty)
    }

    @Test func savePersistsTermsMostRecentFirst() {
        let (sut, defaults, suiteName) = makeSUT()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        sut.save(SearchTerm(query: "nintendo", date: Date(timeIntervalSince1970: 1)))
        sut.save(SearchTerm(query: "sony", date: Date(timeIntervalSince1970: 2)))

        #expect(sut.fetchHistory().map(\.query) == ["sony", "nintendo"])
    }

    @Test func savingTheSameQueryCaseInsensitivelyDedupsAndMovesItToTheFront() {
        let (sut, defaults, suiteName) = makeSUT()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        sut.save(SearchTerm(query: "Nintendo", date: Date(timeIntervalSince1970: 1)))
        sut.save(SearchTerm(query: "sony", date: Date(timeIntervalSince1970: 2)))
        sut.save(SearchTerm(query: "nintendo", date: Date(timeIntervalSince1970: 3)))

        let history = sut.fetchHistory()
        #expect(history.count == 2)
        #expect(history.first?.query == "nintendo")
    }

    @Test func historyIsCappedAtTwentyItems() {
        let (sut, defaults, suiteName) = makeSUT()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        for index in 0..<25 {
            sut.save(SearchTerm(query: "term\(index)", date: Date(timeIntervalSince1970: TimeInterval(index))))
        }

        let history = sut.fetchHistory()
        #expect(history.count == 20)
        #expect(history.first?.query == "term24")
        #expect(!history.contains { $0.query == "term0" })
    }

    @Test func clearRemovesAllPersistedHistory() {
        let (sut, defaults, suiteName) = makeSUT()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        sut.save(SearchTerm(query: "nintendo"))
        sut.clear()

        #expect(sut.fetchHistory().isEmpty)
    }
}
