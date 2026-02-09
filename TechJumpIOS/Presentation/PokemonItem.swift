//
//  PokemonItem.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 23/01/2026.
//

import SwiftUI

struct PokemonItem: View {
    let pokemon: DBModel.Pokemon

    var body: some View {
        VStack(alignment: .leading) {
            Text(pokemon.url)
                .font(.title)
            Text("Name \(pokemon.name)")
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
    }
}
