import Foundation
import SwiftData

extension ApiModel {
    struct PokemonDetails: Decodable {
        let types: [String]
        let abilities: [Ability]
        let forms: [String]
        let height: Int
        let weight: Int
        let baseExperience: Int

        enum CodingKeys: String, CodingKey {
            case types
            case abilities
            case forms
            case height
            case weight
            case baseExperience = "base_experience"
        }

        init(height: Int, weight: Int, baseExperience: Int, types: [String], abilities: [Ability], forms: [String]) {
            self.height = height
            self.weight = weight
            self.baseExperience = baseExperience
            self.types = types
            self.abilities = abilities
            self.forms = forms
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            height = try container.decode(Int.self, forKey: .height)
            weight = try container.decode(Int.self, forKey: .weight)
            baseExperience = try container.decode(Int.self, forKey: .baseExperience)

            let rawTypes = try container.decode([TypeItem].self, forKey: .types)
            types = rawTypes.map { $0.type.name }

            let rawForms = try container.decode([NamedItem].self, forKey: .forms)
            forms = rawForms.map { $0.name }

            let rawAbilities = try container.decode([AbilityItem].self, forKey: .abilities)
            abilities = rawAbilities.map {
                Ability(name: $0.ability.name, isHidden: $0.isHidden)
            }
        }
    }

    struct Ability: Decodable {
        let name: String
        let isHidden: Bool
    }

    private struct NamedItem: Decodable {
        let name: String
    }

    private struct TypeItem: Decodable {
        let type: NamedItem
    }

    private struct AbilityItem: Decodable {
        let ability: NamedItem
        let isHidden: Bool

        enum CodingKeys: String, CodingKey {
            case ability
            case isHidden = "is_hidden"
        }
    }
}
