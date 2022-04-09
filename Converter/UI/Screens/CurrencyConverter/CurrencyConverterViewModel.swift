//
//  CurrencyConverterViewModel.swift
//  Converter
//
//  Created by Marsel Tzatzo on 6/4/22.
//

import SwiftUI
import Combine

// MARK: - Routing

extension CurrencyConverter {
    struct Routing: Equatable {
        var currencySelection: String?
    }
}

extension CurrencyConverter {
    class ViewModel: ObservableObject {
        enum Alert: Identifiable {
            var id: String {
                switch self {
                case
                    let .error(message),
                    let .success(message):
                    return message
                }
            }
            
            case success(String)
            case error(String)
        }
        
        private let currencyExchangeService: AnyCurrencyExchangeService
        
        // State
        @Published var routingState: Routing
        
        @Published var response: Loadable<ExchangeRatesResponse>
        
        @Published var rates: [String: Float] = [:]
        @Published var currencies: [String] = []
        private var balanceDict: [String: Float] = [:]
        @Published var balance: [String] = []
        
        // Default values for receive currency & sell currency
        @Published var sellCurrency: String = "EUR"
        @Published var receiveCurrency: String = "USD"
        
        @Published var focusedField: CurrencyExchangeSelector.FocusableField?
        @Published var sellAmount: Float?
        @Published var receiveAmount: Float?
        
        @Published var alert: Alert?
        
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter
        }()
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(
            container: DIContainer,
            exchangeRatesResponse: Loadable<ExchangeRatesResponse> = .notRequested
        ) {
            self.container = container
            currencyExchangeService = container.services.currencyExchangeService
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.currencyConverter)
            _response = .init(initialValue: exchangeRatesResponse)
            
            // Only during the first (successful) load we initialize the balance
            $response
                .compactMap { $0.value }
                .first()
                .sink { [weak self] response in self?.initializeValues(response: response) }
                .store(in: cancelBag)
            
            $sellAmount
                .filter { [weak self] _ in self?.focusedField == .sell }
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.sellAmountValueDidChange(value)
                }.store(in: cancelBag)

            $receiveAmount
                .filter { [weak self] _ in self?.focusedField == .receive }
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.receiveAmountValueDidChange(value)
                }.store(in: cancelBag)
        }
        
        // Only during the first load we initialize the balance
        private func initializeValues(response: ExchangeRatesResponse) {
            sellCurrency = response.base
            receiveCurrency = "USD"
            rates = response.rates
            currencies = Array(response.rates.keys.sorted(by: { $0 < $1 }))
            balanceDict = response.rates.reduce(into: [String: Float]()) {
                $0[$1.key] = $1.key == response.base ? 1000.0 : 0.0
            }
            updateBalance()
        }
        
        private func updateBalance() {
            balance = balanceDict
                .sorted(by: { $0.key < $1.key })
                .sorted(by: { $0.value > $1.value })
                .compactMap {
                    guard let currencyValue = self.formatter.string(from: NSNumber(value: $0.value)) else {
                        return  nil
                    }
                    return "\(currencyValue) \($0.key)"
                }
        }
        
        private func sellAmountValueDidChange(_ sellAmount: Float?) {
            guard
                let sellAmount = sellAmount,
                let receiveAmount = try? CurrencyExchangeHelpers.calculateExchange(
                    forAmount: sellAmount,
                    withRates: rates,
                    sellCurrency: sellCurrency,
                    receiveCurrency: receiveCurrency) else {
                receiveAmount = nil
                return
            }
            self.receiveAmount = receiveAmount
        }
            
        private func receiveAmountValueDidChange(_ receiveAmount: Float?) {
            guard
                let receiveAmount = receiveAmount,
                let sellAmount = try? CurrencyExchangeHelpers.calculateExchange(
                    forAmount: receiveAmount,
                    withRates: rates,
                    sellCurrency: receiveCurrency,
                    receiveCurrency: sellCurrency) else {
                sellAmount = nil
                return
            }
            self.sellAmount = sellAmount
        }
        
        func loadExchangeRates() {
            currencyExchangeService
                .pollExchangeRates(
                    exchangeRatesResponse: loadableSubject(\.response))
        }
        
        func setSelectedSellCurrency(currencyCode: String) {
            
        }
        
        func setSelectedReceiveCurrency(currencyCode: String) {
            
        }
        
        func performExchange() {
            self.focusedField = nil
            do {
                guard let sellAmount = sellAmount else {
                    return
                }
                let result = try currencyExchangeService.exchange(
                    balance: balanceDict,
                    rates: rates,
                    sellAmount: sellAmount,
                    sellCurrency: sellCurrency,
                    receiveCurrency: receiveCurrency)
                balanceDict = result.balance
                updateBalance()
                self.sellAmount = nil
                self.receiveAmount = nil
                alert = .success(buildMessage(result: result))
            } catch ExchangeError.insufficientFunds {
                alert = .error("This conversion cannot be completed due to insufficient balance.")
            } catch {
                alert = .error("An unexpected error occurred.")
            }
        }
        
        private func buildMessage(result: ExchangeResult) -> String {
            guard
                let sellAmount = formatter.string(from: NSNumber(value: result.sellAmount)),
                let receiveAmount = formatter.string(from: NSNumber(value: result.receiveAmount)) else {
                return String()
            }
            var message = "You have converted \(sellAmount) \(result.sellCurrency) to \(receiveAmount) \(result.receiveCurrency)."
            if result.comissionFee > 0 {
                if let commissionFee = formatter.string(from: NSNumber(value: result.comissionFee)) {
                    message = "\(message) Commission Fee - \(commissionFee) \(result.sellCurrency)"
                }
            }
            return message
        }
    }
}
