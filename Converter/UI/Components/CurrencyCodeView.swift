//
//  CurrencyCodeView.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import SwiftUI

struct CurrencyCodeView: View {
    @Binding var currencyCodeSelected: Bool
    var currencyCode: String
    
    var body: some View {
        Button {
            currencyCodeSelected.toggle()
        } label: {
            HStack {
                Text(currencyCode).bold()
                Image(systemName: "chevron.down")
            }
        }
    }
}

#if DEBUG
struct CurrencyCodeView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyCodeView(
            currencyCodeSelected: .constant(true),
            currencyCode: "EUR")
    }
}
#endif
