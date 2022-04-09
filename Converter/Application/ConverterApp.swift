//
//  ConverterApp.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import SwiftUI

@main
struct ConverterApp: App {
    
    let appEnvironment = AppEnvironment.bootstrap()
    
    var body: some Scene {
        WindowGroup {
            CurrencyConverter(viewModel: .init(container: appEnvironment.container))
        }
    }
}

extension ConverterApp {
    class ViewModel: ObservableObject {
        
//        let container: DIContainer
//        let isRunningTests: Bool
        
//        init(container: DIContainer) {
//            self.container = container
//        }
    }
}
