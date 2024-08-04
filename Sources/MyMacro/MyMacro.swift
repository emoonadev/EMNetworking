// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

@attached(peer)
public macro HTTP(_ method: HTTPMethod, path: CNPath...) = #externalMacro(module: "MyMacroMacros", type: "HTTPMethodMacro")

@attached(extension, conformances: APIRoute, names: arbitrary)
public macro RouteAPI(_ controller: CNPath, baseURL: URL) = #externalMacro(module: "MyMacroMacros", type: "RouteAPI")

@attached(peer, conformances: APIRoute, names: arbitrary)
public macro RouteAPI(_ name: CNPath) = #externalMacro(module: "MyMacroMacros", type: "RouteAPI")

@freestanding(declaration, names: named(baseURL), arbitrary)
public macro BaseURL(_ url: String, _ block: () -> Void) = #externalMacro(module: "MyMacroMacros", type: "BaseURL")
