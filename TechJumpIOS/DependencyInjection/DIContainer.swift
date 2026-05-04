//
//  DIContainer.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

import SwiftData
import SwiftUI

struct DIContainer {
    let appState: Store<AppState>
    let interactors: Interactors

    init(appState: Store<AppState> = .init(AppState()), interactors: Interactors) {
        self.appState = appState
        self.interactors = interactors
    }

    init(appState: AppState, interactors: Interactors) {
        self.init(appState: Store<AppState>(appState), interactors: interactors)
    }
}

extension DIContainer {
    struct WebRepositories {
        let pokemons: PokemonWebRepository
        let svg: SVGWebRepository
    }

    struct DBRepositories {
        let pokemons: PokemonDBRepository
        let svg: SVGDBRepository
    }

    struct Interactors {
        let svg: SVGInteractor
        let pokemons: PokemonInteractor

        static var stub: Self {
            .init(svg: StubSVGInteractor(),
                  pokemons: StubPokemonsInteractor())
        }
    }
}

extension EnvironmentValues {
    @Entry var injected: DIContainer = .init(appState: AppState(), interactors: .stub)
}

extension View {
    func inject(_ container: DIContainer) -> some View {
        return environment(\.injected, container)
    }
}
