//
//  AppEnvironment.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 23/01/2026.
//

import Foundation
import SwiftData

@MainActor
struct AppEnvironment {
    let diContainer: DIContainer
    let modelContainer: ModelContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())

        let session = configuredURLSession()
        let webRepositories = configuredWebRepositories(session: session)
        let modelContainer = configuredModelContainer()
        let dbRepositories = configuredDBRepositories(modelContainer: modelContainer)
        let interactors = configuredInteractors(appState: appState, webRepositories: webRepositories, dbRepositories: dbRepositories)
        let diContainer = DIContainer(appState: appState, interactors: interactors)

        return AppEnvironment(
            diContainer: diContainer,
            modelContainer: modelContainer)
    }

    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }

    private static func configuredWebRepositories(session: URLSession) -> DIContainer.WebRepositories {
        let pokemons = PokemonDataWebRepository(session: session)

        return .init(pokemons: pokemons)
    }

    private static func configuredDBRepositories(modelContainer: ModelContainer) -> DIContainer.DBRepositories {
        let mainDBRepository = MainDBRepository(modelContainer: modelContainer)

        return .init(pokemons: mainDBRepository)
    }

    private static func configuredModelContainer() -> ModelContainer {
        do {
            return try ModelContainer.appModelContainer()
        } catch {
            // Log the error
            return ModelContainer.stub
        }
    }

    private static func configuredInteractors(
        appState: Store<AppState>,
        webRepositories: DIContainer.WebRepositories,
        dbRepositories: DIContainer.DBRepositories
    ) -> DIContainer.Interactors {
        let pokemons = RealPokemonInteractor(
            webRepository: webRepositories.pokemons,
            dbRepository: dbRepositories.pokemons)

        return .init(
            pokemons: pokemons)
    }
}
