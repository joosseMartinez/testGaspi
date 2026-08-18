//
//  SearchHistoryRepository.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

final class SearchHistoryRepository: SearchHistoryRepositoryProtocol {
    private let localDataSource: SearchHistoryLocalDataSourceProtocol

    init(localDataSource: SearchHistoryLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    func fetchHistory() -> [SearchTerm] {
        localDataSource.fetchHistory()
    }

    func save(query: String) {
        localDataSource.save(SearchTerm(query: query))
    }

    func clearHistory() {
        localDataSource.clear()
    }
}
