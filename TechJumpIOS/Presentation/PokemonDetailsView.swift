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

	@Query private var pokemons: [DBModel.Pokemon]
	@Query private var details: [DBModel.PokemonDBDetails]
	@State private var detailsState: Loadable<Void> = .notRequested

	@Environment(\.injected) private var injected: DIContainer

	init(pokemonID: Int) {
		self.pokemonID = pokemonID
		_pokemons = Query(filter: #Predicate<DBModel.Pokemon> { pokemon in
			pokemon.id == pokemonID
		})
		_details = Query(filter: #Predicate<DBModel.PokemonDBDetails> { details in
			details.pokemonId == pokemonID
		})
	}

	private var pokemon: DBModel.Pokemon? {
		pokemons.first
	}

	private var pokemonDetails: DBModel.PokemonDBDetails? {
		details.first
	}

	var body: some View {
		Group {
			if let pokemon, let pokemonDetails {
				loadedView(pokemon: pokemon, details: pokemonDetails)
			} else {
				placeholderView
			}
		}
		.navigationTitle(pokemon?.name.capitalized ?? "Pokemon")
		.navigationBarTitleDisplayMode(.inline)
		.task {
			await loadDetailsIfNeeded()
		}
	}
}

private extension PokemonDetailsView {
	@ViewBuilder
	var placeholderView: some View {
		switch detailsState {
		case .failed(let error):
			ErrorView(error: error) {
				Task {
					await loadDetails(forceReload: true)
				}
			}
		case .isLoading, .notRequested:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}

	func loadedView(pokemon: DBModel.Pokemon, details: DBModel.PokemonDBDetails) -> some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				headerCard(pokemon: pokemon, details: details)

				statGrid(details: details)

				infoSection(title: "Types") {
					tagWrap(items: details.types, tint: .green)
				}

				infoSection(title: "Abilities") {
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
					infoSection(title: "Forms") {
						tagWrap(items: details.forms, tint: .blue)
					}
				}

				infoSection(title: "Habitat") {
					detailRow(title: "Habitat", value: details.habitat.map(displayName) ?? "Unknown")
					detailRow(title: "Shape", value: details.shape.map(displayName) ?? "Unknown")
					detailRow(title: "Egg Groups", value: details.eggGroups.map(displayName).joined(separator: ", "))
				}
			}
			.padding(16)
		}
		.background(Color(.systemGroupedBackground))
	}

	func headerCard(pokemon: DBModel.Pokemon, details: DBModel.PokemonDBDetails) -> some View {
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
				metricPill(title: "Height", value: heightText(details.height))
				metricPill(title: "Weight", value: weightText(details.weight))
			}
		}
		.padding(18)
		.background(
			RoundedRectangle(cornerRadius: 24)
				.fill(Color(.secondarySystemBackground))
		)
	}

	func statGrid(details: DBModel.PokemonDBDetails) -> some View {
		LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
			summaryCard(title: "Base Experience", value: "\(details.baseExperience)")
			summaryCard(title: "Catch Rate", value: "\(details.captureRate)")
			summaryCard(title: "Egg Groups", value: "\(details.eggGroups.count)")
			summaryCard(title: "Abilities", value: "\(details.abilities.count)")
		}
	}

	func summaryCard(title: String, value: String) -> some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.caption)
				.foregroundStyle(.secondary)

			Text(value)
				.font(.title3.weight(.bold))
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(16)
		.background(
			RoundedRectangle(cornerRadius: 18)
				.fill(Color(.secondarySystemBackground))
		)
	}

	func infoSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(title)
				.font(.headline)

			content()
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(16)
				.background(
					RoundedRectangle(cornerRadius: 18)
						.fill(Color(.secondarySystemBackground))
				)
		}
	}

	func tagWrap(items: [String], tint: Color) -> some View {
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

	func detailRow(title: String, value: String) -> some View {
		HStack(alignment: .top) {
			Text(title)
				.foregroundStyle(.secondary)

			Spacer(minLength: 16)

			Text(value)
				.multilineTextAlignment(.trailing)
		}
	}

	func metricPill(title: String, value: String) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(title)
				.font(.caption)
				.foregroundStyle(.secondary)

			Text(value)
				.font(.headline.weight(.semibold))
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(12)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}

	func loadDetailsIfNeeded() async {
		guard pokemonDetails == nil else {
			detailsState = .loaded(())
			return
		}

		await loadDetails(forceReload: false)
	}

	func loadDetails(forceReload: Bool) async {
		guard forceReload || pokemonDetails == nil else { return }

		detailsState.setIsLoading(cancelBag: CancelBag())

		do {
			_ = try await injected.interactors.pokemons.getPokemonDetails(pokemonId: pokemonID)
			await MainActor.run {
				detailsState = .loaded(())
			}
		} catch {
			await MainActor.run {
				detailsState = .failed(error)
			}
		}
	}

	func color(for name: String) -> Color {
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

	func displayName(_ value: String) -> String {
		value
			.replacingOccurrences(of: "-", with: " ")
			.capitalized
	}

	func heightText(_ decimeters: Int) -> String {
		String(format: "%.1f m", Double(decimeters) / 10)
	}

	func weightText(_ hectograms: Int) -> String {
		String(format: "%.1f kg", Double(hectograms) / 10)
	}
}

