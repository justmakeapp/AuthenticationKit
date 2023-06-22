import Foundation

public protocol AuthUser {
    var userID: String { get }
    var email: String? { get }
    var isAnonymous: Bool { get }

    var displayName: String? { get }
    var givenName: String? { get }
    var familyName: String? { get }

    var creationDate: Date? { get }

    var authProviderLinks: [AuthProviderLink] { get }
}
