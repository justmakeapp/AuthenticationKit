//
//  AmplifyAuthenticationService+iOS.swift
//
//
//  Created by longvu on 23/06/2023.
//

#if os(iOS)
    import Amplify
    import AuthKit
    import AuthKitUI
    import Combine
    import Foundation
    import UIKit

    public extension AmplifyAuthenticationService {
        func signIn(
            with provider: OAuthSignInProvider,
            presentingViewController: UIViewController
        ) async throws -> AuthResult {
            guard let currentWindow = await presentingViewController.view.window else {
                throw NSError(
                    domain: "",
                    code: 1_000,
                    userInfo: [NSLocalizedDescriptionKey: "UI is not ready, cannot signin!"]
                )
            }

            let authProvider: AmplifyAuthProvider = {
                switch provider {
                case .google:
                    return .google
                case .apple:
                    return .apple
                }
            }()

            _ = try await Amplify.Auth.signInWithWebUI(
                for: authProvider,
                presentationAnchor: currentWindow,
                options: .preferPrivateSession()
            )

            let user = try await Self.getAmplifyUserFromRemote()
            return AuthResult(user: user)
        }

        func signIn(
            with provider: OAuthSignInProvider,
            presentingViewController: UIViewController
        ) -> AnyPublisher<AuthResult, Error> {
            return Deferred {
                Future<AuthResult, Error> { promise in
                    Task {
                        do {
                            let result = try await self.signIn(
                                with: provider,
                                presentingViewController: presentingViewController
                            )
                            promise(.success(result))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }.eraseToAnyPublisher()
        }

        func reauthenticate(
            with _: OAuthSignInProvider,
            presentingViewController _: UIViewController
        ) async throws -> AuthResult? {
            throw NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Not implemented"]
            )
        }

        func reauthenticate(
            with provider: OAuthSignInProvider,
            presentingViewController: UIViewController
        ) -> AnyPublisher<AuthResult, Error> {
            return Deferred {
                Future<AuthResult, Error> { promise in
                    Task {
                        do {
                            let result = try await self.signIn(
                                with: provider,
                                presentingViewController: presentingViewController
                            )
                            promise(.success(result))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }.eraseToAnyPublisher()
        }
    }
#endif
