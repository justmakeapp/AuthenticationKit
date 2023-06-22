// Created 06/02/2022

import Foundation

public class AuthKitUI {
    public static let shared = AuthKitUI()

    private(set) var googleClientID: String?

    private let lockQueue = DispatchQueue(label: "AuthKitUI.Queue")

    private init() {}

    public func setGoogleClientID(_ googleClientID: String) {
        lockQueue.sync {
            self.googleClientID = googleClientID
        }
    }
}
