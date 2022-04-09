//
//  CurrencyExchangeSelector.swift
//  Converter
//
//  Created by Marsel Tzatzo on 6/4/22.
//

import SwiftUI

struct CurrencyExchangeSelector: View {
    @Binding var focusedField: FocusableField?
    
    @Binding var sellAmount: Float?
    var sellCurrencyCode: String
    @Binding var sellCurrencyCodeSelected: Bool
    @State private var sellFocused: Bool = false
    
    @Binding var receiveAmount: Float?
    var receiveCurrencyCode: String
    @Binding var receiveCurrencyCodeSelected: Bool
    @State private var receiveFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(headerName: "Currency Exchange")
                .padding()
            
            CurrencyExchangeInput(
                currencyCodeSelected: $sellCurrencyCodeSelected,
                amount: $sellAmount,
                focused: $sellFocused,
                action: .sell,
                currencyCode: sellCurrencyCode)
            .padding([.leading, .trailing])
            
            CurrencyExchangeInput(
                currencyCodeSelected: $receiveCurrencyCodeSelected,
                amount: $receiveAmount,
                focused: $receiveFocused,
                action: .receive,
                currencyCode: receiveCurrencyCode)
            .padding([.leading, .trailing])
        }
        .onChange(of: sellFocused) {
            if $0 {
                print("sell")
                focusedField = .sell
            }
        }
        .onChange(of: receiveFocused) {
            if $0 {
                print("receive")
                focusedField = .receive
            }
        }
        .onChange(of: focusedField) {
            if $0 == nil {
                sellFocused = false
                receiveFocused = false
            }
        }.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Hide") {
                    focusedField = nil
                }
            }
        }
    }
}

extension CurrencyExchangeSelector {
    enum FocusableField: Hashable {
        case sell
        case receive
    }
}

struct CurrencyExchangeSelector_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyExchangeSelector(
            focusedField: .constant(nil),
            sellAmount: .constant(100.00),
            sellCurrencyCode: "EUR",
            sellCurrencyCodeSelected: .constant(true),
            receiveAmount: .constant(110.00),
            receiveCurrencyCode: "UST",
            receiveCurrencyCodeSelected: .constant(true))
    }
}
