// Created 06/02/2022

import AuthKitL10n
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
                    .minimumScaleFactor(0.8)
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

        var image: Image {
            switch self {
            case .apple:
                return Image("AppleIcon", bundle: .module)
                    .renderingMode(.template)
            case .google:
                return Image("GoogleFavicon", bundle: .module)
                    .renderingMode(.original)
            }
        }

        var title: String {
            switch self {
            case .apple:
                return L10n.Action.signInWith("Apple")
            case .google:
                return L10n.Action.signInWith("Google")
            }
        }

        var style: AnyButtonStyle {
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
        VStack {
            CustomSignInButton(type: .apple, action: {})
                .frame(minHeight: 44, maxHeight: 54)

            CustomSignInButton(type: .google, action: {})
                .frame(minHeight: 44, maxHeight: 54)
        }
        .padding()
        .background(Color.gray)
    }
}
