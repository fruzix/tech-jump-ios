import SwiftUI

struct PokemonStatGrid: View {
    let details: DBModel.PokemonDBDetails

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            PokemonSummaryCard(title: "Base Experience", value: "\(details.baseExperience)")
            PokemonSummaryCard(title: "Catch Rate", value: "\(details.captureRate)")
            PokemonSummaryCard(title: "Egg Groups", value: "\(details.eggGroups.count)")
            PokemonSummaryCard(title: "Abilities", value: "\(details.abilities.count)")
        }
    }
}
