//
//  EMNetwork.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public final class EMNetwork {
    let accessTokenConfigurator: EMConfigurator.AccessToken?
    let headerConfigurator: EMConfigurator.Header?
    let urlQueryParametersConfigurator: EMConfigurator.URLQueryParameter?

    public init(accessTokenConfigurator: EMConfigurator.AccessToken? = nil, headerConfigurator: EMConfigurator.Header? = nil, urlQueryParametersConfigurator: EMConfigurator.URLQueryParameter? = nil) {
        self.accessTokenConfigurator = accessTokenConfigurator
        self.headerConfigurator = headerConfigurator
        self.urlQueryParametersConfigurator = urlQueryParametersConfigurator
    }

    public func perform<Model: Codable>(route: APIRoute) async throws -> Model? {
        let serverResponse: ServerResponse<Model> = try await performRequest(route: route)
        return serverResponse.data
    }

    public func perform(route: APIRoute) async throws {
        let _: ServerResponse<Nothing> = try await performRequest(route: route)
    }

    private func performRequest<T: Codable>(route: APIRoute) async throws -> ServerResponse<T> {
        var request = route.request

        if let accessTokenConfigurator {
            request.headers[accessTokenConfigurator.customKey ?? "Authorization"] = accessTokenConfigurator.token()
        }
        
        if let headerConfigurator {
            headerConfigurator.headers().forEach { (key, value) in
                request.headers[key] = value
            }
        }
        
        if let urlQueryParametersConfigurator {
            request.queryItems.insert(contentsOf: urlQueryParametersConfigurator.parameters(), at: 0)
        }

        var finalURL = request.url
        
        if !request.queryItems.isEmpty {
            var urlComponents = URLComponents(url: finalURL, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = request.queryItems
            finalURL = urlComponents.url!
        }
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue.uppercased()
        urlRequest.allHTTPHeaderFields = request.headers
        
        if let body = request.body {
            let jsonSerialization = try JSONSerialization.data(withJSONObject: body)
            urlRequest.httpBody = jsonSerialization

            #if DEBUG
            print("--> \(request.method.rawValue.uppercased()) \(urlRequest.url?.absoluteString ?? ""): \(String(data: jsonSerialization, encoding: .utf8) ?? "NO BODY")")
            #endif
        } else {
            #if DEBUG
                print("--> \(request.method.rawValue.uppercased()) \(urlRequest.url?.absoluteString ?? "")")
            #endif
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        #if DEBUG
            print("<-- \(request.method.rawValue.uppercased()) \(urlRequest.url?.absoluteString ?? ""): \(String(data: data, encoding: .utf8) ?? "NO BODY")")
        #endif

        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .secondsSince1970
            let serverResponse = try jsonDecoder.decode(ServerResponse<T>.self, from: data)

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                throw EMError.network(serverResponse.result)
            }

            return serverResponse
        } catch {
            #if DEBUG
                print("🔴 Error on decoding: \(error)")
            #endif

            throw EMError.network(error.localizedDescription)
        }
    }

}
