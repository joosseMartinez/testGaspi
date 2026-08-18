//
//  SearchHistoryUseCase.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

protocol SearchHistoryUseCaseProtocol {
    func fetchHistory() -> [SearchTerm]
    func save(query: String)
    func clearHistory()
}

final class SearchHistoryUseCase: SearchHistoryUseCaseProtocol {
    private let repository: SearchHistoryRepositoryProtocol

    init(repository: SearchHistoryRepositoryProtocol) {
        self.repository = repository
    }

    func fetchHistory() -> [SearchTerm] {
        repository.fetchHistory()
    }

    func save(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        repository.save(query: trimmed)
    }

    func clearHistory() {
        repository.clearHistory()
    }
}
