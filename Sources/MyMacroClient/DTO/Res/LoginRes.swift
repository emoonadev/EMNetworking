//
//  Untitled.swift
//  MyMacro
//
//  Created by Mickael Belhassen on 05/08/2024.
//

import Foundation

import Foundation

struct LoginRes: Codable {
    let noncustodialAddress: String?
    let bigPicture: String
    let lastName: String
    let loginStatus: Int
    let bio: String
    let creationDt: String
    let rank: Int
    let referralCode: String
    let isStaff: Bool
    let userTypeID: Int
    let id: Int
    let totalCredits: Int
    let firstName: String
    let modelName: String
    let googleID: Int
    let preferedAgeGroup: Int
    let feedUnread: Int
    let childNickname: String
    let facebookID: Int
    let dateOfBirth: String
    let subscriptionChannel: String
    let subscriptionStatus: String
    let pictureUpdateDt: String?
    let newToken: String
    let kycApproved: Bool
    let email: String
    let username: String
    let picture: String
    let getPrivacyPolicyConsent: String
    let registered: Bool
    let coverPhoto: String
    let userType: String
    let playsCount: Int
    let openAssignments: Int
    let totalAssignments: Int
    let subAccounts: [SubAccount]
    let certified: Bool
    let preferedLanguage: Int
    let oldToken: String
    let gender: String?
    let userPK: Int
    let token: String
    let isSubscribedToMarketing: Int
    let wasPro: Bool
    let permissions: [String]
    let isTrialing: Bool
    let isPro: Bool
    let getMarketingConsent: Bool

    enum CodingKeys: String, CodingKey {
        case noncustodialAddress = "noncustodial_address"
        case bigPicture = "big_picture"
        case lastName = "last_name"
        case loginStatus = "login_status"
        case bio
        case creationDt = "creation_dt"
        case rank
        case referralCode = "referral_code"
        case isStaff = "is_staff"
        case userTypeID = "user_type_id"
        case id
        case totalCredits = "total_credits"
        case firstName = "first_name"
        case modelName
        case googleID = "google_id"
        case preferedAgeGroup = "prefered_age_group"
        case feedUnread = "feed_unread"
        case childNickname = "child_nickname"
        case facebookID = "facebook_id"
        case dateOfBirth = "date_of_birth"
        case subscriptionChannel = "subscription_channel"
        case subscriptionStatus = "subscription_status"
        case pictureUpdateDt = "picture_update_dt"
        case newToken = "new_token"
        case kycApproved = "kyc_approved"
        case email
        case username
        case picture
        case getPrivacyPolicyConsent = "get_privacy_policy_consent"
        case registered
        case coverPhoto = "cover_photo"
        case userType = "user_type"
        case playsCount = "plays_count"
        case openAssignments = "open_assignments"
        case totalAssignments = "total_assignments"
        case subAccounts = "sub_accounts"
        case certified
        case preferedLanguage = "prefered_language"
        case oldToken = "old_token"
        case gender
        case userPK = "user_pk"
        case token
        case isSubscribedToMarketing = "is_subscribed_to_marketing"
        case wasPro = "was_pro"
        case permissions
        case isTrialing = "is_trialing"
        case isPro = "is_pro"
        case getMarketingConsent = "get_marketing_consent"
    }
}

struct SubAccount: Codable {
    let color: Int
    let id: Int
    let user: User
}

struct User: Codable {
    let lastName: String
    let picture: String
    let firstName: String
    let modelName: String
    let bio: String
    let gender: String?
    let username: String
    let coverPhoto: String
    let creationDt: String
    let rank: Int
    let userType: String
    let userPK: Int
    let userTypeID: Int
    let playsCount: Int
    let isStaff: Bool
    let preferedAgeGroup: Int
    let pictureUpdateDt: String?
    let referralCode: String
    let id: Int
    let certified: Bool
    let preferedLanguage: Int

    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case picture
        case firstName = "first_name"
        case modelName
        case bio
        case gender
        case username
        case coverPhoto = "cover_photo"
        case creationDt = "creation_dt"
        case rank
        case userType = "user_type"
        case userPK = "user_pk"
        case userTypeID = "user_type_id"
        case playsCount = "plays_count"
        case isStaff = "is_staff"
        case preferedAgeGroup = "prefered_age_group"
        case pictureUpdateDt = "picture_update_dt"
        case referralCode = "referral_code"
        case id
        case certified
        case preferedLanguage = "prefered_language"
    }
}
