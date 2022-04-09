//
//  AppState.swift
//  Converter
//
//  Created by Marsel Tzatzo on 6/4/22.
//

import SwiftUI
import Combine

struct AppState: Equatable {
    var conversionsCount = 0
    var userBalance: [String: Float] = ["EUR": 1000]
    var rates: [String: Float] = [:]
    
    var routing = ViewRouting()
    var system = System()
}

extension AppState {
    struct ViewRouting: Equatable {
        var currencyConverter = CurrencyConverter.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
        var keyboardHeight: CGFloat = 0
    }
}

