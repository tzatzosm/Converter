//
//  MyBalancesList.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import SwiftUI

struct BalancesList: View {
    var balances: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(headerName: "My Balances")
                .padding()
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    ForEach(balances, id: \.self) {
                        BalanceView(balance: $0)
                        Spacer(minLength: 30)
                    }
                }
                .padding([.leading, .trailing, .bottom])
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

struct BalancesList_Previews: PreviewProvider {
    static var previews: some View {
        BalancesList(balances: ["1000.00 EUR", "0.00 $", "0.00 ALL", "0.00 ALL", "0.00 ALL", "0.00 ALL"])
    }
}
