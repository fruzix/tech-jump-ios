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
    @State private var nextOffset = 0
    @State private var hasMorePages = true
    @State private var isLoadingNextPage = false

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
        .ignoresSafeArea(edges: .bottom)
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
    enum Constants {
        static let pageSize = 20
        static let preloadThreshold = 4
    }

    func defaultView() -> some View {
        Text("").onAppear {
            if !pokemons.isEmpty {
                nextOffset = pokemons.count
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
                ForEach(Array(pokemons.enumerated()), id: \.element.id) { index, pokemon in
                    PokemonItem(pokemon: pokemon)
                        .onAppear {
                            loadNextPageIfNeeded(currentIndex: index)
                        }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            if isLoadingNextPage {
                loadingNextPageView()
            }
        }
    }

    func loadingNextPageView() -> some View {
        HStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(.circular)

            Text("Loading more pokemons...")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

// MARK: - Side Effects

private extension PokemonList {
    private func loadPokemonList(forceReload: Bool) {
        guard !isLoadingNextPage else { return }

        if forceReload {
            hasMorePages = true
            nextOffset = pokemons.count
        }

        guard forceReload || pokemons.isEmpty else { return }

        isLoadingNextPage = true
        pokemonsState.setIsLoading(cancelBag: CancelBag())

        Task {
            do {
                let page = try await injected.interactors.pokemons.getPokemonList(
                    offset: nextOffset,
                    limit: Constants.pageSize
                )

                await MainActor.run {
                    nextOffset += page.results.count
                    hasMorePages = !page.next.isEmpty
                    isLoadingNextPage = false
                    pokemonsState = .loaded(())
                }
            } catch {
                await MainActor.run {
                    isLoadingNextPage = false
                    pokemonsState = .failed(error)
                }
            }
        }
    }

    private func loadNextPageIfNeeded(currentIndex: Int) {
        let thresholdIndex = max(pokemons.count - Constants.preloadThreshold, 0)
        guard currentIndex >= thresholdIndex else { return }
        guard hasMorePages else { return }
        guard !isLoadingNextPage else { return }
        guard case .loaded = pokemonsState else { return }

        isLoadingNextPage = true

        Task {
            do {
                let page = try await injected.interactors.pokemons.getPokemonList(
                    offset: nextOffset,
                    limit: Constants.pageSize
                )
                await MainActor.run {
                    nextOffset += page.results.count
                    hasMorePages = !page.next.isEmpty
                    isLoadingNextPage = false
                }
            } catch {
                await MainActor.run {
                    isLoadingNextPage = false
                }
            }
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
