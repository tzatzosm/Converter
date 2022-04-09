//
//  ExchangeRateRespository.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import Combine
import Foundation

protocol AnyExchangeRatesRepository: NetworkRepository {
    func loadExchangeRates() -> AnyPublisher<ExchangeRatesResponse, Error>
}

struct ExchangeRatesRepository: AnyExchangeRatesRepository {
    let session: URLSession
    let baseURL: String
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func loadExchangeRates() -> AnyPublisher<ExchangeRatesResponse, Error> {
        return request(route: Router.getExchangeRates)
    }
}

extension ExchangeRatesRepository {
    enum Router {
        case getExchangeRates
    }
}

extension ExchangeRatesRepository.Router: Router {
    var path: String {
        "/v1/latest?access_key=51ab060c5fe3f2ee4d7dd8a9971b2aae"
    }
    
    var method: HTTPMethod {
        .GET
    }
}

struct MockExchangeRatesRepository: AnyExchangeRatesRepository {
    var session: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    var baseURL: String = ""
    
    enum MockError: Swift.Error {
        case pathNotFound
        case couldNotReadData
    }
    
    func loadExchangeRates() -> AnyPublisher<ExchangeRatesResponse, Error> {
        guard let path = Bundle.main.path(forResource: "data", ofType: "json") else {
            return Fail<ExchangeRatesResponse, Error>(error: MockError.pathNotFound).eraseToAnyPublisher()
        }
        guard let jsonData = try? String(contentsOfFile: path).data(using: .utf8) else {
            return Fail<ExchangeRatesResponse, Error>(error: MockError.couldNotReadData).eraseToAnyPublisher()
        }
        do {
            let response = try JSONDecoder().decode(ExchangeRatesResponse.self, from: jsonData)
            return Just<ExchangeRatesResponse>.withErrorType(response, Error.self).eraseToAnyPublisher()
        } catch {
            return Fail<ExchangeRatesResponse, Error>(error: MockError.couldNotReadData).eraseToAnyPublisher()
        }
    }
}
