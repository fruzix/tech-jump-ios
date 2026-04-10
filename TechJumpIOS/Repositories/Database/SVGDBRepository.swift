//
//  SVGDBRepository.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 10/04/2026.
//

import Foundation

protocol SVGDBRepository {
    func cachedSVG(for url: String) -> Data?
    func cacheSVG(_ data: Data, for url: String)
}

final class SVGCacheRepository: SVGDBRepository {
    private let cache = NSCache<NSString, NSData>()

    init(countLimit: Int = 200) {
        cache.countLimit = countLimit
    }

    func cachedSVG(for url: String) -> Data? {
        cache.object(forKey: url as NSString) as Data?
    }

    func cacheSVG(_ data: Data, for url: String) {
        cache.setObject(data as NSData, forKey: url as NSString)
    }
}
