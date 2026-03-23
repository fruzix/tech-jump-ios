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
        let pokemons: PokemonDataWebRepository
        let svg: SVGDataWebRepository
    }

    struct DBRepositories {
        let pokemons: MainDBRepository
        let svg: MainDBRepository
    }

    struct Interactors {
        let pokemons: PokemonInteractor
        let svg: SVGInteractor

        init(webRepositories: WebRepositories, dbRepositories: DBRepositories) {
            let svg = SVGInteractor(
                webRepository: webRepositories.svg,
                dbRepository: dbRepositories.svg
            )
            self.svg = svg
            self.pokemons = PokemonInteractor(
                webRepository: webRepositories.pokemons,
                dbRepository: dbRepositories.pokemons,
                svgInteractor: svg
            )
        }

        init(pokemons: PokemonInteractor, svg: SVGInteractor) {
            self.pokemons = pokemons
            self.svg = svg
        }

        static var stub: Self {
            .init(
                pokemons: .stub,
                svg: .stub
            )
        }
    }
}

extension EnvironmentValues {
    @Entry var injected: DIContainer = .init(appState: AppState(), interactors: .stub)
}

extension View {
    func inject(_ container: DIContainer) -> some View {
        return self
            .environment(\.injected, container)
    }
}
