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

public enum GoogleProvider {
    @MainActor
    public static func getCredential(
        presentingView: PlatformPresentingView
    ) async throws -> GoogleAuthResult {
        let user = try await requestGoogleAuthentication(presentingView: presentingView)

        guard let result = makeGoogleAuthResult(from: user) else {
            throw "Can not make google auth result"
        }

        return result
    }

    public static func getCredential(
        presentingView: PlatformPresentingView
    ) -> AnyPublisher<GoogleAuthResult, Error> {
        requestGoogleAuthentication(presentingView: presentingView)
            .compactMap { user -> GoogleAuthResult? in
                guard let user else {
                    return nil
                }

                return makeGoogleAuthResult(from: user)
            }
            .eraseToAnyPublisher()
    }

    private static func makeGoogleAuthResult(from user: GIDGoogleUser) -> GoogleAuthResult? {
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

    @MainActor
    private static func requestGoogleAuthentication(
        presentingView: PlatformPresentingView
    ) async throws -> GIDGoogleUser {
        let gidInstance = GIDSignIn.sharedInstance
        let result = try await gidInstance.signIn(withPresenting: presentingView)
        return result.user
    }

    private static func requestGoogleAuthentication(
        presentingView: PlatformPresentingView
    ) -> AnyPublisher<GIDGoogleUser?, Error> {
        let gidInstance = GIDSignIn.sharedInstance
        return Deferred {
            Future<GIDGoogleUser?, Error> { promise in
                gidInstance.signIn(withPresenting: presentingView) { result, error in
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
