//
//  Authenticating.swift
//
//
//  Created by Long Vu on 22/05/2022.
//

import Combine
import UIKit

public protocol Authenticating {
    func getCurrentUser() -> AuthUser?
    func userIDToken() async throws -> String?
    func addUserDidChangeListener(_ completion: @escaping (_ user: AuthUser?) -> Void)

    func signIn(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error>
    func signIn(with provider: BasicSignInProvider) async throws -> AuthResult

    func signIn(with provider: OAuthSignInProvider, presentingViewController: UIViewController)
        -> AnyPublisher<AuthResult, Error>

    func signOut() async throws
    func createUser(with email: String, password: String) async throws -> AuthResult
    func resetPassword(with email: String) async throws

    func sendEmailVeritification() async throws
    func unlink(from providerID: String) async throws -> AuthUser?
    func link(_ method: LinkMethod) async throws -> AuthResult?
    func deleteUser() async throws

    func reauthenticate(with provider: BasicSignInProvider) async throws -> AuthResult
    func reauthenticate(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error>
    func reauthenticate(with provider: OAuthSignInProvider, presentingViewController: UIViewController)
        -> AnyPublisher<AuthResult, Error>
}
