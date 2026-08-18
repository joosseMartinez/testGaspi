//
//  SearchViewModel.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([Product])
        case empty
        case error(String)
    }

    @Published var queryText: String = ""
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var history: [SearchTerm] = []

    private let searchProductsUseCase: SearchProductsUseCaseProtocol
    private let searchHistoryUseCase: SearchHistoryUseCaseProtocol
    private weak var coordinator: AppCoordinator?

    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    init(
        searchProductsUseCase: SearchProductsUseCaseProtocol,
        searchHistoryUseCase: SearchHistoryUseCaseProtocol,
        coordinator: AppCoordinator
    ) {
        self.searchProductsUseCase = searchProductsUseCase
        self.searchHistoryUseCase = searchHistoryUseCase
        self.coordinator = coordinator
        self.history = searchHistoryUseCase.fetchHistory()
        observeQueryText()
    }

    private func observeQueryText() {
        $queryText
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.search(query: text)
            }
            .store(in: &cancellables)
    }

    /// Runs the search off the main thread via `async/await` so the UI never blocks while waiting on the network.
    /// Returns the underlying `Task` (nil for a blank query) so callers — namely tests — can await completion deterministically.
    @discardableResult
    func search(query: String) -> Task<Void, Never>? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()

        guard !trimmed.isEmpty else {
            state = .idle
            return nil
        }

        state = .loading
        let task = Task { [weak self] in
            guard let self else { return }
            do {
                // `page` is fixed at 1 for now; pagination will drive this from scroll position later.
                let products = try await self.searchProductsUseCase.execute(query: trimmed, page: 1)
                guard !Task.isCancelled else { return }
                self.state = products.isEmpty ? .empty : .loaded(products)
                self.searchHistoryUseCase.save(query: trimmed)
                self.history = self.searchHistoryUseCase.fetchHistory()
            } catch {
                guard !Task.isCancelled else { return }
                self.state = .error(error.localizedDescription)
            }
        }
        searchTask = task
        return task
    }

    func selectHistory(_ term: SearchTerm) {
        queryText = term.query
    }

    func clearHistory() {
        searchHistoryUseCase.clearHistory()
        history = []
    }

    func didSelect(_ product: Product) {
        coordinator?.push(.productDetail(product))
    }
}
