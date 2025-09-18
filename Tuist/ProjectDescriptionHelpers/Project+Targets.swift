import ProjectDescription

public extension Target {
    static let todosApp: Target = .target(
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
        dependencies: [
            .stevia,
            .sqlite
        ]
    )

    static let todosAppTests: Target = .target(
        name: "todosAppTests",
        destinations: .iOS,
        product: .unitTests,
        bundleId: "io.tuist.todosAppTests",
        infoPlist: .default,
        sources: ["TodosApp/Tests/**"],
        resources: [],
        dependencies: [.target(name: "TodosApp")]
    )
}
