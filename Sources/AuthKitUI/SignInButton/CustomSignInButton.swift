// Created 06/02/2022

import GoogleSignIn
import SwiftUI
import SwiftUIExtension
import ViewComponent

public struct CustomSignInButton: View {
    private struct Configuration {
        var debounceTime: DispatchTimeInterval = .seconds(1)
    }

    private let type: SocialType
    private let action: () -> Void

    private var configuration: Configuration = .init()

    public init(type: SocialType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }

    public var body: some View {
        DebounceButton(action: action) {
            HStack {
                type.image

                Text(type.title)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .debounceTime(configuration.debounceTime)
        .buttonStyle(type.style)
    }
}

public extension CustomSignInButton {
    enum SocialType {
        case apple
        case google

        internal var image: Image {
            switch self {
            case .apple:
                return Image("AppleIcon", bundle: .module)
                    .renderingMode(.template)
            case .google:
                return Image("GoogleFavicon", bundle: .module)
                    .renderingMode(.original)
            }
        }

        internal var title: String {
            switch self {
            case .apple:
                return L10n.Action.signInWith("Apple")
            case .google:
                return L10n.Action.signInWith("Google")
            }
        }

        internal var style: AnyButtonStyle {
            switch self {
            case .apple:
                return AppleStyle().eraseToAnyButtonStyle()
            case .google:
                return GoogleStyle().eraseToAnyButtonStyle()
            }
        }
    }

    func debounceTime(_ value: DispatchTimeInterval) -> Self {
        then { $0.configuration.debounceTime = value }
    }
}

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
