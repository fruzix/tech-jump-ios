//
//  PokemonInteractor.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

protocol PokemonInteractor {
    func getPokemonList(offset: Int, limit: Int) async throws -> ApiModel.PokemonList
    func getPokemonDetails(pokemonId: Int) async throws -> ApiModel.PokemonDetails
}

struct RealPokemonInteractor: PokemonInteractor {
    let webRepository: PokemonWebRepository
    let dbRepository: PokemonDBRepository

    func getPokemonList(offset: Int, limit: Int) async throws -> ApiModel.PokemonList {
        let page = try await webRepository.pokemonList(offset: offset, limit: limit)
        try await dbRepository.store(pokemons: page)
        return page
    }

    func getPokemonDetails(pokemonId: Int) async throws -> ApiModel.PokemonDetails {
        let details = try await webRepository.details(pokemonId: pokemonId)
        let species = try await webRepository.species(pokemonId: pokemonId)
        try await dbRepository.store(pokemonDetails: details, pokemonSpecies: species)
        return details
    }
}

struct StubPokemonsInteractor: PokemonInteractor {
    func getPokemonList(offset _: Int, limit _: Int) async throws -> ApiModel.PokemonList {
        .init(count: 0, next: "", previous: nil, results: [])
    }

    func getPokemonDetails(pokemonId _: Int) async throws -> ApiModel.PokemonDetails {
        .init(id: 0, height: 0, weight: 0, baseExperience: 0, types: [""], abilities: [ApiModel.Ability(name: "", isHidden: true)], forms: [""])
    }
}

