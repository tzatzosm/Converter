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
    case insufficientFunds
}

struct ExchangeResult {
    let balance: [String: Float]
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
        balance: [String: Float],
        rates: [String: Float],
        sellAmount: Float,
        sellCurrency: String,
        receiveCurrency: String) throws -> ExchangeResult
}

class CurrencyExchangeService: AnyCurrencyExchangeService {
    private var balanceRepository: AnyBalanceRepository
    private let exchangeRatesRepository: AnyExchangeRatesRepository
    
    let timerPublisher: Timer.TimerPublisher
    let cancelBag = CancelBag()
    
    init(
        exchangeRatesRepository: AnyExchangeRatesRepository,
        balanceRepository: AnyBalanceRepository
    ) {
        self.exchangeRatesRepository = exchangeRatesRepository
        self.balanceRepository = balanceRepository
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
            .sinkToLoadable {
                exchangeRatesResponse.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
    
    func exchange(balance: [String: Float], rates: [String: Float], sellAmount: Float, sellCurrency: String, receiveCurrency: String) throws -> ExchangeResult {
        let comissionFee = try calculateComissionFee(
            exchangesCount: balanceRepository.exchangesCount,
            rates: rates,
            sellAmount: sellAmount,
            sellCurrency: sellCurrency)
        let amountCharged = sellAmount + comissionFee
        guard let sellBalance = balance[sellCurrency] else {
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
        let newSellBalance = sellBalance - amountCharged
        let newReceiveBalance = (balance[receiveCurrency] ?? 0) + receiveAmount
        var balance = balance
        balance[sellCurrency] = newSellBalance
        balance[receiveCurrency] = newReceiveBalance
        balanceRepository.incrementExchangesCount()
        return .init(
            balance: balance,
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
