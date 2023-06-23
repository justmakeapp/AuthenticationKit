// swift-tools-version:5.5

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
        .library(name: "FirebaseAuthenticationKit", targets: ["FirebaseAuthenticationKit"]),
        .library(name: "AmplifyAuthenticationKit", targets: ["AmplifyAuthenticationKit"])
    ],
    dependencies: [
        .package(name: "GoogleSignIn", url: "https://github.com/google/GoogleSignIn-iOS", from: "6.2.4"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.10.0"),
        .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.11.7"),
        .package(url: "https://github.com/CombineCommunity/CombineExt", from: "1.8.1"),
        .package(path: "../CommonKitUI")
    ],
    targets: [
        .target(
            name: "AuthKit",
            dependencies: []
        ),
        .target(
            name: "AuthKitUI",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn"),
                .byName(name: "AuthKit"),
                .product(name: "SwiftUIExtension", package: "CommonKitUI"),
                .product(name: "ViewComponent", package: "CommonKitUI")
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
        .target(
            name: "AmplifyAuthenticationKit",
            dependencies: [
                .byName(name: "AuthKit"),
                .byName(name: "AuthKitUI"),
                .productItem(name: "Amplify", package: "amplify-swift"),
                .productItem(name: "AWSCognitoAuthPlugin", package: "amplify-swift"),
                .productItem(name: "CombineExt", package: "CombineExt")
            ]
        )
    ]
)
