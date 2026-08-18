//
//  CoordinatorView.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import SwiftUI

/// Hosts the app's single `NavigationStack` and resolves each `AppRoute`
/// pushed by `AppCoordinator` into its destination view.
struct CoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SearchView(viewModel: container.makeSearchViewModel(coordinator: coordinator))
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .productDetail(let product):
            ProductDetailView(viewModel: container.makeProductDetailViewModel(product: product))
        }
    }
}
