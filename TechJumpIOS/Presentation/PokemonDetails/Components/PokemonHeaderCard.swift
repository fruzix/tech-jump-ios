import SwiftUI

struct PokemonHeaderCard: View {
    let pokemon: DBModel.Pokemon
    let details: DBModel.PokemonDBDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color(for: details.color).opacity(0.18))

                    SVGView(svgURL: pokemon.svgUrl, pokemonId: pokemon.id)
                        .padding(18)
                }
                .frame(width: 136, height: 136)

                VStack(alignment: .leading, spacing: 8) {
                    Text(pokemon.name.capitalized)
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    Text(String(format: "#%04d", pokemon.id))
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Label(displayName(details.color), systemImage: "paintpalette.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(color(for: details.color))
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 12) {
                PokemonMetricPill(title: "Height", value: heightText(details.height))
                PokemonMetricPill(title: "Weight", value: weightText(details.weight))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func color(for name: String) -> Color {
        switch name.lowercased() {
        case "black": .black
        case "blue": .blue
        case "brown": .brown
        case "gray": .gray
        case "green": .green
        case "pink": .pink
        case "purple": .indigo
        case "red": .red
        case "white": .white
        case "yellow": .yellow
        default: .mint
        }
    }

    private func displayName(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }

    private func heightText(_ decimeters: Int) -> String {
        String(format: "%.1f m", Double(decimeters) / 10)
    }

    private func weightText(_ hectograms: Int) -> String {
        String(format: "%.1f kg", Double(hectograms) / 10)
    }
}
