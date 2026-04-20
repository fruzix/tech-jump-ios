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

    @MainActor
    func store(pokemonDetails: ApiModel.PokemonDetails, pokemonSpecies: ApiModel.PokemonSpecies) async throws
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

        try modelContext.save()
    }

    func store(pokemonDetails: ApiModel.PokemonDetails, pokemonSpecies: ApiModel.PokemonSpecies) async throws {
        try modelContext.transaction {
            modelContext.insert(pokemonDetails.dbModel(with: pokemonSpecies))
        }

        try modelContext.save()
    }
}

extension ApiModel.Pokemon {
    func dbModel() -> DBModel.Pokemon {
        return .init(name: name, url: url, id: id, svgUrl: svgUrl)
    }
}

extension ApiModel.PokemonDetails {
    func dbModel(with species: ApiModel.PokemonSpecies) -> DBModel.PokemonDBDetails {
        return .init(
            types: types,
            abilities: abilities.map { DBModel.Ability(name: $0.name, isHidden: $0.isHidden) },
            forms: forms,
            height: height,
            weight: weight,
            baseExperience: baseExperience,
            color: species.color,
            captureRate: species.captureRate,
            eggGroups: species.eggGroups,
            shape: species.shape,
            habitat: species.habitat
        )
    }
}
