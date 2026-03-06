//
//  PokemonList.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

import Combine
import SwiftData
import SwiftUI

struct PokemonList: View {
    @Query(sort: \DBModel.Pokemon.name) private var pokemons: [DBModel.Pokemon]
    @State private(set) var pokemonsState: Loadable<Void>

    @State var navigationPath = NavigationPath()
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.pokemonList)
    }

    private var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.pokemonList)
    }

    @Environment(\.injected) private var injected: DIContainer

    init(state: Loadable<Void> = .notRequested) {
        self._pokemonsState = .init(initialValue: state)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .onReceive(routingUpdate) { self.routingState = $0 }
                .navigationTitle("Pokemons")
        }
    }

    @ViewBuilder private var content: some View {
        switch pokemonsState {
        case .notRequested:
            defaultView()
        case .isLoading:
            loadingView()
        case .loaded:
            loadedView()
        case .failed(let error):
            failedView(error)
        }
    }
}

// MARK: - Loading Content

private extension PokemonList {
    func defaultView() -> some View {
        Text("").onAppear {
            if !pokemons.isEmpty {
                pokemonsState = .loaded(())
            }
            loadPokemonList(forceReload: false)
        }
    }

    func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            loadPokemonList(forceReload: true)
        })
    }
}

// MARK: - Displaying Content

@MainActor
private extension PokemonList {
    @ViewBuilder
    func loadedView() -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(pokemons, id: \.id) { pokemon in
                    PokemonItem(pokemon: pokemon)
                }
            }.padding(14)
        }
    }
}

// MARK: - Side Effects

private extension PokemonList {
    private func loadPokemonList(forceReload: Bool) {
        guard forceReload || pokemons.isEmpty else { return }
        $pokemonsState.load {
            try await injected.interactors.pokemons.getPokemonList()
        }
    }
}

// MARK: - Routing

extension PokemonList {
    struct Routing: Equatable {}
}

#Preview {
    PokemonList()
}
