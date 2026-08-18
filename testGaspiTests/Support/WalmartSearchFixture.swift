//
//  WalmartSearchFixture.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
@testable import testGaspi

/// Trimmed-down mirror of a real `GET /wlm/walmart-search-by-keyword` response,
/// verified against a live capture: two stacks, each with one real product tile
/// plus one non-product tile (`AdPlaceholder` / `TileTakeOverProductPlaceholder`).
enum WalmartSearchFixture {
    static let json = """
    {
        "responseStatus": "PRODUCT_FOUND_RESPONSE",
        "responseMessage": "Product successfully found!",
        "sortStrategy": "best_match",
        "keyword": "nintendo",
        "item": {
            "props": {
                "pageProps": {
                    "initialData": {
                        "searchResult": {
                            "itemStacks": [
                                {
                                    "items": [
                                        {
                                            "__typename": "Product",
                                            "usItemId": "111",
                                            "name": "Nintendo Switch OLED",
                                            "price": 349.99,
                                            "image": "https://example.com/switch.png"
                                        },
                                        {
                                            "__typename": "AdPlaceholder",
                                            "adUuid": "abc-123"
                                        }
                                    ]
                                },
                                {
                                    "items": [
                                        {
                                            "__typename": "Product",
                                            "usItemId": "222",
                                            "name": "Nintendo 64 Console",
                                            "price": 129,
                                            "image": "https://example.com/n64.png"
                                        },
                                        {
                                            "__typename": "TileTakeOverProductPlaceholder",
                                            "isPrismTiletakeOver": true
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            }
        }
    }
    """

    static func decode() throws -> ProductSearchResponseDTO {
        try JSONDecoder().decode(ProductSearchResponseDTO.self, from: Data(json.utf8))
    }
}
