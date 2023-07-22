// Created 06/02/2022

import AuthKit
import Combine
import Foundation
import GoogleSignIn

public struct GoogleAuthResult {
    public let idToken: String
    public let accessToken: String
    public let user: SocialSignInUser?
}

#if canImport(UIKit)
    import UIKit.UIViewController

    public enum GoogleProvider {
        public static func getCredential(
            clientID: String,
            presentingViewController: UIViewController
        ) -> AnyPublisher<GoogleAuthResult, Error> {
            requestGoogleAuthentication(
                clientID: clientID,
                presentingViewController: presentingViewController
            )
            .compactMap { user -> GoogleAuthResult? in
                guard let user else {
                    return nil
                }

                guard let idToken = user.idToken?.tokenString else {
                    return nil
                }

                let socialUser: SocialSignInUser? = {
                    guard let profile = user.profile else {
                        return nil
                    }
                    return SocialSignInUser(
                        email: profile.email,
                        fullName: profile.name,
                        givenName: profile.givenName,
                        familyName: profile.familyName
                    )
                }()

                return GoogleAuthResult(
                    idToken: idToken,
                    accessToken: user.accessToken.tokenString,
                    user: socialUser
                )
            }
            .eraseToAnyPublisher()
        }

        private static func requestGoogleAuthentication(
            clientID _: String,
            presentingViewController: UIViewController
        ) -> AnyPublisher<GIDGoogleUser?, Error> {
            let gidInstance = GIDSignIn.sharedInstance
            return Deferred {
                Future<GIDGoogleUser?, Error> { promise in
                    gidInstance.signIn(withPresenting: presentingViewController) { result, error in
                        if let error {
                            promise(.failure(error))
                            return
                        }
                        promise(.success(result?.user))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }
#endif
