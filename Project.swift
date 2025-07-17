import ProjectDescription

let project = Project(
    name: "Divary",
    packages: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0")
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
                    // Secret.xcconfig에서 가져올 값들
                    "API_URL": "$(API_URL)",
                    "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
                    //Infoplist에 정의할 값
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLSchemes": [
                                "$(GOOGLE_URL_SCHEME)"
                            ]
                        ]
                    ]
                ]
            ),
            sources: ["Divary/Sources/**"],
            resources: ["Divary/Resources/**", ".github/**/*"],
            dependencies: [
                .package(product: "Moya"),
                .package(product: "GoogleSignIn"),
                .package(product: "GoogleSignInSwift") // SwiftUI 사용 시에만 필요
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
