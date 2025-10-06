import ProjectDescription

let project = Project(
    name: "Divary",
    packages: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMinor(from: "15.0.3")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMinor(from: "7.0.0")),
        .package(url: "https://github.com/danielsaidi/RichTextKit.git", .upToNextMinor(from: "1.2.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/auth0/JWTDecode.swift", .upToNextMajor(from: "3.0.0")),

    ],
    settings: .settings(
        base: [
            "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
            "GOOGLE_URL_SCHEME": "$(GOOGLE_URL_SCHEME)",

            // === Debug Info 포맷을 SDK/Config 별로 정확히 스코핑 ===
            // 시뮬레이터는 dSYM 금지 (경고 방지)
            "DEBUG_INFORMATION_FORMAT[sdk=iphonesimulator*]": "dwarf",
            // 디바이스(iphoneos)는 dSYM 유지
            "DEBUG_INFORMATION_FORMAT[sdk=iphoneos*][config=Debug]": "dwarf-with-dsym",
            "DEBUG_INFORMATION_FORMAT[sdk=iphoneos*][config=Release]": "dwarf-with-dsym",

            // 실제로 디버그 심볼을 생성하도록 보장
            "GCC_GENERATE_DEBUGGING_SYMBOLS": "YES",
            "GENERATE_DEBUG_SYMBOLS": "YES",

            // 스트립 정책 (Debug는 보존, Release는 스트립)
            "COPY_PHASE_STRIP[config=Debug]": "NO",
            "COPY_PHASE_STRIP[config=Release]": "YES",

            // 빌드/카피 중 디버그 심볼 스트립 금지 (필요한 dSYM 비우지 않도록)
            "STRIP_DEBUG_SYMBOLS_DURING_COPY": "NO",
            // 링크 산출물 스트립: Debug는 보존, Release는 스트립
            "STRIP_LINKED_PRODUCT[config=Debug]": "NO",
            "STRIP_LINKED_PRODUCT[config=Release]": "YES"
        ],
        configurations: [
            .debug(
                name: "SecretOnly",
                // 필요 시 디버그 최적화/LLDB 안정화
                settings: [
                    "ONLY_ACTIVE_ARCH": "YES",
                    "GCC_OPTIMIZATION_LEVEL": "0",
                    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                    "SWIFT_COMPILATION_MODE": "incremental"
                ],
                xcconfig: .relativeToRoot("../divary-iOS/Configuration/Secret.xcconfig")
            ),
            .release(
              name: "Release",
              settings: [
                "SWIFT_OPTIMIZATION_LEVEL": "-O",
                "SWIFT_COMPILATION_MODE": "wholemodule"
              ],
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
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": ""
                    ],
                    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
                    "UISupportedInterfaceOrientations~ipad": ["UIInterfaceOrientationPortrait"],
                    "UIRequiresFullScreen": true,

                    "API_URL": "$(API_URL)",
                    "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
                    "CFBundleURLTypes": [[ "CFBundleURLSchemes": ["$(GOOGLE_URL_SCHEME)"] ]],
                    "UIUserInterfaceStyle": "Light",
                    "NSLocationWhenInUseUsageDescription": "주변 장소를 검색하기 위해 위치 정보가 필요합니다."
                ]
            ),
            sources: ["Divary/Sources/**"],
            resources: ["Divary/Resources/**"],
            entitlements: .dictionary([
                    "com.apple.developer.applesignin": .array([ .string("Default") ])
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
                    // Universal
                    "TARGETED_DEVICE_FAMILY": "1,2",
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
            resources: [],
            dependencies: [ .target(name: "Divary") ]
        )
    ]
)
