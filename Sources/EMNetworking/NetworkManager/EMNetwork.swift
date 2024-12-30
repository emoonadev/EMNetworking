//
//  EMNetwork.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public final class EMNetwork {
    let configurator: EMConfigurator?
    let serverResponseParser: ServerResponseParser
    let logHandler: LogHandler?

    public init(configurator: EMConfigurator? = nil, serverResponseParser: ServerResponseParser = DefaultServerResponseParser(), logHandler: LogHandler? = nil) {
        self.configurator = configurator
        self.logHandler = logHandler
        self.serverResponseParser = serverResponseParser
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

        if let accessTokenConfigurator = configurator?.accessTokenConfigurator {
            request.headers[accessTokenConfigurator.customKey ?? "Authorization"] = accessTokenConfigurator.token()
        }

        if let header = configurator?.headerConfigurator {
            request.headers["Content-Type"] = header.contentType.rawValue

            configurator?.headerConfigurator?.headers().forEach { key, value in
                request.headers[key] = value
            }
        }

        if let urlQueryParametersConfigurator = configurator?.urlQueryParametersConfigurator {
            request.queryItems.insert(contentsOf: urlQueryParametersConfigurator.parameters(), at: 0)
        }

        var finalURL: URL = if let environmentConfigurator = configurator?.environmentConfigurator {
            switch environmentConfigurator.env() {
                case .prod:
                    request.url.prod
                case .staging:
                    request.url.staging ?? request.url.prod
                case .dev:
                    request.url.dev ?? request.url.prod
                case .test:
                    request.url.test ?? request.url.prod
            }
        } else {
            request.url.prod
        }

        if let headerConfigurator = configurator?.headerConfigurator, headerConfigurator.contentType == .formURLEncoded {
            finalURL = URL(string: finalURL.absoluteString + "/")!
        }

        if !request.queryItems.isEmpty {
            var urlComponents = URLComponents(url: finalURL, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = request.queryItems
            finalURL = urlComponents.url!
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue.uppercased()
        urlRequest.allHTTPHeaderFields = request.headers

        if let body = request.body {
            let jsonSerialization: Data

            if let headerConfigurator = configurator?.headerConfigurator, headerConfigurator.contentType == .formURLEncoded {
                jsonSerialization = try URLEncodedFormEncoder().encode(body)
            } else {
                jsonSerialization = try JSONSerialization.data(withJSONObject: try DictionaryEncoder.encode(body))
            }

            urlRequest.httpBody = jsonSerialization

            logHandler?.outputHandler?(LogHandler.Log(httpMethod: request.method, requestURL: urlRequest.url, body: jsonSerialization, httpHeaders: urlRequest.allHTTPHeaderFields))
        } else {
            logHandler?.outputHandler?(LogHandler.Log(httpMethod: request.method, requestURL: urlRequest.url, body: nil, httpHeaders: urlRequest.allHTTPHeaderFields))
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        var httpHeaders = [String: String]()

        (response as? HTTPURLResponse)?.allHeaderFields.forEach {
            httpHeaders[String(describing: $0.key)] = String(describing: $0.value)
        }

        logHandler?.inputHandler?(LogHandler.Log(httpMethod: request.method, requestURL: urlRequest.url, body: data, httpHeaders: httpHeaders))

        do {
            let serverResponse: ServerResponse<T> = try serverResponseParser.parse(data: data)

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                throw NSError(domain: "com.emNetwork.error", code: (response as? HTTPURLResponse)?.statusCode ?? -232, userInfo: [NSLocalizedDescriptionKey: "Failure"])
            }

            return serverResponse
        } catch let error as NSError {
            #if DEBUG
                print("🔴 Error on decoding: \(error)")
            #endif

            throw NSError(domain: "com.emNetwork.error", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        }
    }

    public enum Environment {
        case prod, staging, dev, test
    }
}
