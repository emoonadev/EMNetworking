//
//  Nothing.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public struct ServerResponse<T: Codable>: Codable {
    public let message: String?
    public let data: T?
}

public struct Nothing: Codable {
    
}
