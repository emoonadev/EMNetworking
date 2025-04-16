//
//  EMAccessTokenConfigurator.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public struct EMConfigurator {
    let urlSessionConfiguration: URLSessionConfiguration
    let accessTokenConfigurator: AccessToken?
    let headerConfigurator: Header?
    let urlQueryParametersConfigurator: URLQueryParameter?
    let environmentConfigurator: Environment?

    public init(urlSessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default, accessTokenConfigurator: AccessToken?, headerConfigurator: Header?, urlQueryParametersConfigurator: URLQueryParameter?, environmentConfigurator: Environment? = .init(env: { .prod })) {
        self.urlSessionConfiguration = urlSessionConfiguration
        self.accessTokenConfigurator = accessTokenConfigurator
        self.headerConfigurator = headerConfigurator
        self.urlQueryParametersConfigurator = urlQueryParametersConfigurator
        self.environmentConfigurator = environmentConfigurator
    }
}

public extension EMConfigurator {

    struct AccessToken {
        var customKey: String?
        var refreshTokenManager: TokenManaging
        var authenticationType: AuthenticationType
        
        public init(
            customKey: String? = nil,
            authenticationType: AuthenticationType = .bearer,
            refreshTokenManager: TokenManaging
        ) {
            self.customKey = customKey
            self.authenticationType = authenticationType
            self.refreshTokenManager = refreshTokenManager
        }
        
        var token: () async throws -> String? {
            {
                let rawToken = try await refreshTokenManager.getToken()
                return authenticationType.format(token: rawToken)
            }
        }
        
        var refreshToken: (() async throws -> String?)? {
            {
                let rawToken = try await refreshTokenManager.refreshToken()
                return authenticationType.format(token: rawToken)
            }
        }
        
        public init(customKey: String? = nil, token: @escaping () -> String) {
            self.customKey = customKey
            self.authenticationType = .none
            self.refreshTokenManager = LegacyTokenManager(token: token)
        }
    }
    
    struct Header {
        var contentType: ContentType
        var headers: () -> [String: String]

        public init(contentType: ContentType, headers: @escaping () -> [String: String] = { [String: String]() }) {
            self.contentType = contentType
            self.headers = headers
        }
    }

    struct URLQueryParameter {
        var parameters: () -> [URLQueryItem]

        public init(parameters: @escaping () -> [URLQueryItem]) {
            self.parameters = parameters
        }
    }
    
    struct Environment {
        var env: () -> EMNetwork.Environment

        public init(env: @escaping () -> EMNetwork.Environment) {
            self.env = env
        }
    }

}

private class LegacyTokenManager: TokenManaging {
    private let legacyToken: () -> String
    
    init(token: @escaping () -> String) {
        self.legacyToken = token
    }
    
    func getToken() async throws -> String? {
        return legacyToken()
    }
    
    func refreshToken() async throws -> String? {
        return legacyToken()
    }
    
    var isTokenValid: Bool {
        return true
    }
}
