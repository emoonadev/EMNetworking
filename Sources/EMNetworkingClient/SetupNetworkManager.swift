//
//  SetupNetworkManager.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation
import EMNetworking


let token = "f2910bce-1774-48ad-a94e-17a4a3e7356b"

nonisolated(unsafe) let accessToken = EMConfigurator.AccessToken(customKey: "TinyToken") {
    token
}

nonisolated(unsafe)let defaultHeader = EMConfigurator.Header(contentType: .formURLEncoded) {
    var dic = [String:String]()
    dic["User-Agent"] = "TinyTap/4.5.9 (iPhone; iOS 17.4; Scale/3.00)"
    dic["Accept-Language"] = "en"
    dic["TinyDeviceID"] = "BB662BE1-0399-47F0-99EF-50BB36222AAD"
    return dic
}

nonisolated(unsafe)let queryParameters = EMConfigurator.URLQueryParameter {
    [
        URLQueryItem(name: "ver", value: "3.4.6"),
        URLQueryItem(name: "bundle_id", value: "com.27dv.tinytap"),
        URLQueryItem(name: "app_version", value: "4.5.9"),
        URLQueryItem(name: "session_num", value: "2"),
    ]
}

nonisolated(unsafe) let networkManager = EMNetwork(accessTokenConfigurator: accessToken, 
                               headerConfigurator: defaultHeader,
                               urlQueryParametersConfigurator: queryParameters)
