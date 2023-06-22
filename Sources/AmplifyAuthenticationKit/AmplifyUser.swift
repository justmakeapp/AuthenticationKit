//
//  File.swift
//
//
//  Created by Bình Nguyễn Thanh on 13/12/2022.
//

import AuthKit
import Foundation

// Amplify does not expose an usable user struct/class, so we must implement ourself
public struct AmplifyUser: AuthUser {
    public let userID: String
    public let email: String?
    public let isAnonymous: Bool
    public let displayName: String?
    public var givenName: String?
    public var familyName: String?
    public let creationDate: Date?

    public let authProviderLinks: [AuthProviderLink] = []
}
