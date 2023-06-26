//
//  Authenticating.swift
//
//
//  Created by Long Vu on 22/05/2022.
//

import Combine
#if canImport(UIKit)
    import UIKit
#endif

public protocol Authenticating {
    func getCurrentUser() -> AuthUser?
    func userIDToken() async throws -> String?
    func addUserDidChangeListener(_ completion: @escaping (_ user: AuthUser?) -> Void)

    func signIn(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error>
    func signIn(with provider: BasicSignInProvider) async throws -> AuthResult

    #if canImport(UIKit)
        func signIn(with provider: OAuthSignInProvider, presentingViewController: UIViewController)
            -> AnyPublisher<AuthResult, Error>
    #endif
    func signIn(with provider: OAuthSignInProvider) async throws -> AuthResult

    func signOut() async throws
    func createUser(with email: String, password: String) async throws -> AuthResult
    func resetPassword(with email: String) async throws

    func sendEmailVeritification() async throws
    func unlink(from providerID: String) async throws -> AuthUser?
    func link(_ method: LinkMethod) async throws -> AuthResult?
    func deleteUser() async throws

    func reauthenticate(with provider: BasicSignInProvider) async throws -> AuthResult
    func reauthenticate(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error>

    #if canImport(UIKit)
        func reauthenticate(with provider: OAuthSignInProvider, presentingViewController: UIViewController)
            -> AnyPublisher<AuthResult, Error>
    #endif
}

public extension Authenticating {
    func sendEmailVeritification() async throws {}
    func unlink(from _: String) async throws -> AuthUser? {
        return nil
    }

    func link(_: LinkMethod) async throws -> AuthResult? {
        return nil
    }

    func deleteUser() async throws {}
}
