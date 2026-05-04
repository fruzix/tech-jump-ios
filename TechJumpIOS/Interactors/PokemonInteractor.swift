//
//  PokemonInteractor.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

protocol PokemonInteractor {
    func getPokemonList(offset: Int, limit: Int) async throws -> ApiModel.PokemonList
    func getPokemonDetails(pokemonId: Int, forceReload: Bool) async throws -> DBModel.PokemonDBDetails
    func getPokemonSVG(pokemonId: Int) async -> String?
}

struct RealPokemonInteractor: PokemonInteractor {
    let webRepository: PokemonWebRepository
    let dbRepository: PokemonDBRepository

    func getPokemonList(offset: Int, limit: Int) async throws -> ApiModel.PokemonList {
        let page = try await webRepository.pokemonList(offset: offset, limit: limit)
        try await dbRepository.store(pokemons: page)
        return page
    }

    func getPokemonDetails(
        pokemonId: Int, forceReload: Bool
    ) async throws -> DBModel.PokemonDBDetails {
        if !forceReload,
           let stored = try? await dbRepository.pokemonDetails(pokemonId: pokemonId)
        {
            return stored
        }
        async let details = webRepository.details(pokemonId: pokemonId)
        async let species = webRepository.species(pokemonId: pokemonId)
        let (d, s) = try await (details, species)

        try await dbRepository.store(pokemonDetails: d, pokemonSpecies: s)
        guard let stored = try? await dbRepository.pokemonDetails(pokemonId: pokemonId) else {
            throw ValueIsMissingError()
        }
        return stored
    }

    func getPokemonSVG(pokemonId: Int) async -> String? {
        return try? await dbRepository.pokemon(pokemonId: pokemonId)?.svgUrl
    }
}

struct StubPokemonsInteractor: PokemonInteractor {
    func getPokemonSVG(pokemonId _: Int) async -> String? { nil }

    func getPokemonList(offset _: Int, limit _: Int) async throws -> ApiModel.PokemonList {
        .init(count: 0, next: "", previous: nil, results: [])
    }

    func getPokemonDetails(pokemonId _: Int, forceReload _: Bool) async throws -> DBModel.PokemonDBDetails {
        .init(pokemonId: 0, types: [""], abilities: [DBModel.Ability(name: "", isHidden: true)], forms: [""], height: 0, weight: 0, baseExperience: 0, color: "blue", captureRate: 0, eggGroups: [""], shape: nil, habitat: nil)
    }
}
