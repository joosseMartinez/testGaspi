//
//  ProductTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
import Testing
@testable import testGaspi

struct ProductTests {
    @Test func formattedPriceUsesCurrencyFormatterWhenCurrencyIdIsPresent() {
        let product = Product(id: "1", title: "Nintendo Switch", price: 349.99, currencyId: "USD", thumbnailURL: nil)

        let expectedFormatter = NumberFormatter()
        expectedFormatter.numberStyle = .currency
        expectedFormatter.currencyCode = "USD"
        let expected = expectedFormatter.string(from: NSNumber(value: 349.99))

        #expect(product.formattedPrice == expected)
    }

    @Test func formattedPriceOmitsCurrencyCodeWhenCurrencyIdIsEmpty() {
        let product = Product(id: "1", title: "Nintendo Switch", price: 349.99, currencyId: "", thumbnailURL: nil)

        let expectedFormatter = NumberFormatter()
        expectedFormatter.numberStyle = .currency
        let expected = expectedFormatter.string(from: NSNumber(value: 349.99))

        #expect(product.formattedPrice == expected)
    }
}
