//
//  SearchProductsUseCase.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

protocol SearchProductsUseCaseProtocol {
    func execute(query: String, page: Int) async throws -> [Product]
}

final class SearchProductsUseCase: SearchProductsUseCaseProtocol {
    private let repository: ProductRepositoryProtocol

    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String, page: Int) async throws -> [Product] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return try await repository.searchProducts(query: trimmed, page: page)
    }
}
