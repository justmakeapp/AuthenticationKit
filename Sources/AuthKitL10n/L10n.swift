// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
    /// and
    public static let and = L10n.tr("AuthKit", "and", fallback: "and")
    /// Email
    public static let email = L10n.tr("AuthKit", "email", fallback: "Email")
    /// Name
    public static let name = L10n.tr("AuthKit", "name", fallback: "Name")
    /// or
    public static let or = L10n.tr("AuthKit", "or", fallback: "or")
    /// Password
    public static let password = L10n.tr("AuthKit", "password", fallback: "Password")
    public enum Action {
        /// Continue
        public static let `continue` = L10n.tr("AuthKit", "action.continue", fallback: "Continue")
        /// Forgot password?
        public static let forgotPassword = L10n.tr("AuthKit", "action.forgotPassword", fallback: "Forgot password?")
        /// Register
        public static let register = L10n.tr("AuthKit", "action.register", fallback: "Register")
        /// Register with email
        public static let registerWithEmail = L10n.tr(
            "AuthKit",
            "action.registerWithEmail",
            fallback: "Register with email"
        )
        /// Reset password
        public static let resetPassword = L10n.tr("AuthKit", "action.resetPassword", fallback: "Reset password")
        /// Sign in
        public static let signIn = L10n.tr("AuthKit", "action.signIn", fallback: "Sign in")
        /// Sign in to %@
        public static func signInToApp(_ p1: Any) -> String {
            return L10n.tr("AuthKit", "action.signInToApp", String(describing: p1), fallback: "Sign in to %@")
        }

        /// Sign in with %@
        public static func signInWith(_ p1: Any) -> String {
            return L10n.tr("AuthKit", "action.signInWith", String(describing: p1), fallback: "Sign in with %@")
        }

        /// Sign Up
        public static let signUp = L10n.tr("AuthKit", "action.signUp", fallback: "Sign Up")
    }

    public enum Error {
        /// Email is not valid.
        public static let emailNotValid = L10n.tr("AuthKit", "error.emailNotValid", fallback: "Email is not valid.")
        /// Password must have at least %d characters.
        public static func passwordMustHaveAtLeast(_ p1: Int) -> String {
            return L10n.tr(
                "AuthKit",
                "error.passwordMustHaveAtLeast",
                p1,
                fallback: "Password must have at least %d characters."
            )
        }
    }

    public enum Legal {
        /// Privacy Policy
        public static let privacyPolicy = L10n.tr("AuthKit", "legal.privacyPolicy", fallback: "Privacy Policy")
        /// Terms and Conditions
        public static let termsAndConditions = L10n.tr(
            "AuthKit",
            "legal.termsAndConditions",
            fallback: "Terms and Conditions"
        )
        /// Legal
        public static let title = L10n.tr("AuthKit", "legal.title", fallback: "Legal")
    }

    public enum Message {
        /// Open %@ and sign in to share.
        public static func appExtensionRequireAuth(_ p1: Any) -> String {
            return L10n.tr(
                "AuthKit",
                "message.appExtensionRequireAuth",
                String(describing: p1),
                fallback: "Open %@ and sign in to share."
            )
        }

        /// Please check your email for the verification link
        public static let checkMailForLink = L10n.tr(
            "AuthKit",
            "message.checkMailForLink",
            fallback: "Please check your email for the verification link"
        )
        /// The password reset was successfully sent
        public static let passwordResetLinkWasSent = L10n.tr(
            "AuthKit",
            "message.passwordResetLinkWasSent",
            fallback: "The password reset was successfully sent"
        )
    }

    public enum SignIn {
        /// Don't have an account?
        public static let dontHaveAnAccount = L10n.tr(
            "AuthKit",
            "signIn.dontHaveAnAccount",
            fallback: "Don't have an account?"
        )
        /// Forgot your password?
        public static let forgotYourPassword = L10n.tr(
            "AuthKit",
            "signIn.forgotYourPassword",
            fallback: "Forgot your password?"
        )
        /// Welcome to %@
        public static func welcomeTo(_ p1: Any) -> String {
            return L10n.tr("AuthKit", "signIn.welcomeTo", String(describing: p1), fallback: "Welcome to %@")
        }
    }

    public enum SignUp {
        /// By selecting Sign Up below, I agree to
        public static let bySelectingSignUpBelowIAgreeTo = L10n.tr(
            "AuthKit",
            "signUp.bySelectingSignUpBelowIAgreeTo",
            fallback: "By selecting Sign Up below, I agree to "
        )
    }
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
    private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable convenience_type
