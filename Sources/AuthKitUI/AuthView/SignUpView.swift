//
//  SignUpView.swift
//
//
//  Created by Long Vu on 23/07/2023.
//

import AuthKitL10n
import SwiftUI
import ViewComponent

public struct SignUpView: View {
    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Environment(\.presentationMode) private var presentationMode

    @State private var isSignUpPressed = false
    @Binding private var name: String
    @Binding private var email: String
    @Binding private var password: String

    private var config: Config

    public init(
        name: Binding<String>,
        email: Binding<String>,
        password: Binding<String>,
        termsAndConditionsURL: URL,
        privacyPolicyURL: URL
    ) {
        _name = name
        _email = email
        _password = password
        config = .init(
            termsAndConditionsURL: termsAndConditionsURL,
            privacyPolicyURL: privacyPolicyURL
        )
    }

    private var isCompact: Bool {
        #if os(iOS)
            return horizontalSizeClass == .compact
        #else
            return false
        #endif
    }

    public var body: some View {
        ZStack {
            contentView
                .frame(maxWidth: isCompact ? .infinity : 400.onMac(300))

            buildNonMacView {
                backButton
            }
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            signUpTitle
                .padding(.top, 66.scaledToMac())

            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 16.scaledToMac()) {
                    nameTextField
                    emailTextField
                    passwordTextField
                }
                .padding(.top, 40.scaledToMac())

                ArgreementView(
                    termsAndConditionsURL: config.termsAndConditionsURL,
                    privacyPolicyURL: config.privacyPolicyURL
                )
                .padding(.top, 32.scaledToMac())

                signUpButton
                    .padding(.top, 16.scaledToMac())

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical)
    }

    private var signUpTitle: some View {
        Text(L10n.Action.signUp)
            .font(.title.weight(.semibold))
    }

    private var nameTextField: some View {
        TextField(L10n.name, text: $name)
            .font(.body)
            .textFieldStyling()
    }

    // MARK: - Email

    private var isEmailValid: Bool {
        if isSignUpPressed || !email.isEmpty {
            return AuthView.validateEmail(email)
        } else {
            return true
        }
    }

    private var emailTextField: some View {
        TextField(L10n.email, text: $email)
        #if os(iOS)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
        #endif
            .font(.body)
            .textFieldStyling()
            .overlay {
                if !isEmailValid {
                    HStack {
                        Spacer()

                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.red)
                            .padding(.trailing, 10)
                    }
                }
            }
            .transition(.fade)
            .animation(.linear, value: isEmailValid)
    }

    // MARK: - Password

    private var isPasswordValid: Bool {
        if isSignUpPressed || !password.isEmpty {
            return AuthView.validatePassword(password)
        } else {
            return true
        }
    }

    private var passwordTextField: some View {
        VStack {
            SecureField(L10n.password, text: $password)
                .textFieldStyling()

            if !isPasswordValid {
                Text(L10n.Error.passwordMustHaveAtLeast(6))
                    .font(.body)
                    .foregroundColor(.red)
            }
        }
        .transition(.fade)
        .animation(.linear, value: isPasswordValid)
    }

    // MARK: - Sign Up Button

    private var canContinue: Bool {
        return isEmailValid && isPasswordValid
    }

    private var signUpButtonDisabled: Bool {
        if isSignUpPressed || !email.isEmpty || !password.isEmpty {
            return !canContinue
        } else {
            return false
        }
    }

    private var signUpButton: some View {
        DebounceButton {
            isSignUpPressed = true
            guard canContinue else {
                return
            }

            config.onSignUp()

        } label: {
            HStack {
                Text(L10n.Action.signUp)
                    .font(.body)
                    .foregroundColor(.white)
            }
            .frame(height: 44.scaledToMac())
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(10.onMac(7))
        }
        .disabled(signUpButtonDisabled)
        .transition(.fade)
        .animation(.linear, value: signUpButtonDisabled)
        .buttonStyle(.plain)
    }

    private var backButton: some View {
        ZStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                ZStack {
                    Image(systemName: "chevron.backward")
                        .imageScale(.large)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
                .frame(width: 44, height: 44)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Config

public extension SignUpView {
    struct Config {
        var termsAndConditionsURL: URL
        var privacyPolicyURL: URL
        var onSignUp: () -> Void = {}
    }

    func onSignUp(_ value: @escaping () -> Void) -> Self {
        then { $0.config.onSignUp = value }
    }
}

private extension SignUpView {
    // MARK: - ArgreementView

    struct ArgreementView: View {
        let termsAndConditionsURL: URL
        let privacyPolicyURL: URL

        var body: some View {
            contentView
        }

        @ViewBuilder
        private var contentView: some View {
            agreementView
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }

        @ViewBuilder
        private var agreementView: some View {
            let termsOfServiceText = try? Self.makeHyperlinkMarkdownAttibutedText(
                L10n.Legal.termsAndConditions,
                url: termsAndConditionsURL
            )
            let privacyPolicyText = try? Self.makeHyperlinkMarkdownAttibutedText(
                L10n.Legal.privacyPolicy,
                url: privacyPolicyURL
            )
            if let termsOfServiceText, let privacyPolicyText {
                Group {
                    Text(L10n.SignUp.bySelectingSignUpBelowIAgreeTo)
                        .foregroundColor(Color.secondary)
                        + Text(termsOfServiceText)
                        + Text(" \(L10n.and) ")
                        .foregroundColor(Color.secondary)
                        + Text(privacyPolicyText)
                }
                .font(.body)
            }
        }

        private static func makeHyperlinkMarkdownAttibutedText(_ text: String, url: URL) throws -> AttributedString {
            let markdown = "[\(text)](\(url.absoluteString))"
            return try AttributedString(markdown: markdown)
        }
    }
}

// MARK: - Previews

struct SignUpView_Previews: PreviewProvider {
    @State private static var name = ""
    @State private static var email = ""
    @State private static var password = ""

    static var previews: some View {
        SignUpView(
            name: $name,
            email: $email,
            password: $password,
            termsAndConditionsURL: .init(string: "https://github.com/google/GoogleSignIn-iOS/releases/tag/7.0.0")!,
            privacyPolicyURL: .init(string: "https://github.com/google/GoogleSignIn-iOS/releases/tag/7.0.0")!
        )
    }
}
