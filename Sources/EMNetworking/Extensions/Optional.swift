//
//  Optional.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

extension Optional {

    public func unwrap(orThrow error: Error = EMError.nilData) throws -> Wrapped {
        guard let value = self else { throw error }
        return value
    }
}

