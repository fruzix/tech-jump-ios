import SwiftUI

struct PokemonInfoSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.secondarySystemBackground))
                )
        }
    }
}
