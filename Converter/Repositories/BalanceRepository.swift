//
//  ConversionRepository.swift
//  Converter
//
//  Created by Marsel Tzatzo on 9/4/22.
//

import Foundation

protocol AnyBalanceRepository {
    var exchangesCount: Int { get }
    
    mutating func incrementExchangesCount()
}

struct BalanceRepository: AnyBalanceRepository {
    var exchangesCount: Int = 0
    
    mutating func incrementExchangesCount() {
        self.exchangesCount += 1
    }
}
