//
//  LinkAuthProviderSection.swift
//
//
//  Created by Long Vu on 22/08/2023.
//

import AuthKit
import AuthKitL10n
import SwiftUI

public struct LinkAuthProviderSection: View {
    enum AlertType {
        case isShowUnlinkConfirm
        case isShowLinkAppleConfirm
    }

    @State private var alertType: AlertType?

    @State private var targetLinkProvider: AuthProvider?
    @State private var unlinkProvider: AuthProvider?

    let authProviderLinks: [AuthProviderLink]

    var link: ((AuthProvider) -> Void)?
    var unlink: ((AuthProvider) -> Void)?

    public init(
        authProviderLinks: [AuthProviderLink],
        link: ((AuthProvider) -> Void)? = nil,
        unlink: ((AuthProvider) -> Void)? = nil
    ) {
        self.authProviderLinks = authProviderLinks
        self.link = link
        self.unlink = unlink
    }

    private var canShowUnlink: Bool {
        return authProviderLinks.filter(\.isLinked).count > 1
    }

    public var body: some View {
        let displayedAuthProviderLinks: [AuthProviderLink] = authProviderLinks

        Section {
            ForEach(displayedAuthProviderLinks, id: \.self) { data in
                AuthProviderCellView(data: data, canShowUnlink: canShowUnlink) {
                    buttonTapped(data)
                }
                .padding(.vertical, 8)
                .alert(using: $alertType, content: { alertType in
                    switch alertType {
                    case .isShowUnlinkConfirm:
                        return unlinkAlert
                    case .isShowLinkAppleConfirm:
                        return linkAppleAlert
                    }
                })
            }
        } header: {
            Text(L10n.SignIn.signInMethods.uppercased())
        }
    }

    private var unlinkAlert: Alert {
        Alert(
            title: Text(L10n.Alert.confirmation),
            message: Text(L10n.LinkAuthProvider.unlinkQuestion),
            primaryButton: .default(Text(L10n.Action.agree), action: {
                if let unlinkProvider, let unlink {
                    unlink(unlinkProvider)
                }
            }),
            secondaryButton: .cancel()
        )
    }

    private var linkAppleAlert: Alert {
        Alert(
            title: Text(L10n.Alert.confirmation),
            message: Text(L10n.LinkAuthProvider.linkApple),
            primaryButton: .default(Text(L10n.Action.agree), action: {
                let provider = targetLinkProvider ?? .apple
                link?(provider)
            }),
            secondaryButton: .cancel()
        )
    }

    private func buttonTapped(_ data: AuthProviderLink) {
        let provider = data.provider
        if data.isLinked {
            alertType = .isShowUnlinkConfirm
            unlinkProvider = provider
        } else {
            if provider == .apple {
                alertType = .isShowLinkAppleConfirm
                targetLinkProvider = .apple
            } else {
                if let appleProvider = authProviderLinks.first(where: { $0.provider == .apple }),
                   appleProvider.email != nil {
                    // sign in with apple => then want link to another auth provider
                    alertType = .isShowLinkAppleConfirm
                    targetLinkProvider = provider
                } else {
                    link?(provider)
                }
            }
        }
    }
}

// MARK: - AuthProviderCellView

private struct AuthProviderCellView: View {
    let data: AuthProviderLink
    let canShowUnlink: Bool
    let action: () -> Void

    var body: some View {
        contentView
            .buttonStyle(PlainButtonStyle())
    }

    private var title: String {
        switch data.provider {
        case .apple:
            return "Apple ID"
        case .google:
            return "Google"
        case .email:
            return AuthKitL10n.L10n.email
        }
    }

    private var contentView: some View {
        HStack(spacing: 12) {
            imageView

            VStack(spacing: 2) {
                Text(title)
                    .font(.title3)
                    .frame(height: 24)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let email = data.email {
                    Text(email)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if data.isLinked, canShowUnlink {
                unlinkButton
            }

            if !data.isLinked {
                linkButton
            }
        }
    }

    private var linkButton: some View {
        Button(action: action) {
            Text(L10n.LinkAuthProvider.Action.link)
                .foregroundColor(Color.accentColor)
        }
    }

    private var unlinkButton: some View {
        Button(action: action) {
            Text(L10n.LinkAuthProvider.Action.unlink)
                .foregroundColor(Color.accentColor)
        }
    }

    @ViewBuilder
    private var imageView: some View {
        switch data.provider {
        case .apple:
            Asset.appleIcon.swiftUIImage
                .renderingMode(.original)
                .frame(width: 24, height: 24)

        case .google:
            Asset.googleFavicon.swiftUIImage
                .renderingMode(.original)
                .frame(width: 24, height: 24)
        case .email:
            Image(systemName: "envelope")
                .renderingMode(.template)
                .foregroundColor(.primary)
                .frame(width: 24, height: 24)
        }
    }
}
