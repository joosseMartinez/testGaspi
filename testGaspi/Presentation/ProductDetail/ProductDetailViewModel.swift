//
//  ProductDetailViewModel.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Combine

@MainActor
final class ProductDetailViewModel: ObservableObject {
    let product: Product

    init(product: Product) {
        self.product = product
    }
}
