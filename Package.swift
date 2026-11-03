// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoService",
    platforms: [
        // Hummingbird 2 needs macOS 14 when you build on a Mac. Linux has no minimum.
        .macOS(.v14)
    ],
    products: [
        .executable(name: "todo-server", targets: ["TodoServer"])
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0")
    ],
    targets: [
        // Pure Swift domain code: no Foundation, no web framework.
        .target(name: "TodoCore"),
        // HTTP routes. Depends on the domain and on Hummingbird.
        .target(
            name: "TodoAPI",
            dependencies: [
                "TodoCore",
                .product(name: "Hummingbird", package: "hummingbird"),
            ]
        ),
        // The executable: reads the environment and starts the server.
        .executableTarget(
            name: "TodoServer",
            dependencies: ["TodoAPI", "TodoCore"]
        ),
        .testTarget(name: "TodoCoreTests", dependencies: ["TodoCore"]),
        .testTarget(
            name: "TodoAPITests",
            dependencies: [
                "TodoAPI",
                "TodoCore",
                .product(name: "HummingbirdTesting", package: "hummingbird"),
            ]
        ),
    ]
)
