//
//  LogHandler.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 27/08/2024.
//

import Foundation

public struct LogHandler {
    public var inputHandler: ((InputLog) -> ())?
    public var outputHandler: ((OutputLog) -> ())?

    public init(inputHandler: ((InputLog) -> ())? = nil, outputHandler: ((OutputLog) -> ())? = nil) {
        self.inputHandler = inputHandler
        self.outputHandler = outputHandler
    }

    public class Log {
        public var httpMethod: HTTPMethod
        public var requestURL: URL?
        public var body: Data?
        public var httpHeaders: [String: String]?
        
        init(httpMethod: HTTPMethod, requestURL: URL? = nil, body: Data? = nil, httpHeaders: [String : String]? = nil) {
            self.httpMethod = httpMethod
            self.requestURL = requestURL
            self.body = body
            self.httpHeaders = httpHeaders
        }
    }
    
    public class InputLog: Log {
        public var statusCode: Int
        
        init(httpMethod: HTTPMethod, requestURL: URL? = nil, body: Data? = nil, httpHeaders: [String : String]? = nil, statusCode: Int) {
            self.statusCode = statusCode
            super.init(httpMethod: httpMethod, requestURL: requestURL, body: body, httpHeaders: httpHeaders)
        }
    }
    
    public class OutputLog: Log {
        
    }
}
