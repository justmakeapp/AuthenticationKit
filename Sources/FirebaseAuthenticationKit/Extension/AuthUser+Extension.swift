//
//  AuthUser+Extension.swift
//
//
//  Created by Bình Nguyễn Thanh on 11/12/2022.
//

import AuthKit
import FirebaseAuth
import Foundation

extension FirebaseAuth.User: AuthUser {
    private var nameComponents: PersonNameComponents? {
        guard let displayName else {
            return nil
        }
        let formatter = PersonNameComponentsFormatter()
        return formatter.personNameComponents(from: displayName)
    }

    public var givenName: String? {
        return nameComponents?.givenName
    }

    public var familyName: String? {
        return nameComponents?.familyName
    }

    public var userID: String {
        return self.uid
    }

    public var creationDate: Date? {
        return self.metadata.creationDate
    }

    public var authProviderLinks: [AuthProviderLink] {
        return providerData.compactMap { firebaseUserInfo -> AuthProviderLink? in
            switch firebaseUserInfo.providerID {
            case FirebaseAuth.GoogleAuthProviderID:
                return .init(email: firebaseUserInfo.email, isLinked: true, provider: .google)

            case FirebaseAuth.EmailAuthProviderID:
                return .init(email: firebaseUserInfo.email, isLinked: true, provider: .email)

            case "apple.com":
                return .init(email: firebaseUserInfo.email, isLinked: true, provider: .apple)

            default:
                return nil
            }
        }
    }
}
