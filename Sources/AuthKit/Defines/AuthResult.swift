//
//  File.swift
//
//
//  Created by Bình Nguyễn Thanh on 06/01/2023.
//

import Foundation

#if os(iOS)
    import AuthenticationServices
#endif

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
    #if os(iOS)
        case apple(authorization: ASAuthorization)
    #endif

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
