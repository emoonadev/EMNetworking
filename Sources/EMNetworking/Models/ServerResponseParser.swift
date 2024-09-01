//
//  ServerResponseParser.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 01/09/2024.
//

import Foundation

public protocol ServerResponseParser {
    func parse<T: Codable>(data: Data) throws -> ServerResponse<T>
}

public struct DefaultServerResponseParser: ServerResponseParser {
    public init() {
        
    }
    
    public func parse<T: Codable>(data: Data) throws -> ServerResponse<T> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(ServerResponse<T>.self, from: data)
    }
}
