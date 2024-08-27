//
//  LogHandler.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 27/08/2024.
//

import Foundation

public struct LogHandler {
    public var inputHandler: ((Log) -> ())?
    public var outputHandler: ((Log) -> ())?

    public init(inputHandler: ((Log) -> ())? = nil, outputHandler: ((Log) -> ())? = nil) {
        self.inputHandler = inputHandler
        self.outputHandler = outputHandler
    }

    public struct Log {
        public var httpMethod: HTTPMethod
        public var requestURL: URL?
        public var body: Data?
    }
}
