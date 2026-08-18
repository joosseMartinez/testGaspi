//
//  ProductSearchResponseDTOTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
import Testing
@testable import testGaspi

struct ProductSearchResponseDTOTests {
    @Test func decodesOnlyRealProductTilesAcrossAllStacks() throws {
        let dto = try WalmartSearchFixture.decode()

        #expect(dto.results.count == 2)
        #expect(dto.results.map(\.usItemId) == ["111", "222"])
    }

    @Test func mapsAProductDTOToTheDomainEntity() throws {
        let dto = try WalmartSearchFixture.decode()
        let product = try #require(dto.results.first)

        let domain = product.toDomain()

        #expect(domain.id == "111")
        #expect(domain.title == "Nintendo Switch OLED")
        #expect(domain.price == 349.99)
        #expect(domain.currencyId == "USD")
        #expect(domain.thumbnailURL == URL(string: "https://example.com/switch.png"))
    }
}
