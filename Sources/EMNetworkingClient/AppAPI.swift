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

    #BaseURL(BaseURL("https://api.tinytap.com/api/v1/", dev: "https://api-development.tinytap.it/api/v1/", staging: "https://api.tinytap.it/api/v1/")) {
        @RouteAPI("account/api/")
        enum Account {
            @HTTP(.post, path: "register", isAuthRequired: false)
            case register(SignupReq, params: QueryItems = .init(dictionaryLiteral: ("is_detailed_response", 1)))
        }
    }
    
    @RouteAPI("community/api/", baseURL: BaseURL("https://www.tinytap.com/", dev: "https://www.dev.tinytap.com/"))
    enum Community {
//        @HTTP(.post, path: "login", isAuthRequired: true) case login(LoginReq, header: HeaderItems)
//        @HTTP(.get, path: "login", "erwefwed") case fsdfc(header: HeaderItems)
//        @HTTP(.get, path: "login", "ttt", isAuthRequired: false) case aaaa(header: HeaderItems)
        @HTTP(.get, path: "profile", "details", isAuthRequired: true) case profileDetails
        

    }

}

@EMCodable(codingKeyStrategy: .snakeCase)
struct SignupReq {
    var email: String
    var password: String
    var userType: Int
}
