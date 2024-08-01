//
//  LoginReq.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

struct LoginReq: Codable {
    var auth: String
    var password: String
    var kidNickName: String
    var languageID: Int
    var ageGroupID: Int
    
    enum CodingKeys: String, CodingKey {
        case auth, password, kidNickName = "kid_nickname", languageID = "language_id", ageGroupID = "age_group_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(auth, forKey: .auth)
        try container.encode(password, forKey: .password)
        try container.encode(kidNickName, forKey: .kidNickName)
        try container.encode(languageID, forKey: .languageID)
        try container.encode(ageGroupID, forKey: .ageGroupID)
    }
}
