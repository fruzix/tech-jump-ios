//
//  PokemonSpecie.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 10/04/2026.
//

import Foundation
import SwiftData

extension ApiModel {
    struct PokemonSpecies: Decodable {
        let color: String
        let captureRate: Int
        let eggGroups: [String]
        let shape: String?
        let habitat: String?

        enum CodingKeys: String, CodingKey {
            case color
            case captureRate = "capture_rate"
            case eggGroups = "egg_groups"
            case shape
            case habitat
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            color = try container.decode(NamedItem.self, forKey: .color).name
            captureRate = try container.decode(Int.self, forKey: .captureRate)
            eggGroups = try container.decode([NamedItem].self, forKey: .eggGroups).map(\.name)
            shape = try container.decodeIfPresent(NamedItem.self, forKey: .shape)?.name
            habitat = try container.decodeIfPresent(NamedItem.self, forKey: .habitat)?.name
        }
    }

    private struct NamedItem: Decodable {
        let name: String
    }
}
