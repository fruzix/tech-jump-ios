//
//  Pokemon.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 15/12/2025.
//

import Foundation
import SwiftData

extension DBModel {
    @Model final class Pokemon {
        var name: String
        var url: String
        var svgUrl: String
        var id: Int

        init(name: String, url: String, id: Int, svgUrl: String) {
            self.name = name
            self.url = url
            self.svgUrl = svgUrl
            self.id = id
        }
    }
}

extension ApiModel {
    struct Pokemon: Codable, Equatable {
        let name: String
        let url: String
        let id: Int
        var svgUrl: String

        init(name: String, url: String, id: Int, svgUrl: String) {
            self.name = name
            self.url = url
            self.id = id
            self.svgUrl = svgUrl
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<ApiModel.Pokemon.CodingKeys> = try decoder.container(keyedBy: ApiModel.Pokemon.CodingKeys.self)
            self.name = try container.decode(String.self, forKey: ApiModel.Pokemon.CodingKeys.name)
            self.url = try container.decode(String.self, forKey: ApiModel.Pokemon.CodingKeys.url)

            guard
                let url = URL(string: url),
                let idString = url.pathComponents.last(where: { !$0.isEmpty }),
                let id = Int(idString)

            else {
                throw DecodingError.dataCorruptedError(
                    forKey: .url,
                    in: container,
                    debugDescription: "Invalid Pokémon URL: \(self.url)"
                )
            }

            self.id = id
            self.svgUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/\(self.id).svg"
        }
    }
}
