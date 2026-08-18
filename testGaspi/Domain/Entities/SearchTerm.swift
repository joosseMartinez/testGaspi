//
//  SearchTerm.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

struct SearchTerm: Identifiable, Hashable {
    let id: String
    let query: String
    let date: Date

    init(query: String, date: Date = Date()) {
        self.id = query.lowercased()
        self.query = query
        self.date = date
    }
}
