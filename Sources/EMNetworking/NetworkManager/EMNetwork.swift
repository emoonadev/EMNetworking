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
    private var isRefreshingToken: Bool = false
    private let sessionDelegate: EMNetworkSessionDelegate?

    public init(configurator: EMConfigurator? = nil, serverResponseParser: ServerResponseParser = DefaultServerResponseParser(), logHandler: LogHandler? = nil) {
        self.configurator = configurator
        self.logHandler = logHandler
        self.serverResponseParser = serverResponseParser
        self.sessionDelegate = EMNetworkSessionDelegate(certificatePinning: configurator?.certificatePinningConfigurator)
    }

    public func perform<Model: Codable>(route: APIRoute, isIgnoreRefreshing: Bool = false) async throws -> Model? {
        let serverResponse: ServerResponse<Model> = try await performRequest(route: route, isIgnoreRefreshing: isIgnoreRefreshing)
        return serverResponse.data
    }

    public func perform(route: APIRoute) async throws {
        let _: ServerResponse<Nothing> = try await performRequest(route: route)
    }

    private func performRequest<T: Codable>(route: APIRoute, isIgnoreRefreshing: Bool = false) async throws -> ServerResponse<T> {
        var request = route.request

        func performRefreshToken() async throws {
            guard let accessTokenConfigurator = configurator?.accessTokenConfigurator, request.isAuthRequired else { return }
            
            if !isRefreshingToken, let refreshToken = accessTokenConfigurator.refreshToken {
                isRefreshingToken = true
                
                do {
                    let newToken = try await refreshToken()
                    isRefreshingToken = false
                    request.headers[accessTokenConfigurator.customKey ?? "Authorization"] = newToken
                } catch {
                    isRefreshingToken = false
                    throw error
                }
            }
        }
        
        if let accessTokenConfigurator = configurator?.accessTokenConfigurator, request.isAuthRequired {
            if accessTokenConfigurator.isTokenValid || isIgnoreRefreshing {
                request.headers[accessTokenConfigurator.customKey ?? "Authorization"] = accessTokenConfigurator.token
            } else {
                if !isRefreshingToken {
                    try await performRefreshToken()
                } else {
                    throw NSError(domain: "com.emNetwork.error", code: -338, userInfo: [NSLocalizedDescriptionKey: "Refreshing access token..."])
                }
            }
        }

        if let header = configurator?.headerConfigurator {
            request.headers.merge(header.headers()) { old, _ in old }
            request.headers = request.headers.filter { $0.value != IgnoreValue.ignore }
        }
        
        request.headers["Content-Type"] = route.request.url.contentType.value

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

        if case .formURLEncoded = route.request.url.contentType {
            finalURL = URL(string: finalURL.absoluteString + "/")!
        }

        if !request.queryItems.isEmpty {
            var urlComponents = URLComponents(url: finalURL, resolvingAgainstBaseURL: false)!
            
            if case let .formURLEncoded(alphabetizeKeyValuePairs, arrayEncoding, boolEncoding, dataEncoding, dateEncoding, keyEncoding, spaceEncoding, allowedCharacters) = route.request.url.contentType {
                let encoder = URLEncodedFormEncoder(
                    alphabetizeKeyValuePairs: alphabetizeKeyValuePairs,
                    arrayEncoding: arrayEncoding,
                    boolEncoding: boolEncoding,
                    dataEncoding: dataEncoding,
                    dateEncoding: dateEncoding,
                    keyEncoding: keyEncoding,
                    spaceEncoding: spaceEncoding,
                    allowedCharacters: allowedCharacters
                )
                
                let queryItemsDict = Dictionary(
                    request.queryItems.map { ($0.name, $0.value ?? "") },
                    uniquingKeysWith: { first, _ in first }
                )
                
                if let encodedQuery: String = try? encoder.encode(queryItemsDict) {
                    urlComponents.percentEncodedQuery = encodedQuery
                }
            } else {
                urlComponents.queryItems = request.queryItems
            }
            
            finalURL = urlComponents.url!
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue.uppercased()
        urlRequest.allHTTPHeaderFields = request.headers

        if let body = request.body {
            let jsonSerialization: Data

            if case let .formURLEncoded(alphabetizeKeyValuePairs, arrayEncoding, boolEncoding, dataEncoding, dateEncoding, keyEncoding, spaceEncoding, allowedCharacters) = route.request.url.contentType {
                jsonSerialization = try URLEncodedFormEncoder(alphabetizeKeyValuePairs: alphabetizeKeyValuePairs, arrayEncoding: arrayEncoding, boolEncoding: boolEncoding, dataEncoding: dataEncoding, dateEncoding: dateEncoding, keyEncoding: keyEncoding, spaceEncoding: spaceEncoding, allowedCharacters: allowedCharacters).encode(body)
            } else {
                jsonSerialization = try JSONSerialization.data(withJSONObject: try DictionaryEncoder.encode(body))
            }

            urlRequest.httpBody = jsonSerialization

            logHandler?.outputHandler?(LogHandler.OutputLog(httpMethod: request.method, requestURL: urlRequest.url, body: jsonSerialization, httpHeaders: urlRequest.allHTTPHeaderFields))
        } else {
            logHandler?.outputHandler?(LogHandler.OutputLog(httpMethod: request.method, requestURL: urlRequest.url, body: nil, httpHeaders: urlRequest.allHTTPHeaderFields))
        }
        
        let session: URLSession

        if let urlSessionConfiguration = configurator?.urlSessionConfiguration {
            if configurator?.certificatePinningConfigurator != nil {
                session = URLSession(configuration: urlSessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            } else {
                session = URLSession(configuration: urlSessionConfiguration)
            }
        } else {
            if configurator?.certificatePinningConfigurator != nil {
                session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
            } else {
                session = URLSession.shared
            }
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let (data, response) = try await session.data(for: urlRequest)
        let endTime = CFAbsoluteTimeGetCurrent()
        let responseTimeMillis = Int((endTime - startTime) * 1000)

        var httpHeaders = [String: String]()

        (response as? HTTPURLResponse)?.allHeaderFields.forEach {
            httpHeaders[String(describing: $0.key)] = String(describing: $0.value)
        }

        logHandler?.inputHandler?(LogHandler.InputLog(httpMethod: request.method, requestURL: urlRequest.url, body: data, httpHeaders: httpHeaders, statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1, responseTimeMillis: responseTimeMillis))

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