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

struct SVGDataInteractor: SVGInteractor {
    let webRepository: SVGWebRepository

    init(webRepository: SVGWebRepository) {
        self.webRepository = webRepository
    }

    func load(data: LoadableSubject<Data>, url: String?) {
        guard let url else {
            data.wrappedValue = .notRequested; return
        }
        data.load {
            try await webRepository.loadSVG(url: url)
        }
    }
}

struct StubSVGInteractor: SVGInteractor {
    func load(data: LoadableSubject<Data>, url: String?) {}
}
