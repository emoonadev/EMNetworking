//
//  EMAccessTokenConfigurator.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public enum EMConfigurator {
    
    public struct AccessToken {
        var customKey: String?
        var token: () -> String
        
        public init(customKey: String? = nil, token: @escaping () -> String) {
            self.customKey = customKey
            self.token = token
        }
    }
    
    public struct Header {
        var headers: () -> [String:String]
        
        public init(headers: @escaping () -> [String : String]) {
            self.headers = headers
        }
    }
    
    
    public struct URLQueryParameter {
        var parameters: () -> [URLQueryItem]
        
        public init(parameters: @escaping () -> [URLQueryItem]) {
            self.parameters = parameters
        }
    }
    
    
}

