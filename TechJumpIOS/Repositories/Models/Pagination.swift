//
//  Pagination.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 15/12/2025.
//

import Foundation
import SwiftData

extension DBModel {
    @Model final class PokemonList {
        var count: Int
        var next: String
        var previous: String?
        var results: [Pokemon] = []

        init(count: Int, next: String, previous: String? = nil, results: [Pokemon]) {
            self.count = count
            self.next = next
            self.previous = previous
            self.results = results
        }
    }
}

extension ApiModel {
    struct PokemonList: Codable, Equatable {
        let count: Int
        let next: String
        let previous: String?
        let results: [Pokemon]

        init(count: Int, next: String, previous: String?, results: [Pokemon]) {
            self.count = count
            self.next = next
            self.previous = previous
            self.results = results
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<ApiModel.PokemonList.CodingKeys> = try decoder.container(keyedBy: ApiModel.PokemonList.CodingKeys.self)
            self.count = try container.decode(Int.self, forKey: ApiModel.PokemonList.CodingKeys.count)
            self.next = try container.decode(String.self, forKey: ApiModel.PokemonList.CodingKeys.next)
            self.previous = try container.decodeIfPresent(String.self, forKey: ApiModel.PokemonList.CodingKeys.previous)
            self.results = try container.decode([ApiModel.Pokemon].self, forKey: ApiModel.PokemonList.CodingKeys.results)
        }
    }
}
