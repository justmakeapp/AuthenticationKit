//
//  AuthView.swift
//
//
//  Created by Long Vu on 22/07/2023.
//

import AuthKit
import AuthKitL10n
import FoundationX
import SwiftUI
import SwiftUIExtension
import ViewComponent

public struct AuthView: View {
    #if !os(macOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @Binding private var email: String
    @Binding private var password: String

    @State private var isContinueButtonPressed = false
    @State private var isSignInButtonPressed = false
    @State private var inputState: InputState = .emailOnly

    private var isCompact: Bool {
        #if !os(macOS)
            return horizontalSizeClass == .compact
        #else
            return false
        #endif
    }

    private var config: Config

    public init(
        email: Binding<String>,
        password: Binding<String>
    ) {
        config = .init(enabledPasswordBasedMethod: true)
        _email = email
        _password = password
    }

    public init() {
        config = .init(enabledPasswordBasedMethod: false)
        _email = .constant("")
        _password = .constant("")
    }

    public var body: some View {
        contentView
        #if targetEnvironment(macCatalyst)
        .navigationBarHidden(true)
        #endif
    }

    private var contentView: some View {
        ZStack {
            ScrollView {
                scrollContentView
            }
            buildMacView {
                if config.mode == .reauthenticate {
                    closeButton
                }
            }
        }
    }

    private var scrollContentView: some View {
        VStack(spacing: 0) {
            HeaderView(appName: config.appName)
                .padding(.top, 66.scaledToMac())

            OAuthSignInView { authProvider in
                config.onOauthSignIn(authProvider)
            }

            if config.enabledPasswordBasedMethod {
                passwordBasedView
            } else {
                ZStack {
                    continueAsGuestButton
                }
                .padding(.vertical)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: isCompact ? .infinity : 400.onMac(300))
    }

    private var passwordBasedView: some View {
        VStack(spacing: 0) {
            Text(L10n.or)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.vertical, 20.scaledToMac())

            VStack(alignment: .leading, spacing: 16.scaledToMac()) {
                emailTextField

                if inputState == .emailAndPassword {
                    passwordTextField
                }

                continueButton

                if config.mode == .signIn {
                    signUpQuestionView

                    forgotPasswordButton
                }

                #if DEBUG
                    continueAsGuestButton
                #endif
            }
            .transition(.fade)
            .animation(.linear, value: inputState)
        }
    }

    // MARK: - Email

    public static func validateEmail(_ email: String) -> Bool {
        let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        )

        let range = NSRange(
            email.startIndex ..< email.endIndex,
            in: email
        )

        let matches = detector?.matches(
            in: email,
            options: [],
            range: range
        )

        // We only want our string to contain a single email
        // address, so if multiple matches were found, then
        // we fail our validation process and return nil:
        guard let match = matches?.first, matches?.count == 1 else {
            return false
        }

        // Verify that the found link points to an email address,
        // and that its range covers the whole input string:
        guard match.url?.scheme == "mailto", match.range == range else {
            return false
        }

