//
//  Authenticating.swift
//
//
//  Created by Long Vu on 22/05/2022.
//

import Combine

#if canImport(UIKit)
    import UIKit

    public typealias PlatformPresentingView = UIViewController
#endif

#if canImport(AppKit)
    import AppKit.NSWindow

    public typealias PlatformPresentingView = NSWindow
#endif

public protocol Authenticating {
    func getCurrentUser() -> AuthUser?
    func userIDToken() async throws -> String?
    func addUserDidChangeListener(_ completion: @escaping (_ user: AuthUser?) -> Void)

    func signIn(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error>
    func signIn(with provider: BasicSignInProvider) async throws -> AuthResult

    func signIn(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) -> AnyPublisher<AuthResult, Error>
    func signIn(with provider: OAuthSignInProvider) async throws -> AuthResult
    func signIn(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) async throws -> AuthResult

    func signOut() async throws
    func createUser(with email: String, password: String) async throws -> AuthResult
    func resetPassword(with email: String) async throws

    func sendEmailVeritification() async throws
    func unlink(from providerID: String) async throws -> AuthUser?
    func link(_ method: LinkMethod) async throws -> AuthResult?
    func deleteUser() async throws

    func reauthenticate(with provider: BasicSignInProvider) async throws -> AuthResult
    func reauthenticate(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error>

    func reauthenticate(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) -> AnyPublisher<AuthResult, Error>

    func reauthenticate(
        with provider: OAuthSignInProvider
    ) async throws -> AuthResult

    func reauthenticate(
        with provider: OAuthSignInProvider,
        presentingView: PlatformPresentingView
    ) async throws -> AuthResult

    func revokeAppleToken() async throws
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

    @MainActor
    func signIn(with provider: OAuthSignInProvider) async throws -> AuthResult {
        guard let presentingView = Self.getPresentingView() else {
            throw NSError(
                domain: String(describing: Authenticating.self),
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Not found presenting view"]
            )
        }
        return try await signIn(with: provider, presentingView: presentingView)
    }

    @MainActor
    func reauthenticate(
        with provider: OAuthSignInProvider
    ) async throws -> AuthResult {
        guard let presentingView = Self.getPresentingView() else {
            throw NSError(
                domain: String(describing: Authenticating.self),
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Not found presenting view"]
            )
        }
        return try await reauthenticate(with: provider, presentingView: presentingView)
    }

    @MainActor
    private static func getPresentingView() -> PlatformPresentingView? {
        #if os(iOS)
            let keyWindow: UIWindow? = {
                if #available(iOS 15.0, *) {
                    return UIApplication.shared.connectedScenes
                        // Keep only active scenes, onscreen and visible to the user
                        .filter { $0.activationState == .foregroundActive }
                        // Keep only the first `UIWindowScene`
                        .first(where: { $0 is UIWindowScene })
                        // Get its associated windows
                        .flatMap { $0 as? UIWindowScene }?.windows
                        // Finally, keep only the key window
                        .first(where: \.isKeyWindow)
                } else {
                    return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
                }
            }()

            guard var topController = keyWindow?.rootViewController else {
                return nil
            }

            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        #endif

        #if os(macOS)
            guard let presentingWindow = NSApplication.shared.windows.first else {
                return nil
            }

            return presentingWindow
        #endif
    }
}
