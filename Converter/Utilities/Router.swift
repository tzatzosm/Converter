//
//  Router.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import Foundation

protocol Router {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get throws }
}

extension Router {
    var headers: [String: String]? { nil }
    var body: Data? {
        get throws {
            nil
        }
    }
}

extension Router {
    func asURLRequest(baseURL: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = try body
        return request
    }
}


