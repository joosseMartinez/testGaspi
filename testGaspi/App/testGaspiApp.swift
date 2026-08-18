//
//  testGaspiApp.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import SwiftUI

@main
struct testGaspiApp: App {
    private let container = DIContainer()

    var body: some Scene {
        WindowGroup {
            CoordinatorView(container: container)
        }
    }
}
