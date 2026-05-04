//
//  PokemonDetailsView.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 20/04/2026.
//

import SwiftData
import SwiftUI

struct PokemonDetailsView: View {
    let pokemonID: Int

    @State private var details: DBModel.PokemonDBDetails?
    @State private var viewState: Loadable
    @State private var svgUrl: String?

    @Environment(\.injected) private var injected: DIContainer

    init(pokemonID: Int) {
        self.pokemonID = pokemonID
        self._details = .init(initialValue: nil)
        self._viewState = .init(initialValue: .notRequested)
    }

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .task {
                svgUrl = await injected.interactors.pokemons.getPokemonSVG(pokemonId: pokemonID)
                await loadDetails(forceReload: false)
            }
    }

    @ViewBuilder private var content: some View {
        switch viewState {
        case .notRequested, .isLoading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            if let details {
                loadedView(details: details, svgUrl: svgUrl)
            }
        case let .failed(error):
            ErrorView(error: error) {
                Task {
                    await loadDetails(forceReload: true)
                }
            }
        }
    }
}

private extension PokemonDetailsView {
    func loadedView(details: DBModel.PokemonDBDetails, svgUrl: String?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PokemonHeaderCard(svgURL: svgUrl, pokemonID: pokemonID, details: details)

                PokemonStatGrid(details: details)

                PokemonInfoSection(title: "Types") {
                    PokemonTagWrap(items: details.types, tint: .green)
                }

                PokemonInfoSection(title: "Abilities") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(details.abilities, id: \.persistentModelID) { ability in
                            HStack(alignment: .firstTextBaseline) {
                                Text(displayName(ability.name))
                                    .font(.body.weight(.semibold))

                                Spacer(minLength: 12)

                                if ability.isHidden {
                                    Text("Hidden")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }

                if !details.forms.isEmpty {
                    PokemonInfoSection(title: "Forms") {
                        PokemonTagWrap(items: details.forms, tint: .blue)
                    }
                }

                PokemonInfoSection(title: "Habitat") {
                    PokemonDetailRow(title: "Habitat", value: details.habitat.map(displayName) ?? "Unknown")
                    PokemonDetailRow(title: "Shape", value: details.shape.map(displayName) ?? "Unknown")
                    PokemonDetailRow(title: "Egg Groups", value: details.eggGroups.map(displayName).joined(separator: ", "))
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }

    func loadDetails(forceReload: Bool) async {
        viewState = .isLoading

        guard let fetched = try? await injected.interactors.pokemons.getPokemonDetails(pokemonId: pokemonID, forceReload: forceReload) else {
            return
        }

        details = fetched
        viewState = .loaded
    }

    func displayName(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
}
