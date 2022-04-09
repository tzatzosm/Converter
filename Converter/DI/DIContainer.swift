//
//  DIContainer.swift
//  Converter
//
//  Created by Marsel Tzatzo on 5/4/22.
//

import SwiftUI
import Combine

// MARK: - DIContainer

struct DIContainer: EnvironmentKey {
    
    let appState: Store<AppState>
    let services: Services
    
    init(appState: Store<AppState>, services: Services) {
        self.appState = appState
        self.services = services
    }
    
    init(appState: AppState, services: Services) {
        self.init(appState: Store<AppState>(appState), services: services)
    }
    
    static var defaultValue: Self { Self.default }
    
    private static let `default` = Self(appState: AppState(), services: .stub)
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

// MARK: - Injection in the view hierarchy

extension View {
    
    func inject(_ appState: AppState, _ services: DIContainer.Services) -> some View {
        let container = DIContainer(appState: appState, services: services)
        return inject(container)
    }
    
    func inject(_ container: DIContainer) -> some View {
        return self
            .modifier(RootViewAppearance())
            .environment(\.injected, container)
    }
}


