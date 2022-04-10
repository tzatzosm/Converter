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
        var sellCurrencySelection: Bool = false
        var receiveCurrencySelection: Bool = false
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
        
        
        
        // State
        @Published var routingState: Routing
        
        @Published var response: Loadable<ExchangeRatesResponse>
        
        @Published var currencies: [String] = []
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
        private let currencyExchangeService: AnyCurrencyExchangeService
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
            
            let userBalance = appState.map(\.userBalance)
            let rates = appState.map(\.rates)
            
            cancelBag.collect {
                userBalance.zip(rates)
                    .compactMap { [weak self] in self?.makeUserBalance(userBalance: $0.0, rates: $0.1)  }
                    .removeDuplicates()
                    .weakAssign(to: \.balance, on: self)
                $sellAmount
                    .filter { [weak self] _ in self?.focusedField == .sell }
                    .removeDuplicates()
                    .sink { [weak self] value in self?.sellAmountValueDidChange(value) }
                $receiveAmount
                    .filter { [weak self] _ in self?.focusedField == .receive }
                    .removeDuplicates()
                    .sink { [weak self] value in self?.receiveAmountValueDidChange(value) }
                Publishers.Merge($sellCurrency, $receiveCurrency).sink { _ in
                    self.focusedField = nil
                    self.sellAmount = nil
                    self.receiveAmount = nil
                }
            }
        }
    }
}

extension CurrencyConverter.ViewModel {
    func loadExchangeRates() {
        currencyExchangeService
            .pollExchangeRates(
                exchangeRatesResponse: loadableSubject(\.response))
    }
    
    func performExchange() {
        self.focusedField = nil
        do {
            guard let sellAmount = sellAmount else {
                return
            }
            let result = try currencyExchangeService.exchange(
                sellAmount: sellAmount,
                sellCurrency: sellCurrency,
                receiveCurrency: receiveCurrency)
            self.sellAmount = nil
            self.receiveAmount = nil
            alert = .success(makeSuccessMessage(result: result))
        } catch ExchangeError.insufficientFunds {
            alert = .error("This conversion cannot be completed due to insufficient balance.")
        } catch {
            alert = .error("An unexpected error occurred.")
        }
    }
}

private extension CurrencyConverter.ViewModel {
    func makeUserBalance(userBalance: [String: Float], rates: [String: Float]) -> [String] {
        return rates.reduce(into: [String: Float]()) {
            $0[$1.key] = userBalance[$1.key] ?? 0
        }
        .sorted(by: { $0.key < $1.key })
        .sorted(by: { $0.value > $1.value })
        .compactMap {
            guard let currencyValue = self.formatter.string(from: NSNumber(value: $0.value)) else {
                return  nil
            }
            return "\(currencyValue) \($0.key)"
        }
    }
    
    func sellAmountValueDidChange(_ sellAmount: Float?) {
        guard
            let sellAmount = sellAmount,
            let receiveAmount = try? CurrencyExchangeHelpers.calculateExchange(
                forAmount: sellAmount,
                withRates: container.appState.value.rates,
                sellCurrency: sellCurrency,
                receiveCurrency: receiveCurrency) else {
            receiveAmount = nil
            return
        }
        self.receiveAmount = receiveAmount
    }
        
    func receiveAmountValueDidChange(_ receiveAmount: Float?) {
        guard
            let receiveAmount = receiveAmount,
            let sellAmount = try? CurrencyExchangeHelpers.calculateExchange(
                forAmount: receiveAmount,
                withRates: container.appState.value.rates,
                sellCurrency: receiveCurrency,
                receiveCurrency: sellCurrency) else {
            sellAmount = nil
            return
        }
        self.sellAmount = sellAmount
    }
    
    func makeSuccessMessage(result: ExchangeResult) -> String {
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
