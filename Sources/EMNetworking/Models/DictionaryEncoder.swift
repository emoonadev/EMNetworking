//
//  Untitled.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public struct DictionaryEncoder {

    public static func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(value)
        return try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
    }

    public static func encode(data: Data) throws -> [String: Any]? {
        return try JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

}
