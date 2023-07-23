// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "AuthKitUI",
    defaultLocalization: "en",
    platforms: [
        .macCatalyst(.v15),
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AuthKitUI",
            targets: ["AuthKitUI"]
        ),
        .library(name: "AuthKit", targets: ["AuthKit"]),
        .library(name: "AuthKitL10n", targets: ["AuthKitL10n"]),
        .library(name: "FirebaseAuthenticationKit", targets: ["FirebaseAuthenticationKit"]),
//        .library(name: "AmplifyAuthenticationKit", targets: ["AmplifyAuthenticationKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/google/GoogleSignIn-iOS", exact: "7.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "10.12.0"),
//        .package(url: "https://github.com/aws-amplify/amplify-swift", exact: "2.11.7"),
//        .package(url: "https://github.com/CombineCommunity/CombineExt", exact: "1.8.1"),
        .package(path: "../CommonKitUI"),
        .package(path: "../FoundationX"),
        .package(url: "https://github.com/mhdhejazi/Dynamic.git", exact: "1.2.0"),
        .package(url: "https://github.com/SwiftUIX/SwiftUIX", exact: "0.1.6")
    ],
    targets: [
        .target(
            name: "AuthKit",
            dependencies: []
        ),
        .target(
            name: "AuthKitL10n",
            dependencies: []
        ),
        .target(
            name: "AuthKitUI",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "SwiftUIExtension", package: "CommonKitUI"),
                .product(name: "ViewComponent", package: "CommonKitUI"),
                "FoundationX",
                "AuthKit",
                "AuthKitL10n",
                "Dynamic",
                "SwiftUIX",
            ]
        ),
        .target(
            name: "FirebaseAuthenticationKit",
            dependencies: [
                .byName(name: "AuthKit"),
                .byName(name: "AuthKitUI"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuthCombine-Community", package: "firebase-ios-sdk")
            ]
        ),
//        .target(
//            name: "AmplifyAuthenticationKit",
//            dependencies: [
//                .byName(name: "AuthKit"),
//                .byName(name: "AuthKitUI"),
//                .productItem(name: "Amplify", package: "amplify-swift"),
//                .productItem(name: "AWSCognitoAuthPlugin", package: "amplify-swift"),
//                .productItem(name: "CombineExt", package: "CombineExt")
//            ]
//        )
    ]
)
