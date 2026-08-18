//
//  APIEndpoint.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import Foundation

struct APIEndpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
    /// Headers specific to this request. Merged on top of `APIClient`'s default headers.
    var headers: [String: String] = [:]
}
