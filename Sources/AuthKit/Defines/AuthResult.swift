//
//  AuthResult.swift
//
//
//  Created by Bình Nguyễn Thanh on 06/01/2023.
//

import AuthenticationServices
import Foundation

public struct SocialSignInUser {
    public let email: String
    /// The user's full name.
    public let fullName: String?
    public let givenName: String?
    public let familyName: String?

    public init(email: String, fullName: String? = nil, givenName: String? = nil, familyName: String? = nil) {
        self.email = email
        self.fullName = fullName
        self.givenName = givenName
        self.familyName = familyName
    }
}

public enum ProviderLoginInfo {
    case apple(authorization: ASAuthorization)
    case google(googleUser: SocialSignInUser?)
}

public struct AuthResult {
    public let user: AuthUser
    public let additionalInfo: ProviderLoginInfo?

    public init(user: AuthUser, additionalInfo: ProviderLoginInfo? = nil) {
        self.user = user
        self.additionalInfo = additionalInfo
    }
}
