//
//  AppSchema.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

import SwiftData

enum DBModel {}

extension Schema {
    private static var actualVersion: Schema.Version = Version(1, 0, 0)

    static var appSchema: Schema {
        Schema([
            DBModel.Pokemon.self,
            DBModel.PokemonList.self
        ], version: actualVersion)
    }
}
