//
//  AppAPI.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import EMNetworking
import Foundation

enum AppAPI {
    
    #BaseURL(BaseURL("https://www.tinytap.com",
                     dev: "https://development.tinytap.it/",
                     staging: "https://staging.tinytap.it/",
                     contentType: .formURLEncoded(spaceEncoding: .percentEscaped, allowedCharacters: .afURLQueryAllowed))) {
        
        @RouteAPI("community/api/")
        enum Community {
            @HTTP(.post, path: "login") case login(LoginReq)
        }
        
        
    }
    
    #BaseURL(BaseURL("https://www.tinytap.com",
                     dev: "https://development.tinytap.it/",
                     staging: "https://staging.tinytap.it/",
                     contentType: .formURLEncoded(spaceEncoding: .percentEscaped, allowedCharacters: .afURLQueryAllowed))) {
        
        @RouteAPI("account/api/")
        enum Account {
            @HTTP(.get, path: "email_lookup") case emailLookup(dto: EmailLookupReq)
        }

    }
    
    
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

//    #BaseURL(BaseURL("https://www.tinytap.com/", dev: "https://www.dev.tinytap.com/")) {
//
////        @RouteAPI("community/api/")
////        enum Community {
////            @HTTP(.post, path: "login") case login(LoginReq)
////        }
//
//        @RouteAPI("account/api/")
//        enum Account {
//            @HTTP(.get, path: "email_lookup") case emailLookup(dto: EmailLookupReq)
//            @HTTP(.get, path: "profile", .parameter("id"), "history") case profile(id: Int)
//        }
//    }
    
//    @RouteAPI("community/api/", baseURL: BaseURL("https://www.tinytap.com/", dev: "https://www.dev.tinytap.com/", contentType: .formURLEncoded(spaceEncoding: .percentEscaped, allowedCharacters: .afURLQueryAllowed)))
//    enum Community {
////        @HTTP(.post, path: "login", isAuthRequired: true) case login(LoginReq, header: HeaderItems)
//        @HTTP(.delete, path: "login", "erwefwed") case fsdfc(LoginReq)
//        
//        @HTTP(.post, path: "user", "subaccount/")
//        case createSubAccount(CreateOrUpdateSubAccountReq)
//    }
    
    #BaseURL(BaseURL("https://api.tinytap.com/api/v1/",
                     dev: "https://api-development.tinytap.it/api/v1/",
                     staging: "https://api.tinytap.it/api/v1/")) {
        
        @RouteAPI("client-config/")
        enum ClientConfig {
            @HTTP(.get, isAuthRequired: false)
            case getClientConfig
        }
        
        @RouteAPI("accounts/")
        enum Accounts {
            @HTTP(.post, path: "login/", isAuthRequired: false)
            case login(LoginReq)
            
            @HTTP(.post, path: "login", "social/", isAuthRequired: false)
            case loginSocial(LoginReq)
            

            @HTTP(.get, path: "profile", "details/")
            case profileDetails
            
            @HTTP(.get, path: "profile", "details/")
            case profileDetailsByID(header: HeaderItems)
            
            @HTTP(.get, path: "profile", "details", "permissions/")
            case permissions
            
            @HTTP(.post, path: "user", "subaccount/")
            case createSubAccount(CreateOrUpdateSubAccountReq)
            
            @HTTP(.patch, path: "user", "subaccount/")
            case updateSubAccount(CreateOrUpdateSubAccountReq)
            
        }
    }

}

@EMCodable(codingKeyStrategy: .snakeCase)
struct CreateOrUpdateSubAccountReq {
    let firstName: String
    var lastName: String = ""
    let color: Int
    let ageGroupID: Int
    let languageID: Int
    let subaccountUserID: Int?
}
