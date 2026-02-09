//
//  AppState.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

import Combine
import SwiftUI

struct AppState: Equatable {
    var routing = ViewRouting()
}

extension AppState {
    struct ViewRouting: Equatable {
        var pokemonList = PokemonList.Routing()
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.routing == rhs.routing
}
