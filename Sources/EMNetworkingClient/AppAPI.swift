//
//  AppAPI.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation
import EMNetworking

enum AppAPI {

    #BaseURL("https://www.tinytap.com/") {

        @RouteAPI("community/api/")
        enum Community {
            @HTTP(.post, path: "login") case login(LoginReq)
        }

        @RouteAPI("account/api/")
        enum Account {
            @HTTP(.get, path: "email_lookup") case emailLookup(dto: EmailLookupReq)
        }
    }
    
}
