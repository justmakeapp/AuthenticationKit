//
//  FirebaseAuthenticationService+AuthDataProvider.swift
//
//
//  Created by Long Vu on 26/04/2023.
//

import AuthKit
import Combine
import FirebaseAuthCombineSwift
import Foundation

extension FirebaseAuthenticationService: AuthDataProvider {
    public func authStateDidChangePublisher() -> AnyPublisher<AuthUser?, Never> {
        return auth
            .authStateDidChangePublisher()
            .map { $0 }
            .eraseToAnyPublisher()
    }
}
