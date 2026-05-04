//
//  Loadable.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 12/01/2026.
//

import Foundation
import SwiftUI

typealias LoadableSubject<T> = Binding<Loadable<T>>

enum Loadable<T> {
    case notRequested
    case isLoading(last: T?, cancelBag: CancelBag)
    case loaded(T)
    case failed(Error)

    var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last, _): return last
        default: return nil
        }
    }

    var error: Error? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }

    mutating func setIsLoading(cancelBag: CancelBag) {
        self = .isLoading(last: value, cancelBag: cancelBag)
    }
}

extension LoadableSubject {
    func load<T>(_ resource: @escaping () async throws -> T) where Value == Loadable<T> {
        let cancelBag = CancelBag()
        wrappedValue.setIsLoading(cancelBag: cancelBag)
        let task = Task {
            do {
                wrappedValue = try .loaded(await resource())
            } catch {
                wrappedValue = .failed(error)
            }
        }
        task.store(in: cancelBag)
    }
}

struct ValueIsMissingError: Error {
    var localizedDescription: String {
        NSLocalizedString("Data is missing", comment: "")
    }
}
