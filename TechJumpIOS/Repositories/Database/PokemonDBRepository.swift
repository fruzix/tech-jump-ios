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

        try modelContext.save()
    }
}

extension ApiModel.Pokemon {
    func dbModel() -> DBModel.Pokemon {
        return .init(name: name, url: url, id: id, svgUrl: svgUrl)
    }
}
