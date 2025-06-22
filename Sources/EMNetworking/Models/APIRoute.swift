//
//  APIRoute.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public protocol APIRoute {
    var request: Request { get }
    var baseURL: BaseURL { get }
}

public extension APIRoute {

    var baseHeader: [String: String] { [String: String]() }

    func get(_ path: CNPath..., queryItems: [URLQueryItem] = [], headerItems: [String: String] = [:], isAuthRequired: Bool) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .get, pahtComponent: path, queryItems: queryItems, headerItems: headerItems, isAuthRequired: isAuthRequired)
        return req
    }

    func delete<T: Codable>(_ path: CNPath..., body: T, queryItems: [URLQueryItem] = [], headerItems: [String: String] = [:], isAuthRequired: Bool) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .delete, pahtComponent: path, queryItems: queryItems, headerItems: headerItems, isAuthRequired: isAuthRequired)
        req.body = body
        return req
    }

    func put<T: Codable>(_ path: CNPath..., body: T, queryItems: [URLQueryItem] = [], headerItems: [String: String] = [:], isAuthRequired: Bool) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .put, pahtComponent: path, queryItems: queryItems, headerItems: headerItems, isAuthRequired: isAuthRequired)
        req.body = body
        return req
    }

    func patch<T: Codable>(_ path: CNPath..., body: T, queryItems: [URLQueryItem] = [], headerItems: [String: String] = [:], isAuthRequired: Bool) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .patch, pahtComponent: path, queryItems: queryItems, headerItems: headerItems, isAuthRequired: isAuthRequired)
        req.body = body
        return req
    }

    func post<T: Codable>(_ path: CNPath..., body: T, queryItems: [URLQueryItem] = [], headerItems: [String: String] = [:], isAuthRequired: Bool) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .post, pahtComponent: path, queryItems: queryItems, headerItems: headerItems, isAuthRequired: isAuthRequired)
        req.body = body
        return req
    }

    func buidPath(for request: inout Request, _ method: HTTPMethod, pahtComponent: [CNPath], queryItems: [URLQueryItem] = [], headerItems: [String: String] = [:], isAuthRequired: Bool) {
        pahtComponent.forEach {
            request.url.prod.appendPathComponent($0.path)
            request.url.dev?.appendPathComponent($0.path)
            request.url.staging?.appendPathComponent($0.path)
            request.url.test?.appendPathComponent($0.path)
        }
        request.queryItems.append(contentsOf: queryItems)
        request.method = method
        request.isAuthRequired = isAuthRequired
        request.headers.merge(headerItems) { _, new in new }
        
        if let contentType = request.url.contentType {
            request.headers["Content-Type"] = contentType.value
        }
    }
}
