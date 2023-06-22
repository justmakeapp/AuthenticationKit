// Created 02/02/2022

import AuthKit
import AuthKitUI
import Combine
import Firebase
import FirebaseAuth
import Foundation
import UIKit

public struct FirebaseAuthenticationService: Authenticating {
    let auth: Auth = .auth()

    public var uid: String? {
        auth.currentUser?.uid
    }

    public init() {}

    public func getCurrentUser() -> AuthUser? {
        return auth.currentUser as AuthUser?
    }

    public func userIDToken() async throws -> String? {
        return try await auth.currentUser?.getIDToken()
    }

    public func addUserDidChangeListener(_ completion: @escaping (AuthUser?) -> Void) {
        auth.addStateDidChangeListener { _, user in completion(user) }
    }

    public func signIn(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error> {
        return Deferred {
            Future<AuthResult, Error> { promise in
                Task {
                    do {
                        let result = try await self.signIn(with: provider)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    public func signIn(with provider: BasicSignInProvider) async throws -> AuthResult {
        let authResult = try await {
            switch provider {
            case let .emailAndPassword(email, password):
                return try await auth.signIn(withEmail: email, password: password)
            case let .emailLink(email, link):
                return try await auth.signIn(withEmail: email, link: link)
            case .anonymous:
                return try await auth.signInAnonymously()
            }
        }()

        return AuthResult(from: authResult)
    }

    public func signIn(
        with provider: OAuthSignInProvider,
        presentingViewController: UIViewController
    ) -> AnyPublisher<AuthResult, Error> {
        signInAndGetCredentialOAuth2(from: provider, presentingViewController: presentingViewController)
            .map { authCredential, additionalInfo -> AnyPublisher<AuthResult, Error> in
                return Deferred {
                    Future<AuthResult, Error> { promise in
                        let unknownError = NSError(
                            domain: "",
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

    public func signOut() async throws {
        try auth.signOut()
    }

    // FIXME: - Move to Email and Password provider
    public func createUser(with email: String, password: String) async throws -> AuthResult {
        let result = try await auth.createUser(withEmail: email, password: password)
        return AuthResult(from: result)
    }

    public func resetPassword(with email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    public static func authProviderLinks(from user: AuthUser?) -> [AuthProviderLink] {
        guard let user = user as? User else {
            return []
        }

        let res = user.providerData
            .compactMap { firebaseUserInfo -> AuthProviderLink? in
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

        return res
    }

    public func sendEmailVeritification() async throws {
        try await auth.currentUser?.sendEmailVerification()
    }

    public func unlink(from providerID: String) async throws -> AuthUser? {
        let firebaseProviderID: String = {
            switch providerID {
            case AuthProvider.google.identifier:
                return FirebaseAuth.GoogleAuthProviderID

            case AuthProvider.apple.identifier:
                return "apple.com"

            case AuthProvider.email.identifier:
                return FirebaseAuth.EmailAuthProviderID

            default:
                return providerID
            }
        }()

        return try await auth.currentUser?.unlink(fromProvider: firebaseProviderID)
    }

    public func link(_ method: LinkMethod) async throws -> AuthResult? {
        let firebaseAuthCredential: AuthCredential = {
            switch method {
            case let .withEmailPassword(email, password):
                return EmailAuthProvider.credential(withEmail: email, password: password)

            case let .withEmailLink(email, link):
                return EmailAuthProvider.credential(withEmail: email, link: link)

            case let .withGoogle(idToken, accessToken):
                return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            case let .withApple(idToken, nonce):
                return OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce)
            }
        }()

        guard let result = try await auth.currentUser?.link(with: firebaseAuthCredential) else {
            return nil
        }
        return AuthResult(from: result)
    }

    public func deleteUser() async throws {
        try await auth.currentUser?.delete()
    }

    public func reauthenticate(with provider: BasicSignInProvider) async throws -> AuthResult {
        guard let user = auth.currentUser else {
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Can not found user!"]
            )
            throw error
        }

        let credential = try Self.makeFirebaseAuthCredential(provider)
        let authDataResult = try await user.reauthenticate(with: credential)
        return AuthResult(from: authDataResult)
    }

    public func reauthenticate(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error> {
        return Deferred {
            Future<AuthResult, Error> { promise in
                Task {
                    do {
                        let result = try await self.reauthenticate(with: provider)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func reauthenticate(
        with provider: OAuthSignInProvider,
        presentingViewController: UIViewController
    ) -> AnyPublisher<AuthResult, Error> {
        guard let currentUser = auth.currentUser else {
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Can not found user!"]
            )
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return signInAndGetCredentialOAuth2(from: provider, presentingViewController: presentingViewController)
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
                                    domain: "",
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

    // MARK: - Helpers

    private func signInAndGetCredentialOAuth2(
        from provider: OAuthSignInProvider,
        presentingViewController: UIViewController
    ) -> AnyPublisher<(AuthCredential, ProviderLoginInfo), Error> {
        switch provider {
        case .google:
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                let error = NSError(
                    domain: "",
                    code: 1_000,
                    userInfo: [NSLocalizedDescriptionKey: "Can not authenticate with Google"]
                )
                return Fail(error: error).eraseToAnyPublisher()
            }
            return GoogleProvider.getCredential(clientID: clientID, presentingViewController: presentingViewController)
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

    private static func makeFirebaseAuthCredential(_ provider: BasicSignInProvider) throws -> AuthCredential {
        switch provider {
        case let .emailLink(email, link):
            return EmailAuthProvider.credential(withEmail: email, link: link)
        case let .emailAndPassword(email, password):
            return EmailAuthProvider.credential(withEmail: email, password: password)
        case .anonymous:
            let error = NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Invalid provider!"]
            )
            throw error
        }
    }
}

extension AuthResult {
    init(from firebaseAuthResult: AuthDataResult) {
        self.init(user: firebaseAuthResult.user)
    }
}
