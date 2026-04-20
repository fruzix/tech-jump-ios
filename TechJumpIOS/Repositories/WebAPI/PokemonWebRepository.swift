//
//  PokemonWebRopository.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 15/12/2025.
//

import Foundation

protocol PokemonWebRepository: WebRepository {
    func pokemonList(offset: Int, limit: Int) async throws -> ApiModel.PokemonList
    func details(pokemonId: Int) async throws -> ApiModel.PokemonDetails
    func species(pokemonId: Int) async throws -> ApiModel.PokemonSpecies
}

struct PokemonDataWebRepository: PokemonWebRepository {
    let session: URLSession
    let baseURL: String

    init(session: URLSession) {
        self.session = session
        self.baseURL = "https://pokeapi.co/api/v2/pokemon"
    }

    func pokemonList(offset: Int, limit: Int) async throws -> ApiModel.PokemonList {
        return try await call(endpoint: API.pokemonList(offset: offset, limit: limit))
    }

    func details(pokemonId: Int) async throws -> ApiModel.PokemonDetails {
        return try await call(endpoint: API.details(pokemonId: pokemonId))
    }
    
    func species(pokemonId: Int) async throws -> ApiModel.PokemonSpecies {
        return try await call(endpoint: API.species(pokemonId: pokemonId))
    }
}

extension PokemonDataWebRepository {
    enum API: APICall {
        case pokemonList(offset: Int, limit: Int)
        case details(pokemonId: Int)
        case species(pokemonId: Int)

        var path: String {
            switch self {
            case let .pokemonList(offset: offset, limit: limit):
                return "?offset=\(offset)&limit=\(limit)"
            case let .details(pokemonId: pokemonId):
                return "/\(pokemonId)"
            case let .species(pokemonId: pokemonId):
                return "-species/\(pokemonId)"
            }
        }

        var method: String { "GET" }
        var headers: [String: String]? {
            ["Accept": "application/json"]
        }

        func body() throws -> Data? { nil }
    }
}
