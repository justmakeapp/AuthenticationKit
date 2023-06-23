//
//  GoogleSignInButton.swift
//
//
//  Created by longvu on 23/06/2023.
//

#if os(iOS)
    import Foundation
    import GoogleSignIn
    import SwiftUI
    import UIKit

    public struct GoogleSignInButton: UIViewRepresentable {
        @Environment(\.colorScheme) var colorScheme
        let action: () -> Void

        public init(_ action: @escaping () -> Void) {
            self.action = action
        }

        private var button: GIDSignInButton = {
            let v = GIDSignInButton()
            v.style = .wide
            return v
        }()

        public func makeUIView(context: Context) -> GIDSignInButton {
            button.colorScheme = colorScheme == .dark ? .dark : .light
            button.addTarget(
                context.coordinator,
                action: #selector(Coordinator.googleSignInButtonTapped),
                for: .touchUpInside
            )
            return button
        }

        public func updateUIView(_: UIViewType, context _: Context) {
            button.colorScheme = colorScheme == .dark ? .dark : .light
        }

        public func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

        public class Coordinator {
            private let parent: GoogleSignInButton
            private let gidInstance = GIDSignIn.sharedInstance

            init(parent: GoogleSignInButton) {
                self.parent = parent
            }

            @objc
            func googleSignInButtonTapped() {
                parent.action()
            }
        }
    }
#endif
