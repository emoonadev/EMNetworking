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
        
        @RouteAPI("account/api/")
        enum User {
            @HTTP(.post, path: "login") case login(LoginReq)
        }

        @RouteAPI("community/api/")
        enum Community {
            @HTTP(.get, path: "configurations") case configurations
        }
        
    }
}
