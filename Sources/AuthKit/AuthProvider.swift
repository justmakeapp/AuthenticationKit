// Created 06/02/2022

public enum AuthProvider: Hashable, CaseIterable {
    case apple
    case google
    case email

    public var identifier: String {
        switch self {
        case .apple:
            return "apple.com"
        case .email:
            return "email"
        case .google:
            return "google"
        }
    }
}

public struct AuthProviderLink: Hashable {
    public var email: String?
    public var isLinked: Bool
    public var provider: AuthProvider

    public init(email: String?, isLinked: Bool, provider: AuthProvider) {
        self.email = email
        self.isLinked = isLinked
        self.provider = provider
    }
}

public enum LinkMethod {
    case withEmailPassword(email: String, password: String)
    case withEmailLink(email: String, link: String)
    case withGoogle(idToken: String, accessToken: String)
    case withApple(idToken: String, nonce: String)
}

public enum OAuthSignInProvider {
    case google
    case apple
}

public enum BasicSignInProvider {
    case anonymous
    case emailAndPassword(email: String, password: String)
    case emailLink(email: String, link: String)
}
