//  SVGInteractor.swift
//  TechJumpIOS
//
//  Created by Copilot on 06/03/2026.
//

import Foundation
import SwiftUI

protocol SVGInteractor {
    func load(url: String?, pokemonId: Int) async throws -> Data?
}

final class SVGDataInteractor: SVGInteractor {
    let webRepository: SVGWebRepository
    let dbRepository: SVGDBRepository

    init(webRepository: SVGWebRepository, dbRepository: SVGDBRepository) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
    }

    func load(url: String?, pokemonId: Int) async throws -> Data? {
        guard let url else {
            return nil
        }

        if let cached = dbRepository.cachedSVG(for: pokemonId) {
            return cached
        }

        let result = try await webRepository.loadSVG(url: url)
        dbRepository.cacheSVG(result, for: pokemonId)
        return result
    }
}

struct StubSVGInteractor: SVGInteractor {
    func load(url: String?, pokemonId: Int) async throws -> Data? { nil }
}
