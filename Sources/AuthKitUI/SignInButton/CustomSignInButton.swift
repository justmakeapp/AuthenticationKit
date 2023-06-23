// Created 06/02/2022

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

struct SignInButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomSignInButton(type: .apple, action: {})
    }
}
