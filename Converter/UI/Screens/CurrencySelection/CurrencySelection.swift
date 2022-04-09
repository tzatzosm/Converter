//
//  CurrencySelection.swift
//  Converter
//
//  Created by Marsel Tzatzo on 6/4/22.
//

import SwiftUI

struct CurrencySelection: View {
    @Binding var isPresented: Bool
    @ObservedObject private(set) var viewModel: ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.currencies, id: \.self) { currency in
                let tint: Color = currency == viewModel.selectedCurrency ? .red : .black
                Button {
                    viewModel.selectedCurrency = currency
                    isPresented = false
                } label: {
                    Text(currency)
                }
                .tint(tint)
            }
        }
    }
}

struct CurrencySelection_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySelection(
            isPresented: .constant(true),
            viewModel: .init(container: .defaultValue, selectedCurrency: .constant("EUR")))
    }
}
