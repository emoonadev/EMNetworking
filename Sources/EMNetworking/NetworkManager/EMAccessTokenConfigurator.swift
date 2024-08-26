//
//  EMAccessTokenConfigurator.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public struct EMConfigurator {
    let accessTokenConfigurator: AccessToken?
    let headerConfigurator: Header?
    let urlQueryParametersConfigurator: URLQueryParameter?
    
    public init(accessTokenConfigurator: AccessToken?, headerConfigurator: Header?, urlQueryParametersConfigurator: URLQueryParameter?) {
        self.accessTokenConfigurator = accessTokenConfigurator
        self.headerConfigurator = headerConfigurator
        self.urlQueryParametersConfigurator = urlQueryParametersConfigurator
    }
}

public extension EMConfigurator {
    
    struct AccessToken {
        var customKey: String?
        var token: () -> String
        
        public init(customKey: String? = nil, token: @escaping () -> String) {
            self.customKey = customKey
            self.token = token
        }
    }
    
    struct Header {
        var contentType: ContentType
        var headers: () -> [String:String]
        
        public init(contentType: ContentType, headers: @escaping () -> [String : String]) {
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
    
}

