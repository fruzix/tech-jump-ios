//
//  Pokemon.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 15/12/2025.
//

import Foundation
import SwiftData

enum DBModel {}

extension DBModel {
    @Model final class Pokemon {
        var name: String
        var url: String

        init(name: String, url: String) {
            self.name = name
            self.url = url
        }
    }
}

extension ApiModel {
    struct Pokemon: Codable, Equatable {
        let name: String
        let url: String

        init(name: String, url: String) {
            self.name = name
            self.url = url
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<ApiModel.Pokemon.CodingKeys> = try decoder.container(keyedBy: ApiModel.Pokemon.CodingKeys.self)
            self.name = try container.decode(String.self, forKey: ApiModel.Pokemon.CodingKeys.name)
            self.url = try container.decode(String.self, forKey: ApiModel.Pokemon.CodingKeys.url)
        }
    }
}
