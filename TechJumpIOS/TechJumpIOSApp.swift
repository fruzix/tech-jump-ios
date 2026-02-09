//
//  TechJumpIOSApp.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 17/11/2025.
//

import SwiftUI

@main
struct TechJumpIOSApp: App {
    private let environment = AppEnvironment.bootstrap()

    var rootView: some View {
        environment.rootView
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }
}

extension AppEnvironment {
    var rootView: some View {
        VStack {
            PokemonList()
                .modelContainer(modelContainer)
                .inject(diContainer)
            if modelContainer.isStub {
                Text("⚠️ There is an issue with local database")
                    .font(.caption2)
            }
        }
    }
}
