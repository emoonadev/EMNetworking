//
//  AppAPI.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import EMNetworking
import Foundation

enum AppAPI {
//    #BaseURL("https://www.tinytap.com/") {
//
//        @RouteAPI("community/api/")
//        enum Community {
//            @HTTP(.post, path: "login") case login(LoginReq)
//        }
//
//        @RouteAPI("account/api/")
//        enum Account {
//            @HTTP(.get, path: "email_lookup") case emailLookup(dto: EmailLookupReq)
//            @HTTP(.get, path: "profile", .parameter("id"), "history") case profile(id: Int)
//        }
//    }

//
//    #BaseURL("https://www.tinytap.com/") {
//
//        @RouteAPI("community/api/")
//        enum Community {
//            @HTTP(.post, path: "login") case login(LoginReq)
//        }
//
//        @RouteAPI("account/api/")
//        enum Account {
//            @HTTP(.get, path: "email_lookup") case emailLookup(dto: EmailLookupReq)
//            @HTTP(.get, path: "profile", .parameter("id"), "history") case profile(id: Int)
//        }
//    }

//    #BaseURL(BaseURL("https://www.tinytap.com/", staging: "https://www.staging.tinytap.com/")) {
//
//        @RouteAPI("community/api/")
//        enum Community {
//            @HTTP(.post, path: "login") case login(LoginReq)
//        }
//
//        @RouteAPI("account/api/")
//        enum Account {
//            @HTTP(.get, path: "email_lookup") case emailLookup(dto: EmailLookupReq)
//            @HTTP(.get, path: "profile", .parameter("id"), "history") case profile(id: Int)
//        }
//    }

//    #BaseURL(BaseURL(URL(string: "https://www.tinytap.com/")!)) {
//
//        @RouteAPI("community/api/")
//        enum Community {
//            @HTTP(.post, path: "login") case login(LoginReq)
//        }
//
//        @RouteAPI("account/api/")
//        enum Account {
//            @HTTP(.get, path: "email_lookup") case emailLookup(dto: EmailLookupReq)
//            @HTTP(.get, path: "profile", .parameter("id"), "history") case profile(id: Int)
//        }
//    }

    #BaseURL(BaseURL("https://www.tinytap.com/", dev: "https://www.dev.tinytap.com/")) {

        @RouteAPI("community/api/")
        enum Community {
            @HTTP(.post, path: "login") case login(LoginReq)
        }

        @RouteAPI("account/api/")
        enum Account {
            @HTTP(.get, path: "email_lookup") case emailLookup(dto: EmailLookupReq)
            @HTTP(.get, path: "profile", .parameter("id"), "history") case profile(id: Int)
        }
    }

}
