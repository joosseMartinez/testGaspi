//
//  AppCoordinatorTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import SwiftUI
import Testing
@testable import testGaspi

@MainActor
struct AppCoordinatorTests {
    private let product = Product(id: "1", title: "Nintendo Switch", price: 299, currencyId: "USD", thumbnailURL: nil)

    @Test func pushAppendsARouteToThePath() {
        let sut = AppCoordinator()

        sut.push(.productDetail(product))

        #expect(sut.path.count == 1)
    }

    @Test func popRemovesTheLastRouteWhenThePathIsNotEmpty() {
        let sut = AppCoordinator()
        sut.push(.productDetail(product))

        sut.pop()

        #expect(sut.path.isEmpty)
    }

    @Test func popIsANoOpWhenThePathIsEmpty() {
        let sut = AppCoordinator()

        sut.pop()

        #expect(sut.path.isEmpty)
    }

    @Test func popToRootClearsTheWholePath() {
        let sut = AppCoordinator()
        sut.push(.productDetail(product))
        sut.push(.productDetail(product))

        sut.popToRoot()

        #expect(sut.path.isEmpty)
    }
}
