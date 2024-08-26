//
//  Request.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public struct Request {
    var url: URL
    var headers: [String: String] = [:]
    var queryItems: [URLQueryItem] = []
    var body: Encodable?
    var method: HTTPMethod = .post
}
