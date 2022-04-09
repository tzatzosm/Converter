//
//  CurrencySelectionViewModel.swift
//  Converter
//
//  Created by Marsel Tzatzo on 9/4/22.
//

import SwiftUI

extension CurrencySelection {
    class ViewModel: ObservableObject {
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        @Published var selectedCurrency: String
        @Published var currencies: [String] = []
        
        init(container: DIContainer, selectedCurrency: Binding<String>) {
            self.container = container
            self.selectedCurrency = selectedCurrency.wrappedValue
            
            let appState = container.appState
            
            $selectedCurrency
                .dropFirst() // Drop first assignment here, done on line 20. Doesn't seem like the best way to do this.
                .sink { selectedCurrency.wrappedValue = $0 }
                .store(in: cancelBag)
            
            appState
                .map(\.rates)
                .map { $0.map { $0.key }.sorted(by: { $0 < $1 }) }
                .weakAssign(to: \.currencies, on: self)
                .store(in: cancelBag)
            
            
        }
    }
}
