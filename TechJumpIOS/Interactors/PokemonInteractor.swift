//
//  PokemonInteractor.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

protocol PokemonInteractor {
    func getPokemonList(offset: Int, limit: Int) async throws -> ApiModel.PokemonList
}

struct RealPokemonInteractor: PokemonInteractor {
    let webRepository: PokemonWebRepository
    let dbRepository: PokemonDBRepository

    func getPokemonList(offset: Int, limit: Int) async throws -> ApiModel.PokemonList {
        let page = try await webRepository.pokemonList(offset: offset, limit: limit)
        try await dbRepository.store(pokemons: page)
        return page
    }
}

struct StubPokemonsInteractor: PokemonInteractor {
    func getPokemonList(offset _: Int, limit _: Int) async throws -> ApiModel.PokemonList {
        .init(count: 0, next: "", previous: nil, results: [])
    }
}
