//
//  SetupNetworkManager.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import EMNetworking
import Foundation

nonisolated(unsafe)
let logHandler = LogHandler { log in
    if let body = log.body {
        print("➡️ \(log.httpMethod.rawValue.uppercased()) \(log.requestURL?.absoluteString ?? ""): \(String(data: body, encoding: .utf8) ?? "NO BODY")")
    } else {
        print("➡️ \(log.httpMethod.rawValue.uppercased()) \(log.requestURL?.absoluteString ?? "")")
    }
} outputHandler: { log in
    if let body = log.body {
        print("⬅️ \(log.httpMethod.rawValue.uppercased()) \(log.requestURL?.absoluteString ?? ""): \(String(data: body, encoding: .utf8) ?? "NO BODY")")
    } else {
        print("⬅️ \(log.httpMethod.rawValue.uppercased()) \(log.requestURL?.absoluteString ?? "")")
    }
}

let token = "f2910bce-1774-48ad-a94e-17a4a3e7356b"

nonisolated(unsafe) let accessToken = EMConfigurator.AccessToken(customKey: "TinyToken") {
    token
}

nonisolated(unsafe) let defaultHeader = EMConfigurator.Header(contentType: .formURLEncoded) {
    var dic = [String: String]()
    dic["User-Agent"] = "TinyTap/4.5.9 (iPhone; iOS 17.4; Scale/3.00)"
    dic["Accept-Language"] = "en"
    dic["TinyDeviceID"] = "BB662BE1-0399-47F0-99EF-50BB36222AAD"
    return dic
}

nonisolated(unsafe) let queryParameters = EMConfigurator.URLQueryParameter {
    [
        URLQueryItem(name: "ver", value: "3.4.6"),
        URLQueryItem(name: "bundle_id", value: "com.27dv.tinytap"),
        URLQueryItem(name: "app_version", value: "4.5.9"),
        URLQueryItem(name: "session_num", value: "2"),
    ]
}

nonisolated(unsafe) let networkManager = EMNetwork(configurator: EMConfigurator(accessTokenConfigurator: accessToken,
                                                                                headerConfigurator: defaultHeader,
                                                                                urlQueryParametersConfigurator: queryParameters),
                                                   logHandler: logHandler
)
