//
//  WebRepository.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import Combine
import Foundation

protocol NetworkRepository {
    var session: URLSession { get }
    var baseURL: String { get }
}

extension NetworkRepository {
    func request<Value>(
        route: Router
    ) -> AnyPublisher<Value, Error> where Value: Decodable {
        do {
            let request = try route.asURLRequest(baseURL: baseURL)
            return session
                .dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Value.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch let error {
            return Fail<Value, Error>(error: error).eraseToAnyPublisher()
        }
    }
}
