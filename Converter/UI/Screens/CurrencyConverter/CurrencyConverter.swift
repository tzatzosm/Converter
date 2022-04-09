//
//  ContentView.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import SwiftUI

struct CurrencyConverter: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            self.content
                .foregroundColor(.black)
                .navigationViewStyle(.stack)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Currency Converter")
                .sheet(isPresented: $viewModel.routingState.sellCurrencySelection) {
                    CurrencySelection(
                        isPresented: $viewModel.routingState.sellCurrencySelection,
                        viewModel: .init(
                            container: viewModel.container,
                            selectedCurrency: $viewModel.sellCurrency))
                }.sheet(isPresented: $viewModel.routingState.receiveCurrencySelection) {
                    CurrencySelection(
                        isPresented: $viewModel.routingState.receiveCurrencySelection,
                        viewModel: .init(
                            container: viewModel.container,
                            selectedCurrency: $viewModel.receiveCurrency))
                }.alert(item: $viewModel.alert) { alert in
                    switch alert {
                    case let .error(message):
                        return Alert(title: Text("An error occurred"), message: Text(message), dismissButton: .cancel(Text("Ok")))
                    case let .success(message):
                        return Alert(title: Text("Currency converted"), message: Text(message), dismissButton: .cancel(Text("Ok")))
                    }
                }
        }
    }
}

extension CurrencyConverter {
    private var content: AnyView {
        switch viewModel.response {
        case .notRequested: return notRequestedView
        case .isLoading: return loadingView
        case let .failed(error): return errorView(error)
        case .loaded: return loadedView
        }
    }
}

extension CurrencyConverter {
    
    var notRequestedView: AnyView {
        AnyView(Text("").onAppear(perform: viewModel.loadExchangeRates))
    }
    
    var loadingView: AnyView {
        AnyView(Text("Loading"))
    }
    
    func errorView(_ error: Error) -> AnyView {
        AnyView(Text(error.localizedDescription))
    }
    
    var loadedView: AnyView {
        return AnyView(VStack {
            balanceView
            currencySelectorView.padding([.bottom])
            submitButton
            Spacer()
        })
    }
    
    var balanceView: AnyView {
        return AnyView(BalancesList(balances: viewModel.balance))
    }
    
    var currencySelectorView: AnyView {
        return AnyView(CurrencyExchangeSelector(
            focusedField: $viewModel.focusedField,
            sellAmount: $viewModel.sellAmount,
            sellCurrencyCode: viewModel.sellCurrency,
            sellCurrencyCodeSelected: $viewModel.routingState.sellCurrencySelection,
            receiveAmount: $viewModel.receiveAmount,
            receiveCurrencyCode: viewModel.receiveCurrency,
            receiveCurrencyCodeSelected: $viewModel.routingState.receiveCurrencySelection))
    }
    
    var isDisabled: Bool {
        return viewModel.sellAmount == nil && viewModel.receiveAmount == nil
    }
    
    var submitButton: some View {
        let backgroundColor: Color = isDisabled ? .cyan.opacity(0.5) : .cyan
        let foregroundColor: Color = isDisabled ? .white.opacity(0.5) : .white
        return Button {
            viewModel.performExchange()
        } label: {
            Text("Submit")
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 4, x: 3, y: 3)
                .padding([.leading, .trailing], 20)
        }.disabled(isDisabled)
    }
}
