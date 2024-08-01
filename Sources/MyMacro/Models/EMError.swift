//
//  EMError.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public enum EMError: Error {
    case network(String)
    case nilData

    var errorDescription: String? {
        switch self {
            case let .network(msg): return msg
            case .nilData: return "Data is nil"
        }
    }

    var failureReason: String? {
        switch self {
            case let .network(msg): return msg
            case .nilData: return "Data is nil"
        }
    }

    var recoverySuggestion: String? {
        switch self {
            case let .network(msg): return msg
            case .nilData: return "Data is nil"
        }
    }
}
