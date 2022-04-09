//
//  ExchangeRateResponse.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import Foundation

struct ExchangeRatesResponse: Decodable {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let success: Bool
    let timestamp: Date
    let base: String
    let date: Date
    let rates: [String: Float]
    
    enum CodingKeys: String, CodingKey {
        case success, timestamp, base, date, rates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.base = try container.decode(String.self, forKey: .base)
        let dateString = try container.decode(String.self, forKey: .date)
        guard let date = Self.dateFormatter.date(from: dateString) else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.date],
                debugDescription: "\(dateString) is not in the expected format: \"yyyy-MM-dd\"")
            throw DecodingError.typeMismatch(Date.self, context)
        }
        self.date = date
        self.rates = try container.decode([String: Float].self, forKey: .rates)
    }
}
