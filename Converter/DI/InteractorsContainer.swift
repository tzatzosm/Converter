//
//  InteractorsContainer.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import Foundation

extension DIContainer {
    struct Services {
        let currencyExchangeService: AnyCurrencyExchangeService
        
        
        init(currencyExchangeService: AnyCurrencyExchangeService) {
            self.currencyExchangeService = currencyExchangeService
        }
        
        static var stub: Self {
            let exchangeRatesRepository = ExchangeRatesRepository(session: URLSession.shared, baseURL: String())
            let balanceRepository = BalanceRepository()
            let service = CurrencyExchangeService(
                exchangeRatesRepository: exchangeRatesRepository,
                balanceRepository: balanceRepository)
            return .init(currencyExchangeService: service)
        }
    }
}
