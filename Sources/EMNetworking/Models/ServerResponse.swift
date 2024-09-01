//
//  Nothing.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public struct ServerResponse<T: Codable>: Codable {
    public var message: String?
    public var data: T?
    
    public init(message: String? = nil, data: T? = nil) {
        self.message = message
        self.data = data
    }
}

public struct Nothing: Codable {
    
}
