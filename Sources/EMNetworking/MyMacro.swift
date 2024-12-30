// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

@attached(peer)
public macro HTTP(_ method: HTTPMethod, path: CNPath...) = #externalMacro(module: "EMNetworkingMacros", type: "HTTPMethodMacro")

@attached(extension, conformances: APIRoute, names: arbitrary)
public macro RouteAPI(_ controller: CNPath, baseURL: BaseURL) = #externalMacro(module: "EMNetworkingMacros", type: "RouteAPI")

@attached(peer, conformances: APIRoute, names: arbitrary)
public macro RouteAPI(_ name: CNPath) = #externalMacro(module: "EMNetworkingMacros", type: "RouteAPI")

@freestanding(declaration, names: named(baseURL), arbitrary)
public macro BaseURL(_ baseURL: BaseURL, _ block: () -> Void) = #externalMacro(module: "EMNetworkingMacros", type: "BaseURL")

@attached(extension, conformances: Codable, names: arbitrary)
public macro EMCodable(codingKeyStrategy: KeyCodingStrategy.Case = .camelCase) = #externalMacro(module: "EMNetworkingMacros", type: "EMCodable")

@attached(peer)
public macro EMCodingKey(_ name: String) = #externalMacro(module: "EMNetworkingMacros", type: "EMCodingKey")

public struct BaseURL: ExpressibleByStringInterpolation {
    public var prod: URL
    public var dev: URL?
    public var staging: URL?
    public var test: URL?
    
    public init(_ prod: URL, dev: URL? = nil, staging: URL? = nil, test: URL? = nil) {
        self.prod = prod
        self.dev = dev
        self.staging = staging
        self.test = test
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
