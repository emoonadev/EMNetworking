//
//  Optional.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

extension Optional {

    public func unwrap(orThrow error: Error = NSError(domain: "com.emNetwork.error", code: -328, userInfo: [NSLocalizedDescriptionKey: "Nil data"])) throws -> Wrapped {
        guard let value = self else { throw error }
        return value
    }
}

