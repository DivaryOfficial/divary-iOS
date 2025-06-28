import ProjectDescription

let project = Project(
    name: "Divary",
    targets: [
        .target(
            name: "Divary",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Divary",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Divary/Sources/**"],
            resources: ["Divary/Resources/**"],
            dependencies: []
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
