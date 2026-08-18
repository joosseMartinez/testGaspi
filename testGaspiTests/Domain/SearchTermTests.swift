//
//  SearchTermTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
import Testing
@testable import testGaspi

struct SearchTermTests {
    @Test func idIsTheLowercasedQuery() {
        let term = SearchTerm(query: "Nintendo Switch")

        #expect(term.id == "nintendo switch")
    }

    @Test func defaultDateIsSetAtInitTime() {
        let before = Date()
        let term = SearchTerm(query: "sony")
        let after = Date()

        #expect(term.date >= before && term.date <= after)
    }

    @Test func explicitDateIsPreserved() {
        let date = Date(timeIntervalSince1970: 1_000)
        let term = SearchTerm(query: "sony", date: date)

        #expect(term.date == date)
    }
}
