// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

@attached(peer)
public macro HTTP(_ method: HTTPMethod, path: CNPath...) = #externalMacro(module: "EMNetworkingMacros", type: "HTTPMethodMacro")

@attached(extension, conformances: APIRoute, names: arbitrary)
public macro RouteAPI(_ controller: CNPath, baseURL: URL) = #externalMacro(module: "EMNetworkingMacros", type: "RouteAPI")

@attached(peer, conformances: APIRoute, names: arbitrary)
public macro RouteAPI(_ name: CNPath) = #externalMacro(module: "EMNetworkingMacros", type: "RouteAPI")

@freestanding(declaration, names: named(baseURL), arbitrary)
public macro BaseURL(_ url: String, _ block: () -> Void) = #externalMacro(module: "EMNetworkingMacros", type: "BaseURL")

@attached(extension, conformances: Codable, names: arbitrary)
public macro EMCodable() = #externalMacro(module: "EMNetworkingMacros", type: "EMCodable")

@attached(peer)
public macro EMCodingKey(_ name: String) = #externalMacro(module: "EMNetworkingMacros", type: "EMCodingKey")
