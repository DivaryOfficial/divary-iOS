import ProjectDescription

let project = Project(
    name: "Divary",
    packages: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMinor(from: "15.0.3")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMinor(from: "7.0.0")),
        .package(url: "https://github.com/danielsaidi/RichTextKit.git", .upToNextMinor(from: "1.2.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/auth0/JWTDecode.swift", .upToNextMajor(from: "3.0.0"))
    ],
    settings: .settings(
        base: [
            "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
            "GOOGLE_URL_SCHEME": "$(GOOGLE_URL_SCHEME)"
        ],
        configurations: [
            .debug(
                name: "Debug",
                xcconfig: .relativeToRoot("../divary-iOS/Configuration/Secret.xcconfig")
            ),
            .release(
                name: "Release",
                xcconfig: .relativeToRoot("../divary-iOS/Configuration/Secret.xcconfig")
            )
        ]
    ),
    targets: [
        .target(
            name: "Divary",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Divary",
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleIconName": "AppIcon",
                    "UILaunchScreen": [:],
                    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
                    "API_URL": "$(API_URL)",
                    "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
                    "CFBundleURLTypes": [["CFBundleURLSchemes": ["$(GOOGLE_URL_SCHEME)"]]],
                    "UIUserInterfaceStyle": "Light",
                    "NSLocationWhenInUseUsageDescription": "주변 장소를 검색하기 위해 위치 정보가 필요합니다."
                ]
            ),
            sources: ["Divary/Sources/**"],
            resources: ["Divary/Resources/**"],
            entitlements: .dictionary([
                "com.apple.developer.applesignin": .array([.string("Default")])
            ]),
            dependencies: [
                .package(product: "Moya"),
                .package(product: "CombineMoya"),
                .package(product: "GoogleSignIn"),
                .package(product: "GoogleSignInSwift"),
                .package(product: "RichTextKit"),
                .package(product: "Kingfisher"),
                .package(product: "JWTDecode")
            ],
            settings: .settings(
                base: [
                    "IPHONEOS_DEPLOYMENT_TARGET": "17.0"
                ]
            )
        ),
        .target(
            name: "DivaryTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.DivaryTests",
            infoPlist: .default,
            sources: ["Divary/Tests/**"],
            dependencies: [.target(name: "Divary")]
        )
    ]
)
