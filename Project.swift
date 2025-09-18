import ProjectDescription

let project = Project(
    name: "TodosApp",
    targets: [
        .target(
            name: "TodosApp",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.TodosApp",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["TodosApp/Sources/**"],
            resources: ["TodosApp/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "TodosAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.TodosAppTests",
            infoPlist: .default,
            sources: ["TodosApp/Tests/**"],
            resources: [],
            dependencies: [.target(name: "TodosApp")]
        ),
    ]
)
