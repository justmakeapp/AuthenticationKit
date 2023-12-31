//
//  FirebaseAuthenticationService+OauthProvider.swift
//
//
//  Created by longvu on 23/06/2023.
//

import AuthKit
import AuthKitUI
import Combine
import Firebase
import Foundation

public extension FirebaseAuthenticationService {
    // MARK: - Sign in

    func signIn(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) async throws -> AuthResult {
        let (authCredential, additionalInfo) = try await signInAndGetCredentialOAuth2(
            from: provider,
            presentingView: presentingView
        )
        let authResult = try await auth.signIn(with: authCredential)
        return AuthResult(
            user: authResult.user,
            additionalInfo: additionalInfo
        )
    }

    func signIn(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) -> AnyPublisher<AuthResult, Error> {
        signInAndGetCredentialOAuth2(from: provider, presentingView: presentingView)
            .map { authCredential, additionalInfo -> AnyPublisher<AuthResult, Error> in
                return Deferred {
                    Future<AuthResult, Error> { promise in
                        let unknownError = NSError(
                            domain: Bundle.main.bundleIdentifier!,
                            code: 1_000,
                            userInfo: [NSLocalizedDescriptionKey: "Cannot login!"]
                        )

                        self.auth.signIn(with: authCredential) { authResult, error in
                            if let error {
                                promise(.failure(error))
                                return
                            }
                            guard let authResult else {
                                promise(.failure(unknownError))
                                return
                            }
                            promise(.success(AuthResult(user: authResult.user, additionalInfo: additionalInfo)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    // MARK: - Reauthenticate

    func reauthenticate(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) async throws -> AuthResult {
        guard let currentUser = auth.currentUser else {
            let error = NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Can not found user!"]
            )
            throw error
        }

        let (authCredential, additionalInfo) = try await signInAndGetCredentialOAuth2(
            from: provider,
            presentingView: presentingView
        )

        let authResult = try await currentUser.reauthenticate(with: authCredential)
        return AuthResult(
            user: authResult.user,
            additionalInfo: additionalInfo
        )
    }

    func reauthenticate(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) -> AnyPublisher<AuthResult, Error> {
        guard let currentUser = auth.currentUser else {
            let error = NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Can not found user!"]
            )
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return signInAndGetCredentialOAuth2(from: provider, presentingView: presentingView)
            .map { authCredential, _ -> AnyPublisher<AuthResult, Error> in
                return Deferred {
                    Future<AuthResult, Error> { promise in
                        currentUser.reauthenticate(with: authCredential) { authResult, error in
                            if let error {
                                promise(.failure(error))
                                return
                            }
                            guard let authResult else {
                                let error = NSError(
                                    domain: Bundle.main.bundleIdentifier!,
                                    code: 1_000,
                                    userInfo: [NSLocalizedDescriptionKey: "Content can not be empty!"]
                                )

                                promise(.failure(error))
                                return
                            }
                            promise(.success(AuthResult(user: authResult.user)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    // MARK: - RevokeToken

    func revokeAppleToken() async throws {
        let provider = AppleProvider()

        let authorization = try await provider.startSignInWithAppleFlow()

        guard let appleAuthCode = try provider.makeAppleAuthCode(from: authorization) else {
            let error = NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Can not get apple authorization code"]
            )
            throw error
        }

        try await auth.revokeToken(withAuthorizationCode: appleAuthCode)
    }

    // MARK: - Link

    func link(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) async throws -> AuthResult {
        switch provider {
        case .google:
            let googleAuthResult = try await GoogleProvider.getCredential(
                presentingView: presentingView
            )
            guard let authResult = try await link(.withGoogle(
                idToken: googleAuthResult.idToken,
                accessToken: googleAuthResult.accessToken
            )) else {
                throw "Can not link google with \(googleAuthResult)"
            }
            return authResult

        case .apple:
            let provider = AppleProvider()
            let authorization = try await provider.startSignInWithAppleFlow()

            guard let result = provider.makeAuthCredential(from: authorization) else {
                let error = NSError(
                    domain: "",
                    code: 1_000,
                    userInfo: [NSLocalizedDescriptionKey: "Can not authenticate with Apple"]
                )
                throw error
            }

            guard let authResult = try await link(
                .withApple(idToken: result.idToken, nonce: result.nonce)
            ) else {
                throw "Can not link apple with \(result)"
            }

            return authResult
        }
    }

    // MARK: - Helpers

    private func signInAndGetCredentialOAuth2(
        from provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) async throws -> (AuthCredential, ProviderLoginInfo) {
        switch provider {
        case .google:
            let googleAuthResult = try await GoogleProvider.getCredential(
                presentingView: presentingView
            )

            let credential = GoogleAuthProvider.credential(
                withIDToken: googleAuthResult.idToken,
                accessToken: googleAuthResult.accessToken
            )
            return (credential, .google(googleUser: googleAuthResult.user))

        case .apple:

            let provider = AppleProvider()
            let authorization = try await provider.startSignInWithAppleFlow()

            guard let result = provider.makeAuthCredential(from: authorization) else {
                let error = NSError(
                    domain: "",
                    code: 1_000,
                    userInfo: [NSLocalizedDescriptionKey: "Can not authenticate with Apple"]
                )
                throw error
            }

            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: result.idToken,
                rawNonce: result.nonce
            )

            return (credential, .apple(authorization: authorization))
        }
    }

    private func signInAndGetCredentialOAuth2(
        from provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) -> AnyPublisher<(AuthCredential, ProviderLoginInfo), Error> {
        switch provider {
        case .google:
            return GoogleProvider.getCredential(
                presentingView: presentingView
            )
            .map { googleAuthResult in
                let credential = GoogleAuthProvider.credential(
                    withIDToken: googleAuthResult.idToken,
                    accessToken: googleAuthResult.accessToken
                )
                return (credential, .google(googleUser: googleAuthResult.user))
            }
            .eraseToAnyPublisher()

        case .apple:
            let provider = AppleProvider()
            return provider.startSignInWithAppleFlow()
                .tryMap {
                    guard let result = provider.makeAuthCredential(from: $0) else {
                        let error = NSError(
                            domain: "",
                            code: 1_000,
                            userInfo: [NSLocalizedDescriptionKey: "Can not authenticate with Apple"]
                        )
                        throw error
                    }

                    let credential = OAuthProvider.credential(
                        withProviderID: "apple.com",
                        idToken: result.idToken,
                        rawNonce: result.nonce
                    )

                    return (credential, .apple(authorization: $0))
                }
                .eraseToAnyPublisher()
        }
    }
}
