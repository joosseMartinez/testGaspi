//
//  SearchHistoryLocalDataSource.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

protocol SearchHistoryLocalDataSourceProtocol {
    func fetchHistory() -> [SearchTerm]
    func save(_ term: SearchTerm)
    func clear()
}

/// Persists search history in `UserDefaults`. Swap this implementation
/// behind `SearchHistoryLocalDataSourceProtocol` if a richer store (e.g. Core Data) is needed later.
final class SearchHistoryLocalDataSource: SearchHistoryLocalDataSourceProtocol {
    private struct StoredTerm: Codable {
        let query: String
        let date: Date

        init(_ term: SearchTerm) {
            query = term.query
            date = term.date
        }

        func toDomain() -> SearchTerm {
            SearchTerm(query: query, date: date)
        }
    }

    private let userDefaults: UserDefaults
    private let storageKey = "com.testGaspi.searchHistory"
    private let maxItems = 20

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchHistory() -> [SearchTerm] {
        guard
            let data = userDefaults.data(forKey: storageKey),
            let stored = try? JSONDecoder().decode([StoredTerm].self, from: data)
        else {
            return []
        }
        return stored.map { $0.toDomain() }.sorted { $0.date > $1.date }
    }

    func save(_ term: SearchTerm) {
        var current = fetchHistory().filter { $0.id != term.id }
        current.insert(term, at: 0)
        if current.count > maxItems {
            current = Array(current.prefix(maxItems))
        }
        guard let data = try? JSONEncoder().encode(current.map(StoredTerm.init)) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    func clear() {
        userDefaults.removeObject(forKey: storageKey)
    }
}
