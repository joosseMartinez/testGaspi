//
//  APIError.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .invalidResponse:
            return "Respuesta inválida del servidor."
        case .httpError(let statusCode):
            return "Error del servidor (\(statusCode))."
        case .decodingFailed:
            return "No se pudo procesar la respuesta del servidor."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
