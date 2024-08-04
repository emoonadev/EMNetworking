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
        
        @RouteAPI(.account)
        enum User {
            @HTTP(.post, path: .login) case login(LoginReq)
        }

        @RouteAPI(.community)
        enum Community {
            @HTTP(.get, path: .configurations) case configurations
        }
        
    }
    
    @RouteAPI("community/api/", baseURL: URL(string: "https://www.tinytap.com/")!)
    enum Communityu {
//        @HTTP(.get, path: .parameter("id")) case configurations(id: Int)
        @HTTP(.get, path: "configuration", "user", .parameter("id")) case configurations(id: Int)
    }
}

extension CNPath {
    static let community: CNPath = "community/api/"
    static let account: CNPath = "account/api/"
    
    static let login: CNPath = "login"
    static let configurations: CNPath = "configurations"
}
