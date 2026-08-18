//
//  Product.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

struct Product: Identifiable, Hashable {
    let id: String
    let title: String
    let price: Double
    let currencyId: String
    let thumbnailURL: URL?
}

extension Product {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if !currencyId.isEmpty {
            formatter.currencyCode = currencyId
        }
        return formatter.string(from: NSNumber(value: price)) ?? String(price)
    }
}
