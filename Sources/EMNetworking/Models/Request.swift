//
//  Request.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public struct Request {
    var url: BaseURL
    var headers: [String: String] = [:]
    var queryItems: [URLQueryItem] = []
    var body: Encodable?
    var method: HTTPMethod = .post
}
