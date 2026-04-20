//
//  PokemonDBDetails.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 10/04/2026.
//  It is a a merge of two models: PokemonDBDetails and PokemonDBAbility, which were previously defined separately. The new model includes all the properties from both models, and the Ability class is now a nested class within PokemonDBDetails. This change was made to simplify the data structure and improve code organization.

import Foundation
import SwiftData

extension DBModel {
    @Model final class PokemonDBDetails {
        var pokemonId: Int
        var types: [String]
        var abilities: [Ability]
        var forms: [String]
        var height: Int
        var weight: Int
        var baseExperience: Int
        var color: String
        var captureRate: Int
        var eggGroups: [String]
        var shape: String?
        var habitat: String?

        init(pokemonId: Int, types: [String], abilities: [Ability], forms: [String], height: Int, weight: Int, baseExperience: Int, color: String,
             captureRate: Int,
             eggGroups: [String],
             shape: String?,
             habitat: String?)
        {
            self.pokemonId = pokemonId
            self.types = types
            self.abilities = abilities
            self.forms = forms
            self.height = height
            self.weight = weight
            self.baseExperience = baseExperience
            self.color = color
            self.captureRate = captureRate
            self.eggGroups = eggGroups
            self.shape = shape
            self.habitat = habitat
        }
    }

    @Model final class Ability {
        var name: String
        var isHidden: Bool

        init(name: String, isHidden: Bool) {
            self.name = name
            self.isHidden = isHidden
        }
    }
}
