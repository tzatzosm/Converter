//
//  CurrencyExchangeView.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import SwiftUI
import Combine

struct CurrencyExchangeInput: View {
    @Binding var currencyCodeSelected: Bool
    @Binding var amount: Float?
    @Binding var focused: Bool
    
    @FocusState private var isTextFieldFocused: Bool
    
    var action: Action
    var currencyCode: String
    
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter
    }()

    @State private var amountText = String() {
        willSet {
            if let amount = Float(newValue) {
                self.$amount.wrappedValue = amount
            } else {
                self.$amount.wrappedValue = nil
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: action.imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(action.color)
                    .frame(width: 40, height: 40)
                
                Text(action.actionName)
                    .padding(4)
                
                Spacer()
                
                // This binding acts as a text change wrapper
                let textBinding = Binding<String>(get: {
                    if isTextFieldFocused {
                        return amountText
                    }
                    guard let amount = amount else {
                        return String()
                    }
                    return numberFormatter.string(from: NSNumber(value: amount)) ?? String()
                }, set: {
                    self.amountText = $0
                })
                
                TextField("Amount", text: textBinding)
                    .focused($isTextFieldFocused)
                    .font(.body.bold())
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 100, alignment: .trailing)
                    .fixedSize(horizontal: true, vertical: false)
                    .keyboardType(.decimalPad)
                
                CurrencyCodeView(
                    currencyCodeSelected: $currencyCodeSelected,
                    currencyCode: currencyCode)
                .frame(width: 80)
            }
            
            Divider()
                .padding([.leading], 52)
                .frame(height: 5.0)
        }.onChange(of: isTextFieldFocused) { newValue in
            focused = newValue
        }.onChange(of: focused) { newValue in
            isTextFieldFocused = newValue
        }
    }
}

extension CurrencyExchangeInput {
    enum Action: Hashable {
        case sell
        case receive
        
        var imageName: String {
            switch self {
            case .sell:
                return "arrow.up.circle.fill"
            case .receive:
                return "arrow.down.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .sell:
                return Color.red
            case .receive:
                return Color.green
            }
        }
        
        var actionName: String {
            switch self {
            case .sell:
                return "Sell"
            case .receive:
                return "Receive"
            }
        }
    }
}

struct CurrencyExchangeInput_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyExchangeInput(
            currencyCodeSelected: .constant(true),
            amount: .constant(10.00),
            focused: .constant(false),
            action: .sell,
            currencyCode: "EUR")
    }
}
