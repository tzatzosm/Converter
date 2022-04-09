//
//  SectionHeader.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import SwiftUI

struct SectionHeaderView: View {
    @State var headerName: String
    
    var body: some View {
        Text(headerName.uppercased())
            .font(.subheadline.bold())
            .foregroundColor(.gray)
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView(headerName: "My Balances")
    }
}
