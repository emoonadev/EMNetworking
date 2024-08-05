//
//  APIRoute.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public protocol APIRoute {
    var request: Request { get }
    var baseURL: URL { get }
}

public extension APIRoute {

    var baseHeader: [String: String] { [String: String]() }

    func get(_ path: CNPath..., queryItems: URLQueryItem...) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .get, pahtComponent: path, queryItems: queryItems)
        return req
    }

    func delete(_ path: CNPath...) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .delete, pahtComponent: path)
        return req
    }

    func put<T: Codable>(_ path: CNPath..., body: T) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .put, pahtComponent: path)
        req.body = body
        return req
    }

    func patch<T: Codable>(_ path: CNPath..., body: T) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .patch, pahtComponent: path)
        req.body = body
        return req
    }

    func post<T: Codable>(_ path: CNPath..., body: T) -> Request {
        var req = Request(url: baseURL, headers: baseHeader, body: nil)
        buidPath(for: &req, .post, pahtComponent: path)
        req.body = body
        return req
    }

    func buidPath(for request: inout Request, _ method: HTTPMethod, pahtComponent: [CNPath], queryItems: [URLQueryItem] = []) {
        pahtComponent.forEach { request.url.appendPathComponent($0.path) }
        request.queryItems.append(contentsOf: queryItems)
        request.method = method
    }
}
