// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

@attached(peer)
public macro HTTP(_ method: HTTPMethod, path: CNPath..., isAuthRequired: Bool = true) = #externalMacro(module: "EMNetworkingMacros", type: "HTTPMethodMacro")

@attached(extension, conformances: APIRoute, names: arbitrary)
public macro Controller(_ controller: CNPath, baseURL: BaseURL) = #externalMacro(module: "EMNetworkingMacros", type: "Controller")

@attached(peer, conformances: APIRoute, names: arbitrary)
public macro Controller(_ name: CNPath) = #externalMacro(module: "EMNetworkingMacros", type: "Controller")

@freestanding(declaration, names: named(baseURL), arbitrary)
public macro BaseURL(_ baseURL: BaseURL, _ block: () -> Void) = #externalMacro(module: "EMNetworkingMacros", type: "BaseURL")

@attached(extension, conformances: Codable, names: arbitrary)
public macro EMCodable(codingKeyStrategy: KeyCodingStrategy.Case = .camelCase) = #externalMacro(module: "EMNetworkingMacros", type: "EMCodable")

@attached(peer)
public macro EMCodingKey(_ name: String) = #externalMacro(module: "EMNetworkingMacros", type: "EMCodingKey")
