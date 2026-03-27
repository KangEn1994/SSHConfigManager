// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SSHConfigManager",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SSHCMCore", targets: ["SSHCMCore"]),
        .executable(name: "sshcm", targets: ["sshcm"]),
        .executable(name: "SSHConfigManagerGUI", targets: ["SSHConfigManagerGUI"])
    ],
    targets: [
        .target(
            name: "SSHCMCore"
        ),
        .executableTarget(
            name: "sshcm",
            dependencies: ["SSHCMCore"]
        ),
        .executableTarget(
            name: "SSHConfigManagerGUI",
            dependencies: ["SSHCMCore"]
        ),
        .testTarget(
            name: "SSHCMCoreTests",
            dependencies: ["SSHCMCore"]
        )
    ]
)
