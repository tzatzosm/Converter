//
//  BalanceView.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import SwiftUI

struct BalanceView: View {
    @State var balance: String
    
    var body: some View {
        HStack {
            Text(balance).font(.headline)
        }
    }
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceView(balance: "1000.00 EUR")
    }
}
