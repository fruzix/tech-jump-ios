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

    init(pokemon: DBModel.Pokemon) {
        self.pokemon = pokemon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))

                SVGView(svgURL: pokemon.svgUrl)
            }
            .frame(height: 120)

            Text(pokemon.name.capitalized)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.leading, 4)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .background(Color(.systemGray5))
        .cornerRadius(18)
    }
}
