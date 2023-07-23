//
//  Created by longvu on 19/05/2022.
//

import AuthKit
import Combine
import CryptoKit

public struct AppleAuthResult {
    public let idToken: String
    public let nonce: String
}

import AuthenticationServices

public class AppleProvider: NSObject {
    private var authorizationSubject: PassthroughSubject<ASAuthorization, Error> = .init()

    // Unhashed nonce.
    private var currentUnhashedNonce: String?

    public func startSignInWithAppleFlow(
        delegate: ASAuthorizationControllerDelegate? = nil,
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil
    ) -> AnyPublisher<ASAuthorization, Error> {
        authorizationSubject = .init()
        let nonce = Self.randomNonceString()
        currentUnhashedNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        if let delegate {
            authorizationController.delegate = delegate
        } else {
            authorizationController.delegate = self
        }

        if let presentationContextProvider {
            authorizationController.presentationContextProvider = presentationContextProvider
        }

        authorizationController.performRequests()
        return authorizationSubject.eraseToAnyPublisher()
    }

    // MARK: - Helper

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    public static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    public static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

extension AppleProvider: ASAuthorizationControllerDelegate {
    public func makeAuthCredential(from authorization: ASAuthorization) -> AppleAuthResult? {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:

            guard let nonce = currentUnhashedNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return nil
            }

            return AppleAuthResult(idToken: idTokenString, nonce: nonce)
        default:
            return nil
        }
    }

    public func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        authorizationSubject.send(authorization)
    }

    public func authorizationController(controller _: ASAuthorizationController,
                                        didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        authorizationSubject.send(completion: .failure(error))
    }
}
