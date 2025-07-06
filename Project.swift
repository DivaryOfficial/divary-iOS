import ProjectDescription

let project = Project(
    name: "Divary",
    packages: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0"))
    ],
    settings: .settings(
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
                ]
            ),
            sources: ["Divary/Sources/**"],
            resources: ["Divary/Resources/**", ".github/**/*"],
            dependencies: [
                .package(product: "Moya")
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
