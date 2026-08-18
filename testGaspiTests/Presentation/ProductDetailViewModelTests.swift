//
//  ProductDetailViewModelTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Testing
@testable import testGaspi

@MainActor
struct ProductDetailViewModelTests {
    @Test func storesTheInjectedProduct() {
        let product = Product(id: "1", title: "Nintendo Switch", price: 299, currencyId: "USD", thumbnailURL: nil)

        let sut = ProductDetailViewModel(product: product)

        #expect(sut.product == product)
    }
}
