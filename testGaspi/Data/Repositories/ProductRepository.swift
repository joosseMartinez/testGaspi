//
//  ProductRepository.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

final class ProductRepository: ProductRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func searchProducts(query: String, page: Int) async throws -> [Product] {
        let endpoint = APIEndpoint(
            path: "/wlm/walmart-search-by-keyword",
            queryItems: [
                URLQueryItem(name: "keyword", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "sortBy", value: "best_match")
            ]
        )
        let response: ProductSearchResponseDTO = try await apiClient.request(endpoint)
        return response.results.map { $0.toDomain() }
    }
}
