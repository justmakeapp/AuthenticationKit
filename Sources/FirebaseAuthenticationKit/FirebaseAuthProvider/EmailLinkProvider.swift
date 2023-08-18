//
//  EmailLinkProvider.swift
//
//
//  Created by Long Vu on 12/06/2022.
//

import Combine
import FirebaseAuth

public final class EmailLinkProvider {
    let auth: Auth = .auth()

    public init() {}

    public static func makeActionCodeSettings(
        continueURL embeddedDeepLink: URL?,
        handleCodeInApp: Bool = true,
        bundleID: String,
        dynamicLinkDomain: String?
    ) -> ActionCodeSettings {
        let actionCodeSettings = ActionCodeSettings()

        /// The deep link to embed and any additional state to be passed along. (Continue URL)
        /// The link's domain has to be whitelisted in the Firebase Console list of authorized domains, which can be
        // found by going to the Sign-in method tab (Authentication -> Sign-in method).
        /// This makes it possible for a user to continue right where they left off after an email action.
        actionCodeSettings.url = embeddedDeepLink

        /// handleCodeInApp: Set to true.
        /// The sign-in operation has to always be completed in the app unlike other out of band email actions (password
        // reset and email verifications).
        /// This is because, at the end of the flow, the user is expected to be signed in and their Auth state persisted
        // within the app.
        actionCodeSettings.handleCodeInApp = handleCodeInApp

        actionCodeSettings.setIOSBundleID(bundleID)

        /// When multiple custom dynamic link domains are defined, specify which one to use.
        actionCodeSettings.dynamicLinkDomain = dynamicLinkDomain

        return actionCodeSettings
    }

    public func sendSignInLink(
        to email: String,
        actionCodeSettings: ActionCodeSettings
    ) -> AnyPublisher<Bool, Error> {
        let auth = self.auth
        return Deferred {
            Future<Bool, Error> { promise in
                auth.sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
                    if let error {
                        promise(.failure(error))
                    } else {
                        promise(.success(true))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    public static func makeCredential(email: String, link: String) -> AuthCredential {
        return EmailAuthProvider.credential(withEmail: email, link: link)
    }

    public func sendSignInLink(
        to email: String,
        actionCodeSettings: ActionCodeSettings
    ) async throws {
        try await auth.sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
    }

    func signIn(with email: String, link: String) async throws -> AuthDataResult {
        return try await auth.signIn(withEmail: email, link: link)
    }

    func signIn(with email: String, link: String) -> AnyPublisher<AuthDataResult, Error> {
        return Deferred {
            Future<AuthDataResult, Error> { promise in
                self.auth.signIn(withEmail: email, link: link) { authDataResult, error in
                    if let error {
                        promise(.failure(error))
                    }
                    if let authResult = authDataResult {
                        promise(.success(authResult))
                    } else {
                        let error = NSError(
                            domain: "",
                            code: 1_000,
                            userInfo: [NSLocalizedDescriptionKey: "Content can not be empty!"]
                        )
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
