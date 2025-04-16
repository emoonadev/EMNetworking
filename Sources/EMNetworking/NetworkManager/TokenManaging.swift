//
//  TokenManaging.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 15/04/2025.
//

import Foundation

public protocol TokenManaging {
    var token: String { get }
    var isTokenValid: Bool { get }
    func refreshToken() async throws -> String
}

