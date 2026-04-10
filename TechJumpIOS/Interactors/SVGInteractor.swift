//  SVGInteractor.swift
//  TechJumpIOS
//
//  Created by Copilot on 06/03/2026.
//

import Combine
import Foundation
import SwiftUI

protocol SVGInteractor {
    func load(data: LoadableSubject<Data>, url: String?)
}

final class SVGDataInteractor: SVGInteractor {
    let webRepository: SVGWebRepository
    let dbRepository: SVGDBRepository

    init(webRepository: SVGWebRepository, dbRepository: SVGDBRepository) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
    }

    func load(data: LoadableSubject<Data>, url: String?) {
        guard let url else {
            data.wrappedValue = .notRequested; return
        }
        if let cached = dbRepository.cachedSVG(for: url) {
            data.wrappedValue = .loaded(cached)
            return
        }
        data.load { [dbRepository] in
            let result = try await self.webRepository.loadSVG(url: url)
            dbRepository.cacheSVG(result, for: url)
            return result
        }
    }
}

struct StubSVGInteractor: SVGInteractor {
    func load(data: LoadableSubject<Data>, url: String?) {}
}
