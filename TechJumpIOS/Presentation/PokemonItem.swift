//
//  PokemonItem.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 23/01/2026.
//

import SwiftData
import SwiftSVG
import SwiftUI

struct PokemonItem: View {
    let pokemon: DBModel.Pokemon

    @Environment(\.injected) private var injected: DIContainer

    @Query private var cached: [DBModel.CachedSVG]

    init(pokemon: DBModel.Pokemon) {
        self.pokemon = pokemon

        let pokemonId = pokemon.id
        _cached = Query(filter: #Predicate<DBModel.CachedSVG> { $0.id == pokemonId })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6))
                svgThumb
                    .padding(18)
            }.frame(height: 180)

            Text(pokemon.name.capitalized).font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .task(id: pokemon.id) {
            guard cached.first == nil else { return }

            do {
                try await injected.interactors.pokemonSVG.getPokemonSVG(id: String(pokemon.id))
            } catch {}
        }
    }

    @ViewBuilder
    private var svgThumb: some View {
        if let svg = cached.first {
            SwiftSVGView(svgData: svg.data).frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ProgressView()
        }
    }
}
