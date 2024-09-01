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
    var auth: String
    var password: String
    var kidNickName: String?
    var languageID: Int?
    var ageGroupID: Int?
    var userType: Int?
}
