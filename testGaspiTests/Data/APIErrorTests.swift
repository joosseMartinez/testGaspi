//
//  APIErrorTests.swift
//  testGaspiTests
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation
import Testing
@testable import testGaspi

struct APIErrorTests {
    @Test func eachCaseProvidesALocalizedDescription() {
        struct Underlying: LocalizedError {
            var errorDescription: String? { "underlying message" }
        }

        #expect(APIError.invalidURL.errorDescription == "URL inválida.")
        #expect(APIError.invalidResponse.errorDescription == "Respuesta inválida del servidor.")
        #expect(APIError.httpError(statusCode: 404).errorDescription == "Error del servidor (404).")
        #expect(APIError.decodingFailed(NSError(domain: "test", code: 1)).errorDescription == "No se pudo procesar la respuesta del servidor.")
        #expect(APIError.underlying(Underlying()).errorDescription == "underlying message")
    }
}
