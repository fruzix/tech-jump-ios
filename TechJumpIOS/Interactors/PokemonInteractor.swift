//
//  PokemonInteractor.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

protocol PokemonInteractor {
    func getPokemonList() async throws
}

struct RealPokemonInteractor: PokemonInteractor {
    let webRepository: PokemonWebRepository
    let dbRepository: PokemonDBRepository

    func getPokemonList() async throws {
        let apiPokemons = try await webRepository.pokemonList(offset: Constants.offset, limit: Constants.limit)
        try await dbRepository.store(pokemons: apiPokemons)
    }

    private enum Constants {
        static let offset: Int = 20
        static let limit: Int = 20
    }
}

struct StubPokemonsInteractor: PokemonInteractor {
    func getPokemonList() async throws {}
}
