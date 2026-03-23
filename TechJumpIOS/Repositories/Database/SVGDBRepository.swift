//  SVGDBRepository.swift
//  TechJumpIOS
//
//  Created by Copilot on 06/03/2026.
//

import Foundation
import SwiftData

protocol SVGDBRepository {
    @MainActor
    func store(svg: ApiModel.SVG) async throws
}

extension MainDBRepository: SVGDBRepository {
    func store(svg: ApiModel.SVG) async throws {
        let dbSVG = svg.dbModel()
        try modelContext.transaction {
            modelContext.insert(dbSVG)
        }
        try modelContext.save()
    }
}

extension ApiModel.SVG {
    func dbModel() -> DBModel.SVG {
        return .init(url: url, data: data)
    }
}
