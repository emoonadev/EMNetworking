//
//  AppAPI.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation
import MyMacro

enum AppAPI {

    #BaseURL("https://www.tinytap.com/") {

        @RouteAPI("community/api/")
        enum User {
            @HTTP(.post, path: "login") case login(LoginReq)
        }

        @RouteAPI("community/api/")
        enum Community {
            @HTTP(.get, path: "configurations") case configurations
        }

    }

    @RouteAPI("community/api/", baseURL: URL(string: "https://www.tinytap.com/")!)
    enum EnumForDebug {
//        @HTTP(.get, path: .parameter("id")) case configurations(id: Int)
        @HTTP(.post, path: "configuration", "user", .parameter("id"), "test", .parameter("second")) case configurations(String, id: Int, second: Int)
    }
}
