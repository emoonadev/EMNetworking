//
//  TokenManaging.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 15/04/2025.
//

import Foundation

public protocol TokenManaging {
    func getToken() async throws -> String
    func refreshToken() async throws -> String
}

