//
//  ProductSearchResponseDTO.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

// Response shape for GET /wlm/walmart-search-by-keyword (Axesso Walmart Data Service):
// item.props.pageProps.initialData.searchResult.itemStacks[].items[]
struct ProductSearchResponseDTO: Decodable {
    let item: ItemDTO

    struct ItemDTO: Decodable {
        let props: PropsDTO
    }

    struct PropsDTO: Decodable {
        let pageProps: PagePropsDTO
    }

    struct PagePropsDTO: Decodable {
        let initialData: InitialDataDTO
    }

    struct InitialDataDTO: Decodable {
        let searchResult: SearchResultDTO
    }

    struct SearchResultDTO: Decodable {
        let itemStacks: [ItemStackDTO]
    }

    struct ItemStackDTO: Decodable {
        /// `items` mixes real products with ad/layout tiles (`AdPlaceholder`,
        /// `TileTakeOverProductPlaceholder`, …) that don't decode as `ProductDTO`;
        /// those are dropped instead of failing the whole page.
        private let items: [FailableDecodable<ProductDTO>]?

        var products: [ProductDTO] {
            (items ?? []).compactMap(\.value)
        }
    }

    /// Flattens products across every stack (some stacks — banners, facets — carry no `items`).
    var results: [ProductDTO] {
        item.props.pageProps.initialData.searchResult.itemStacks.flatMap { $0.products }
    }
}

private struct FailableDecodable<T: Decodable>: Decodable {
    let value: T?

    init(from decoder: Decoder) throws {
        value = try? T(from: decoder)
    }
}

struct ProductDTO: Decodable {
    let usItemId: String
    let name: String
    let price: Double
    let image: String
}

extension ProductDTO {
    func toDomain() -> Product {
        Product(
            id: usItemId,
            title: name,
            price: price,
            currencyId: "USD",
            thumbnailURL: URL(string: image)
        )
    }
}
