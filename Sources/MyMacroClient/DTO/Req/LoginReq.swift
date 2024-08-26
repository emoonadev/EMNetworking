//
//  LoginReq.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation
import MyMacro

@EMCodable()
struct LoginReq {
    var auth: String
    var password: String
    @EMCodingKey("kid_nickname") var kidNickName: String
    @EMCodingKey("language_id") var languageID: Int
    @EMCodingKey("age_group_id") var ageGroupID: Int
}
