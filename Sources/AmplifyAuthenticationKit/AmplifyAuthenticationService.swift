//
//  AmplifyAuthenticationService.swift
//
//
//  Created by Bình Nguyễn Thanh on 12/12/2022.
//

import Amplify
import AuthKit
import AuthKitUI
import AWSCognitoAuthPlugin
import AWSCognitoIdentityProvider
import Combine
import CombineExt
import Foundation

public final class AmplifyAuthenticationService: Authenticating {
    private var currentUserSubject: CurrentValueSubject<AuthKit.AuthUser?, Never> = .init(nil)
    private var cancellableSet: Set<AnyCancellable> = []

    public init() {
        addUserDidChangeListener { [weak self] user in
            self?.currentUserSubject.send(user)
        }
    }

    deinit {
        cancellableSet = []
    }

    public func userIDToken() async throws -> String? {
        // TODO: implement this
        return nil
    }

    public func getCurrentUser() -> AuthKit.AuthUser? {
        return currentUserSubject.value
    }

    public func addUserDidChangeListener(_ completion: @escaping (AuthKit.AuthUser?) -> Void) {
        _ = Amplify.Hub.listen(to: .auth) { payload in
            switch payload.eventName {
            case HubPayload.EventName.Auth.signedIn,
                 HubPayload.EventName.Auth.federateToIdentityPoolAPI:
                Task {
                    let user = try? await Self.getAmplifyUserFromRemote()
                    completion(user)
                }

            case HubPayload.EventName.Auth.sessionExpired,
                 HubPayload.EventName.Auth.signedOut,
                 HubPayload.EventName.Auth.userDeleted,
                 HubPayload.EventName.Auth.clearedFederationToIdentityPoolAPI:
                completion(nil)

            default:
                break
            }
        }

        // Always emit current user after listen to change
        Task {
            let user = try? await Self.getAmplifyUserFromRemote()
            completion(user)
        }
    }

    public func signIn(with provider: BasicSignInProvider) async throws -> AuthResult {
        switch provider {
        case let .emailAndPassword(email: email, password: password):
            return try await signInWithEmailAndPassword(email: email, password: password)
        default:
            throw NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Sign in provider \(provider) not implemented"]
            )
        }
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

    public func signIn(with provider: OAuthSignInProvider) async throws -> AuthResult {
        let signInResult: AuthSignInResult = try await Amplify.Auth.signInWithWebUI(for: {
            switch provider {
            case .google:
                return .google
            case .apple:
                return .apple
            }
        }())

        guard signInResult.isSignedIn else {
            throw NSError(
                domain: "AmplifyAuthenticationKit",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "isSignedIn is false"]
            )
        }

        let user = try await Self.getAmplifyUserFromRemote()
        let result = AuthResult(user: user)
        return result
    }

    private func signInWithEmailAndPassword(email: String, password: String) async throws -> AuthResult {
        do {
            let option = AWSAuthSignInOptions(authFlowType: .userPassword)
            _ = try await Amplify.Auth.signIn(
                username: email,
                password: password,
                options: .init(pluginOptions: option)
            )
            let user = try await Self.getAmplifyUserFromRemote()
            return AuthResult(user: user)
        } catch {
            if let authError = error as? AuthError,
               let cognitoError = authError.underlyingError as? AWSCognitoAuthError,
               case .userNotFound = cognitoError {
                return try await createUser(with: email, password: password)
            }
            throw error
        }
    }

    public func signOut() async throws {
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult else {
            throw NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Sign out failed!"]
            )
        }

        switch signOutResult {
        case .complete, .partial:
            currentUserSubject.send(nil)
            return
        case let .failed(error):
            throw error
        }
    }

    public func reauthenticate(with _: BasicSignInProvider) async throws -> AuthResult {
        throw NSError(
            domain: "",
            code: 1_000,
            userInfo: [NSLocalizedDescriptionKey: "Not implemented"]
        )
    }

    public func reauthenticate(with provider: BasicSignInProvider) -> AnyPublisher<AuthResult, Error> {
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

    public func createUser(with email: String, password: String) async throws -> AuthResult {
        let result = try await Amplify.Auth.signUp(username: email, password: password, options: .init(userAttributes: [
            .init(.email, value: email)
        ]))

        guard result.isSignUpComplete else {
            print("Create user failed with result: ", result)
            throw NSError(
                domain: "",
                code: 1_000,
                userInfo: [NSLocalizedDescriptionKey: "Signup failed!"]
            )
        }

        let option = AWSAuthSignInOptions(authFlowType: .userPassword)
        _ = try await Amplify.Auth.signIn(
            username: email,
            password: password,
            options: .init(pluginOptions: option)
        )
        let user = try await Self.getAmplifyUserFromRemote()
        return AuthResult(user: user)
    }

    public func resetPassword(with _: String) async throws {
        // TODO: implement this
//        let resetResult = try await Amplify.Auth.resetPassword(for: email)
//        switch resetResult.nextStep {
//        case let .confirmResetPasswordWithCode(deliveryDetails, info):
//            debugPrint("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
//        case .done:
//            debugPrint("Reset completed")
//        }
    }

    public func sendEmailVeritification() async throws {
        // TODO: implement this
    }

    public func unlink(from _: String) async throws -> AuthKit.AuthUser? {
        // TODO: implement this
        return nil
    }

    public func link(_: LinkMethod) async throws -> AuthResult? {
        // TODO: implement this
        return nil
    }

    public func deleteUser() async throws {
        return try await Amplify.Auth.deleteUser()
    }

    public static func authProviderLinks(from _: AuthKit.AuthUser?) -> [AuthProviderLink] {
        // TODO: implement this
        return []
    }

    static func getAmplifyUserFromRemote() async throws -> AuthKit.AuthUser {
        async let attributesAsync = try Amplify.Auth.fetchUserAttributes()
        async let currentUserAsync = try Amplify.Auth.getCurrentUser()

        let result = try await (attributesAsync, currentUserAsync)
        let attributes = result.0
        let currentUser = result.1

        let attributeMap = [AuthUserAttributeKey: String](
            attributes.map { ($0.key, $0.value) },
            uniquingKeysWith: { first, _ in first }
        )

        let creationDate: Date? = {
            guard let dateString = attributeMap[.custom("createdAt")] else {
                return nil
            }
            return ISO8601DateFormatter().date(from: dateString)
        }()

        let user = AmplifyUser(
            userID: attributeMap[.custom("persistenceUID"), default: currentUser.userId],
            email: attributeMap[.email],
            isAnonymous: false,
            displayName: attributeMap[.name],
            givenName: attributeMap[.givenName],
            familyName: attributeMap[.familyName],
            creationDate: creationDate
        )
        print("Amplify user: ", user)
        return user
    }
}

extension AmplifyAuthenticationService: AuthDataProvider {
    public func authStateDidChangePublisher() -> AnyPublisher<AuthKit.AuthUser?, Never> {
        return currentUserSubject.share(replay: 1).eraseToAnyPublisher()
    }
}
