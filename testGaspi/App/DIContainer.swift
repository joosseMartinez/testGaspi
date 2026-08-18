//
//  DIContainer.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

/// Composition root: wires Data implementations behind Domain protocols
/// and assembles the view models the Coordinator hands to each screen.
final class DIContainer {
    private static let rapidAPIHost = "axesso-walmart-data-service.p.rapidapi.com"

    private lazy var apiClient: APIClientProtocol = APIClient(
        baseURL: URL(string: "https://\(Self.rapidAPIHost)"),
        defaultHeaders: [
            "x-rapidapi-key": Secrets.rapidAPIKey
        ]
    )
    private lazy var productRepository: ProductRepositoryProtocol = ProductRepository(apiClient: apiClient)

    private lazy var searchHistoryLocalDataSource: SearchHistoryLocalDataSourceProtocol = SearchHistoryLocalDataSource()
    private lazy var searchHistoryRepository: SearchHistoryRepositoryProtocol = SearchHistoryRepository(
        localDataSource: searchHistoryLocalDataSource
    )

    private lazy var searchProductsUseCase: SearchProductsUseCaseProtocol = SearchProductsUseCase(
        repository: productRepository
    )
    private lazy var searchHistoryUseCase: SearchHistoryUseCaseProtocol = SearchHistoryUseCase(
        repository: searchHistoryRepository
    )

    @MainActor
    func makeSearchViewModel(coordinator: AppCoordinator) -> SearchViewModel {
        SearchViewModel(
            searchProductsUseCase: searchProductsUseCase,
            searchHistoryUseCase: searchHistoryUseCase,
            coordinator: coordinator
        )
    }

    @MainActor
    func makeProductDetailViewModel(product: Product) -> ProductDetailViewModel {
        ProductDetailViewModel(product: product)
    }
}
