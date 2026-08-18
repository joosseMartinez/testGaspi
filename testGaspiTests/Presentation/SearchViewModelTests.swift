//
//  SearchViewModelTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
import SwiftUI
import Testing
@testable import testGaspi

@MainActor
struct SearchViewModelTests {
    private func makeSUT(
        searchResult: Result<[Product], Error> = .success([]),
        history: [SearchTerm] = []
    ) -> (
        sut: SearchViewModel,
        searchUseCase: MockSearchProductsUseCase,
        historyUseCase: MockSearchHistoryUseCase,
        coordinator: AppCoordinator
    ) {
        let searchUseCase = MockSearchProductsUseCase()
        searchUseCase.result = searchResult
        let historyUseCase = MockSearchHistoryUseCase()
        historyUseCase.historyToReturn = history
        let coordinator = AppCoordinator()
        let sut = SearchViewModel(
            searchProductsUseCase: searchUseCase,
            searchHistoryUseCase: historyUseCase,
            coordinator: coordinator
        )
        return (sut, searchUseCase, historyUseCase, coordinator)
    }

    @Test func loadsHistoryAndStartsIdleOnInit() {
        let (sut, _, _, _) = makeSUT(history: [SearchTerm(query: "nintendo")])

        #expect(sut.state == .idle)
        #expect(sut.history.map(\.query) == ["nintendo"])
    }

    @Test func searchingWithABlankQuerySetsIdleWithoutCallingTheUseCase() async {
        let (sut, searchUseCase, _, _) = makeSUT()

        await sut.search(query: "   ")?.value

        #expect(sut.state == .idle)
        #expect(searchUseCase.receivedQueries.isEmpty)
    }

    @Test func searchingWithResultsTransitionsToLoadedAndUpdatesHistory() async {
        let product = Product(id: "1", title: "Nintendo Switch", price: 299, currencyId: "USD", thumbnailURL: nil)
        let (sut, searchUseCase, historyUseCase, _) = makeSUT(searchResult: .success([product]))
        historyUseCase.historyToReturn = [SearchTerm(query: "nintendo")]

        await sut.search(query: "nintendo")?.value

        #expect(sut.state == .loaded([product]))
        #expect(searchUseCase.receivedQueries.first?.query == "nintendo")
        #expect(historyUseCase.savedQueries == ["nintendo"])
        #expect(sut.history.map(\.query) == ["nintendo"])
    }

    @Test func searchingWithNoResultsTransitionsToEmpty() async {
        let (sut, _, _, _) = makeSUT(searchResult: .success([]))

        await sut.search(query: "asdkjaskjd")?.value

        #expect(sut.state == .empty)
    }

    @Test func searchingWhenTheUseCaseFailsTransitionsToError() async {
        struct StubError: LocalizedError {
            var errorDescription: String? { "boom" }
        }
        let (sut, _, _, _) = makeSUT(searchResult: .failure(StubError()))

        await sut.search(query: "nintendo")?.value

        #expect(sut.state == .error("boom"))
    }

    @Test func selectHistorySetsTheQueryText() {
        let (sut, _, _, _) = makeSUT()

        sut.selectHistory(SearchTerm(query: "sony"))

        #expect(sut.queryText == "sony")
    }

    @Test func clearHistoryEmptiesThePublishedHistoryAndDelegates() {
        let (sut, _, historyUseCase, _) = makeSUT(history: [SearchTerm(query: "nintendo")])

        sut.clearHistory()

        #expect(sut.history.isEmpty)
        #expect(historyUseCase.clearCallCount == 1)
    }

    @Test func didSelectPushesAProductDetailRouteOnTheCoordinator() {
        let (sut, _, _, coordinator) = makeSUT()
        let product = Product(id: "1", title: "Nintendo Switch", price: 299, currencyId: "USD", thumbnailURL: nil)

        sut.didSelect(product)

        #expect(coordinator.path.count == 1)
    }

    @Test func settingQueryTextTriggersADebouncedSearch() async throws {
        let product = Product(id: "1", title: "Nintendo Switch", price: 299, currencyId: "USD", thumbnailURL: nil)
        let (sut, searchUseCase, _, _) = makeSUT(searchResult: .success([product]))

        sut.queryText = "nintendo"
        try await Task.sleep(for: .milliseconds(700))

        #expect(searchUseCase.receivedQueries.first?.query == "nintendo")
        #expect(sut.state == .loaded([product]))
    }

    /// If the query is edited while a search is in flight, the stale call must be cancelled
    /// and never allowed to overwrite the state set by the new one.
    @Test func editingTheQueryCancelsTheInFlightSearchInsteadOfLettingItOverwriteTheNewOne() async {
        let staleProduct = Product(id: "1", title: "Stale result", price: 1, currencyId: "USD", thumbnailURL: nil)
        let freshProduct = Product(id: "2", title: "Fresh result", price: 2, currencyId: "USD", thumbnailURL: nil)
        let (sut, searchUseCase, _, _) = makeSUT()

        searchUseCase.result = .success([staleProduct])
        searchUseCase.delay = .milliseconds(200)
        let staleTask = sut.search(query: "first")

        searchUseCase.result = .success([freshProduct])
        searchUseCase.delay = .zero
        let freshTask = sut.search(query: "second")

        await staleTask?.value
        await freshTask?.value

        #expect(searchUseCase.receivedQueries.map(\.query) == ["first", "second"])
        #expect(sut.state == .loaded([freshProduct]))
    }
}
