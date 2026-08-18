//
//  ProductRepositoryProtocol.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

protocol ProductRepositoryProtocol {
    /// - Parameters:
    ///   - query: the search keyword (criterio).
    ///   - page: page number to fetch, for infinite-scroll pagination.
    func searchProducts(query: String, page: Int) async throws -> [Product]
}
