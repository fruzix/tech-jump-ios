//
//  SVGDBRepository.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 10/04/2026.
//

import Foundation

protocol SVGDBRepository {
    func cachedSVG(for pokemonId: Int) -> Data?
    func cacheSVG(_ data: Data, for pokemonId: Int)
}

final class SVGCacheRepository: SVGDBRepository {
    private let cache = NSCache<NSNumber, NSData>()

    init(countLimit: Int = 200) {
        cache.countLimit = countLimit
    }

    func cachedSVG(for pokemonId: Int) -> Data? {
        cache.object(forKey: pokemonId as NSNumber) as Data?
    }

    func cacheSVG(_ data: Data, for pokemonId: Int) {
        cache.setObject(data as NSData, forKey: pokemonId as NSNumber)
    }
}
