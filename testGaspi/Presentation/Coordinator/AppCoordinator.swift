//
//  AppCoordinator.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Combine
import SwiftUI

@MainActor
protocol Coordinator: ObservableObject {
    var path: NavigationPath { get set }
    func push(_ route: AppRoute)
    func pop()
    func popToRoot()
}

@MainActor
final class AppCoordinator: Coordinator {
    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
