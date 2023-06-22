//
//  AuthDataProvider.swift
//
//
//  Created by Long Vu on 26/04/2023.
//

import Combine
import Foundation

public protocol AuthDataProvider {
    func authStateDidChangePublisher() -> AnyPublisher<AuthUser?, Never>
}
