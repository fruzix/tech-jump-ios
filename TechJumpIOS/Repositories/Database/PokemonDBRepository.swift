//
//  PokemonDBRepository.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

import Foundation
import SwiftData

protocol PokemonDBRepository {
    @MainActor
    func store(pokemons: ApiModel.PokemonList) async throws
}

extension MainDBRepository: PokemonDBRepository {
    func store(pokemons: ApiModel.PokemonList) async throws {
        try modelContext.transaction {
            pokemons.results
                .map { $0.dbModel() }
                .forEach {
                    modelContext.insert($0)
                }
        }

        // Force persistence
        try modelContext.save()

        // Debug proof:
        // Fetch first saved Pokemon
        var descriptor = FetchDescriptor<DBModel.Pokemon>()
        descriptor.fetchLimit = 1
        let result = try modelContext.fetch(descriptor)

        if let first = result.first {
            print("✅ First saved pokemon:")
            print("Name:", first.name)
            print("URL:", first.url)
        } else {
            print("❌ No pokemons found in DB")
        }
    }
}

extension ApiModel.Pokemon {
    func dbModel() -> DBModel.Pokemon {
        return .init(name: name, url: url)
    }
}
