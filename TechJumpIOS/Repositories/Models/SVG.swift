//
//  SVG.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 06/03/2026.
//

import Foundation
import SwiftData

extension DBModel {
    @Model final class SVG {
        var url: String
        var data: Data

        init(url: String, data: Data) {
            self.url = url
            self.data = data
        }
    }
}

extension ApiModel {
    struct SVG: Codable, Equatable {
        var url: String
        var data: Data

        init(data: Data, url: String) {
            self.url = url
            self.data = data
        }
    }
}
