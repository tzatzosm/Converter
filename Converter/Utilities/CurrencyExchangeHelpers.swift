//
//  CurrencyExchangeHelpers.swift
//  Converter
//
//  Created by Marsel Tzatzo on 7/4/22.
//

import Foundation


//Clarification: Using enum instead of struct cause we dont wont someone to accidentally initialize an instance of this class
enum CurrencyExchangeHelpers {
    enum Error: Swift.Error {
        case fromCurrencyMissing
        case toCurrencyMissing
    }
    
    static func calculateExchange(forAmount amount: Float, withRates rates: [String: Float], sellCurrency: String, receiveCurrency: String) throws -> Float {
        guard let sellRate = rates[sellCurrency] else {
            throw Error.fromCurrencyMissing
        }
        guard let receiveRate = rates[receiveCurrency] else {
            throw Error.toCurrencyMissing
        }
        return amount * 1.0 / sellRate * receiveRate
    }
}
