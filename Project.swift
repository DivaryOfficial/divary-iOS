import ProjectDescription

let project = Project(
    name: "Divary",
    packages: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMinor(from: "15.0.3")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMinor(from: "7.0.0")),
        .package(url: "https://github.com/danielsaidi/RichTextKit.git", .upToNextMinor(from: "1.2.0"))
    ],
    settings: .settings(
        base: [
               "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
               "GOOGLE_URL_SCHEME": "$(GOOGLE_URL_SCHEME)"
        ],
        configurations: [
            .debug(name: "SecretOnly", xcconfig: .relativeToRoot("../divary-iOS/Configuration/Secret.xcconfig"))
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
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "API_URL": "$(API_URL)",
                    "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLSchemes": [
                                "$(GOOGLE_URL_SCHEME)"
                            ]
                        ]
                    ],
                    "UIUserInterfaceStyle": "Light"
                ]
            ),
            sources: ["Divary/Sources/**"],
            resources: ["Divary/Resources/**"],
            dependencies: [
                .package(product: "Moya"),
                .package(product: "GoogleSignIn"),
                .package(product: "GoogleSignInSwift"), // 선택적
                .package(product: "RichTextKit")        // 실제 product명이 맞는지 꼭 확인
            ]
        ),
        .target(
            name: "DivaryTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.DivaryTests",
            infoPlist: .default,
            sources: ["Divary/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Divary")]
        ),
    ]
)
