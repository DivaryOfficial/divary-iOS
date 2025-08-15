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
            // dSYM 생성 관련
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "GENERATE_DEBUG_SYMBOLS": "YES",
            "STRIP_DEBUG_SYMBOLS_DURING_COPY": "NO",
            "STRIP_LINKED_PRODUCT": "NO"
        ],
        configurations: [
            .debug(
                name: "SecretOnly",
                xcconfig: .relativeToRoot("../divary-iOS/Configuration/Secret.xcconfig")
            ),
            .release(
                name: "Release",
                settings: [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "GENERATE_DEBUG_SYMBOLS": "YES",
                    "STRIP_DEBUG_SYMBOLS_DURING_COPY": "NO"
                ]
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

                    // Universal (iPhone=1, iPad=2)
                    "UIDeviceFamily": [1, 2],

                    // 세로 모드만 지원 (iPhone)
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    // 세로 모드만 지원 (iPad)
                    "UISupportedInterfaceOrientations~ipad": [
                        "UIInterfaceOrientationPortrait"
                    ],

                    // iPad 멀티태스킹 불가(전체화면 강제) — 세로 고정 시 권장
                    "UIRequiresFullScreen": true,

                    // 환경 변수 / URL 스킴
                    "API_URL": "$(API_URL)",
                    "GOOGLE_CLIENT_ID": "$(GOOGLE_CLIENT_ID)",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLSchemes": [
                                "$(GOOGLE_URL_SCHEME)"
                            ]
                        ]
                    ],

                    // 라이트 모드 고정(의도대로 유지)
                    "UIUserInterfaceStyle": "Light",

                    // 권한 문구
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
            settings: .settings(
                base: [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "GENERATE_DEBUG_SYMBOLS": "YES",
                    // Universal (빌드 설정에서도 명시)
                    "TARGETED_DEVICE_FAMILY": "1,2",
                    // 필요 시 배포 타깃 고정
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
            dependencies: [
                .target(name: "Divary")
            ]
        )
    ]
)
