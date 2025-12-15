//
//  PokemonWebRopository.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 15/12/2025.
//

import Foundation

protocol PokemonWebRepository: WebRepository {
    func pokemonList(offset: Int, limit: Int) async throws -> [ApiModel.PokemonList]
}

struct PokemonDataWebRepository: PokemonWebRepository {
    let session: URLSession
    let baseURL: String

    init(session: URLSession) {
        self.session = session
        self.baseURL = "https://pokeapi.co/api/v2/pokemon"
    }

    func pokemonList(offset: Int = 20, limit: Int = 20) async throws -> [ApiModel.PokemonList] {
        return try await call(endpoint: API.pokemonList(offset: <#T##Int#>, limit: <#T##Int#>))
    }
}

extension PokemonDataWebRepository {
    enum API: APICall {
        case pokemonList(offset: Int, limit: Int)

        var path: String {
            switch self {
            case let .pokemonList(offset, limit):
                return "?offset=\(offset)&limit=\(limit)"
            }
        }

        var method: String { "GET" }
        var headers: [String: String]? {
            ["Accept": "application/json"]
        }

        func body() throws -> Data? { nil }
    }
}