        return true
    }

    private var emailIsValid: Bool {
        if isContinueButtonPressed || !email.isEmpty {
            return Self.validateEmail(email)
        }
        return true
    }

    private var emailTextField: some View {
        TextField(L10n.email, text: $email)
        #if os(iOS) || targetEnvironment(macCatalyst)
            .keyboardType(UIKeyboardType.emailAddress)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
        #endif
            .font(.body)
            .textFieldStyling()
            .overlay {
                if !emailIsValid {
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
            .animation(.linear, value: emailIsValid)
    }

    // MARK: - Password

    public static func validatePassword(_ password: String) -> Bool {
        let passwordPattern = #"(?=.{6,})"# // At least 6 characters

        return password ~= passwordPattern
    }

    private var isPasswordValid: Bool {
        if isSignInButtonPressed || !password.isEmpty {
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

    // MARK: - ContinueButton

    private var canSignIn: Bool {
        return emailIsValid && isPasswordValid
    }

    private var continueButtonDisabled: Bool {
        switch inputState {
        case .emailOnly:
            if isContinueButtonPressed || !email.isEmpty {
                return !emailIsValid
            }

        case .emailAndPassword:
            if isSignInButtonPressed || !password.isEmpty {
                return !canSignIn
            }
        }

        return false
    }

    private var continueButton: some View {
        DebounceButton {
            switch inputState {
            case .emailOnly:
                isContinueButtonPressed = true
                guard emailIsValid else {
                    return
                }
                inputState = .emailAndPassword

            case .emailAndPassword:
                isSignInButtonPressed = true
                guard canSignIn else {
                    return
                }
                config.onSignIn()
            }
        } label: {
            HStack {
                let continueTitle: String = {
                    switch inputState {
                    case .emailOnly:
                        return L10n.Action.continue
                    case .emailAndPassword:
                        return L10n.Action.signIn
                    }
                }()

                Text(continueTitle)
                    .font(.body)
                    .foregroundColor(.white)
            }
            .frame(height: 44.scaledToMac())
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(config.cornerRadius)
        }
        .disabled(continueButtonDisabled)
        .buttonStyle(.plain)
    }

    private var signUpQuestionView: some View {
        HStack(spacing: 8.scaledToMac()) {
            Text(L10n.SignIn.dontHaveAnAccount)
                .font(.body)
                .foregroundColor(.secondary)

            Button {
                config.onSignUp()
            } label: {
                Text(L10n.Action.signUp)
                    .font(.body)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
    }

    private var forgotPasswordButton: some View {
        Button {
            config.onForgotPassword()
        } label: {
            Text(L10n.SignIn.forgotYourPassword)
                .font(.body)
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }

    private var continueAsGuestButton: some View {
        DebounceButton {
            config.onContinueAsGuest()
        } label: {
            Text(L10n.Action.continueAsGuest)
                .font(.body)
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }

    private var closeButton: some View {
        ZStack {
            Button {
                config.onClose()
            } label: {
                ZStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .foregroundColor(.secondary)
                }
                .frame(width: 44, height: 44, alignment: .center)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

private extension AuthView {
    struct HeaderView: View {
        let appName: String
        var body: some View {
            VStack(spacing: 12) {
                if let appIcon = Bundle.main.icon {
                    ZStack {
                        buildView {
                            appIcon
                                .resizable()
                        } nonMacBuilder: {
                            appIcon
                                .resizable()
                                .cornerRadius(14)
                        }
                    }
                    .frame(width: 78.scaledToMac(), height: 78.scaledToMac())
                }

                Text(L10n.SignIn.welcomeTo(appName))
                    .foregroundColor(.accentColor)
                    .font(.title.weight(.semibold))
            }
        }
    }

    struct OAuthSignInView: View {
        private let cornerRadius: CGFloat = 10.onMac(7)

        var onAction: (_ authProvider: OAuthSignInProvider) -> Void

        var body: some View {
            VStack(spacing: 16.scaledToMac()) {
                signInWithAppleButton

                googleSignInButton
            }
            .padding(.top, 40.scaledToMac())
        }

        private var googleSignInButton: some View {
            CustomSignInButton(type: .google) {
                onAction(.google)
            }
            .frame(height: 44.scaledToMac())
            .cornerRadius(cornerRadius)
            .shadow(radius: 1)
        }

        private var signInWithAppleButton: some View {
            CustomSignInButton(type: .apple) {
                onAction(.apple)
            }
            .debounceTime(.seconds(2))
            .frame(height: 44.scaledToMac())
            .cornerRadius(cornerRadius)
        }
    }
}

// MARK: - Config

public extension AuthView {
    enum InputState {
        case emailOnly
        case emailAndPassword
    }

    enum Mode {
        case signIn
        case reauthenticate
    }

    struct Config {
        var enabledPasswordBasedMethod: Bool
        var appName: String = ""
        var cornerRadius: CGFloat = 10.onMac(7)
        var mode: Mode = .signIn
        var onClose: () -> Void = {}
        var onForgotPassword: () -> Void = {}
        var onSignIn: () -> Void = {}
        var onOauthSignIn: (_ authProvider: OAuthSignInProvider) -> Void = { _ in }
        var onSignUp: () -> Void = {}
        var onContinueAsGuest: () -> Void = {}
    }

    func appName(_ value: String) -> Self {
        then { $0.config.appName = value }
    }

    func onClose(_ value: @escaping () -> Void) -> Self {
        then { $0.config.onClose = value }
    }

    func onForgotPassword(_ value: @escaping () -> Void) -> Self {
        then { $0.config.onForgotPassword = value }
    }

    func onSignIn(_ value: @escaping () -> Void) -> Self {
        then { $0.config.onSignIn = value }
    }

    func onOauthSignIn(_ value: @escaping (_ authProvider: OAuthSignInProvider) -> Void) -> Self {
        then { $0.config.onOauthSignIn = value }
    }

    func onSignUp(_ value: @escaping () -> Void) -> Self {
        then { $0.config.onSignUp = value }
    }

    func onContinueAsGuest(_ value: @escaping () -> Void) -> Self {
        then { $0.config.onContinueAsGuest = value }
    }
}

// MARK: - Previews

struct AuthView_Previews: PreviewProvider {
    @State private static var email = "longvudai@email.com"
    @State private static var password = ""
    static var previews: some View {
        AuthView(email: $email, password: $password)
            .appName("My App")
    }
}
