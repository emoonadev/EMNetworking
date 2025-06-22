//
//  BaseURL.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 30/12/2024.
//

import Foundation

public struct BaseURL: ExpressibleByStringInterpolation {
    public var prod: URL
    public var dev: URL?
    public var staging: URL?
    public var test: URL?
    public var contentType: ContentType = .json
    
    public init(_ prod: URL, dev: URL? = nil, staging: URL? = nil, test: URL? = nil, contentType: ContentType = .json) {
        self.prod = prod
        self.dev = dev
        self.staging = staging
        self.test = test
        self.contentType = contentType
    }
    
    public init(stringLiteral value: String) {
        self = BaseURL(URL(string: value)!)
    }
}

extension URL: @retroactive ExpressibleByStringInterpolation {
    
    public init(stringLiteral value: String) {
        self = URL(string: value)!
    }
    
}
