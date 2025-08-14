import ProjectDescription

let project = Project(
    name: "Divary",
    packages: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMinor(from: "15.0.3")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMinor(from: "7.0.0")),
        .package(url: "https://github.com/danielsaidi/RichTextKit.git", .upToNextMinor(from: "1.2.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.0.0"))
    ],
    settings: .settings(
        base: [
            "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
            "GOOGLE_URL_SCHEME": "$(GOOGLE_URL_SCHEME)",
            // dSYM 생성을 위한 설정 추가
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "GENERATE_DEBUG_SYMBOLS": "YES",
            "STRIP_DEBUG_SYMBOLS_DURING_COPY": "NO",
            "STRIP_LINKED_PRODUCT": "NO"
        ],
        configurations: [
            .debug(name: "SecretOnly", xcconfig: .relativeToRoot("../divary-iOS/Configuration/Secret.xcconfig")),
            // Release 설정 추가 (Archive용)
            .release(name: "Release", settings: [
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                "GENERATE_DEBUG_SYMBOLS": "YES",
                "STRIP_DEBUG_SYMBOLS_DURING_COPY": "NO"
            ])
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
                    "UIUserInterfaceStyle": "Light",
                    "NSLocationWhenInUseUsageDescription": "주변 장소를 검색하기 위해 위치 정보가 필요합니다."
                ]
            ),
            sources: ["Divary/Sources/**"],
            resources: ["Divary/Resources/**"],
            dependencies: [
                .package(product: "Moya"),
                .package(product: "CombineMoya"),
                .package(product: "GoogleSignIn"),
                .package(product: "GoogleSignInSwift"),
                .package(product: "RichTextKit"),
                .package(product: "Kingfisher")
            ],
            // Target별 설정도 추가
            settings: .settings(
                base: [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "GENERATE_DEBUG_SYMBOLS": "YES"
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
            resources: [],
            dependencies: [.target(name: "Divary")]
        ),
    ]
)
