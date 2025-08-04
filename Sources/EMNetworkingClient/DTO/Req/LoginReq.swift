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
    var languageID: Int = 1
    var auth: String = "mickael@tinytap.com"
    var password: String = "capoeira"
}
