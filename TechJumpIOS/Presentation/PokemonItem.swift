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
    @Query var svgItems: [DBModel.SVG]
    @Environment(\.injected) private var injected: DIContainer

    init(pokemon: DBModel.Pokemon) {
        self.pokemon = pokemon
        // Query SVGs matching the pokemon's svgUrl
        self._svgItems = Query(filter: #Predicate { $0.url == pokemon.svgUrl })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))

                if let svgData = svgItems.first?.data {
                    RemoteSVGView(svgData: svgData)
                        .padding(18)
                } else {
                    ProgressView()
                        .padding(18)
                }
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
