// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LearnSwift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "LearnSwift", targets: ["LearnSwift"]),
        .library(name: "LearnSwiftCore", targets: ["LearnSwiftCore"])
    ],
    targets: [
        .target(
            name: "LearnSwiftCore",
            dependencies: []
        ),
        .executableTarget(
            name: "LearnSwift",
            dependencies: ["LearnSwiftCore"]
        ),
        .testTarget(
            name: "LearnSwiftTests",
            dependencies: ["LearnSwiftCore"]
        )
    ]
)
