//  SVGWebRepository.swift
//  TechJumpIOS
//
//  Created by Copilot on 06/03/2026.
//

import Foundation

protocol SVGWebRepository: WebRepository {
    func loadSVG(url: String) async throws -> Data
}

struct SVGDataWebRepository: SVGWebRepository {
    let session: URLSession
    let baseURL: String

    init(session: URLSession, baseURL: String = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/") {
        self.session = session
        self.baseURL = baseURL
    }

    func loadSVG(url: String) async throws -> Data {
        guard let svgURL = URL(string: url) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await session.data(from: svgURL)
        return data
    }
}
