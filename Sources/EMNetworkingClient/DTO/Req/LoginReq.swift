//
//  LoginReq.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation
import EMNetworking

@EMCodable(codingKeyStrategy: .snakeCase)
struct LoginReq {
    var languageID: LoginReq.User?
    
    @EMCodable(codingKeyStrategy: .snakeCase)
    struct User {
        var test: String
    }
}
