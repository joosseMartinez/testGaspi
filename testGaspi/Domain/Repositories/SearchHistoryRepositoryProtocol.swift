//
//  SearchHistoryRepositoryProtocol.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

protocol SearchHistoryRepositoryProtocol {
    func fetchHistory() -> [SearchTerm]
    func save(query: String)
    func clearHistory()
}
