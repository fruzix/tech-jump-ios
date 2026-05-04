//
//  Loadable.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

import Foundation
import SwiftUI

enum Loadable {
    case notRequested
    case isLoading
    case loaded
    case failed(Error)

    var error: Error? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }

    mutating func setIsLoading() {
        self = .isLoading
    }
}

struct ValueIsMissingError: Error {
    var localizedDescription: String {
        NSLocalizedString("Data is missing", comment: "")
    }
}
