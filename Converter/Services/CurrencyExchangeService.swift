//
//  ExchangeRatesInteractor.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import Combine
import Foundation
import SwiftUI

enum ExchangeError: Error {
    case balanceMissing
    case ratesMissing
    case insufficientFunds
}

struct ExchangeResult {
    let sellCurrency: String
    let sellAmount: Float
    let receiveCurrency: String
    let receiveAmount: Float
    let comissionFee: Float
}

protocol AnyCurrencyExchangeService {
    func pollExchangeRates(
        exchangeRatesResponse: LoadableSubject<ExchangeRatesResponse>)
    
    func exchange(
        sellAmount: Float,
        sellCurrency: String,
        receiveCurrency: String) throws -> ExchangeResult
}

class CurrencyExchangeService: AnyCurrencyExchangeService {
    private let appState: Store<AppState>
    private let exchangeRatesRepository: AnyExchangeRatesRepository
    
    let timerPublisher: Timer.TimerPublisher
    let cancelBag = CancelBag()
    
    init(
        appState: Store<AppState>,
        exchangeRatesRepository: AnyExchangeRatesRepository
    ) {
        self.appState = appState
        self.exchangeRatesRepository = exchangeRatesRepository
        timerPublisher = Timer.publish(every: 15, on: .main, in: .common)
    }
    
    func pollExchangeRates(exchangeRatesResponse: LoadableSubject<ExchangeRatesResponse>) {
        exchangeRatesResponse.wrappedValue.setIsLoading(cancelBag: cancelBag)
        timerPublisher
            .autoconnect()
            .map { _ in () }
            .prepend(()) // Prepend one element so that it starts immediately
            .map { [exchangeRatesRepository] _ -> AnyPublisher<ExchangeRatesResponse, Error> in
                return exchangeRatesRepository.loadExchangeRates()
            }
            .switchToLatest()
            .sinkToLoadable { [weak self] in
                self?.appState.value.rates = $0.value?.rates ?? [:]
                exchangeRatesResponse.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
    
    func exchange(sellAmount: Float, sellCurrency: String, receiveCurrency: String) throws -> ExchangeResult {
        let rates = appState.value.rates
        let comissionFee = try calculateComissionFee(
            exchangesCount: appState.value.conversionsCount,
            rates: rates,
            sellAmount: sellAmount,
            sellCurrency: sellCurrency)
        let amountCharged = sellAmount + comissionFee
        guard let sellBalance = appState.value.userBalance[sellCurrency] else {
            throw ExchangeError.balanceMissing
        }
        guard sellBalance > amountCharged else {
            throw ExchangeError.insufficientFunds
        }
        let receiveAmount = try CurrencyExchangeHelpers.calculateExchange(
            forAmount: sellAmount,
            withRates: rates,
            sellCurrency: sellCurrency,
            receiveCurrency: receiveCurrency)
        var balance = appState.value.userBalance
        let newSellBalance = sellBalance - amountCharged
        let newReceiveBalance = (balance[receiveCurrency] ?? 0) + receiveAmount
        balance[sellCurrency] = newSellBalance
        balance[receiveCurrency] = newReceiveBalance
        appState.value.userBalance = balance
        appState.value.conversionsCount += 1
        return .init(
            sellCurrency: sellCurrency,
            sellAmount: sellAmount,
            receiveCurrency: receiveCurrency,
            receiveAmount: receiveAmount,
            comissionFee: comissionFee)
    }
}

private extension CurrencyExchangeService {
    func calculateComissionFee(exchangesCount: Int, rates: [String: Float], sellAmount: Float, sellCurrency: String) throws -> Float {
        switch exchangesCount {
        case let exchangesCount where exchangesCount < 5:
            return 0
        case let exchangesCount where exchangesCount < 15:
            return sellAmount * 0.007
        default:
            let baseComission = try CurrencyExchangeHelpers.calculateExchange(
                forAmount: 0.3,
                withRates: rates,
                sellCurrency: "EUR",
                receiveCurrency: sellCurrency)
            return baseComission + 0.012 * sellAmount
        }
    }
}
