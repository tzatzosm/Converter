//
//  CurrencySelection.swift
//  Converter
//
//  Created by Marsel Tzatzo on 6/4/22.
//

import SwiftUI

struct CurrencySelection: View {
    @Binding var isPresented: Bool
    @Binding var selectedCurrency: String
    @State var currencies: [String]
    
    var body: some View {
        List {
            ForEach(currencies, id: \.self) { currency in
                let tint: Color = currency == selectedCurrency ? .red : .black
                Button {
                    _selectedCurrency.wrappedValue = currency
                    isPresented = false
                } label: {
                    Text(currency)
                }.tint(tint)
            }
        }
    }
}

struct CurrencySelection_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySelection(
            isPresented: .constant(true),
            selectedCurrency: .constant("EUR"),
            currencies: ["EUR", "USD"])
    }
}
