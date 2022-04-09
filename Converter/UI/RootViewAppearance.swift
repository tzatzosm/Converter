//
//  RootViewAppearance.swift
//  Converter
//
//  Created by Marsel Tzatzo on 6/4/22.
//

import SwiftUI
import Combine

struct RootViewAppearance: ViewModifier {
    
    @Environment(\.injected) private var injected: DIContainer
    @State private var isActive: Bool = false
    
    func body(content: Content) -> some View {
        content
            .blur(radius: isActive ? 0 : 10)
            .onReceive(stateUpdate) { self.isActive = $0 }
    }
    
    private var stateUpdate: AnyPublisher<Bool, Never> {
        injected.appState.updates(for: \.system.isActive)
    }
}
