import SwiftUI

struct PokemonTagWrap: View {
    let items: [String]
    let tint: Color

    var body: some View {
        FlexibleTagLayout(data: items, spacing: 10) { item in
            Text(displayName(item))
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(tint.opacity(0.16))
                .foregroundStyle(tint)
                .clipShape(Capsule())
        }
    }

    private func displayName(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
}
