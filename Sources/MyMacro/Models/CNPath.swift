//
//  CNPath.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public protocol CNPathParameter {
    var cnValue: String { get }
}

public enum CNPath: ExpressibleByStringInterpolation {
    case constant(String), parameter(CNPathParameter), join([CNPath])

    var path: String {
        switch self {
            case let .constant(value): return value
            case let .parameter(value): return value.cnValue
            case let .join(values): return values.map { $0.path }.joined(separator: "/")
        }
    }

    public init(stringLiteral value: String) {
        self = .constant(value)
    }
}

extension String: CNPathParameter {
    public var cnValue: String { self }
}

extension UUID: CNPathParameter {
    public var cnValue: String { uuidString }
}
