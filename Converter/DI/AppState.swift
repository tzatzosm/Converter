//
//  AppState.swift
//  Converter
//
//  Created by Marsel Tzatzo on 6/4/22.
//

import SwiftUI
import Combine

struct AppState: Equatable {
    var userBalance = UserBalance()
    var routing = ViewRouting()
    var system = System()
}

extension AppState {
    struct UserBalance: Equatable {
        var balance: [String: Double] = [:]
    }
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

