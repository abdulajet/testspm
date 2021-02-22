// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "NexmoClient",
    platforms: [
        .iOS(.v10)
      ],
    products: [
        .library(
            name: "NexmoClient",
            targets: ["NexmoClient"])
    ],
    targets: [
        .binaryTarget(
            name: "NexmoClient",
            path: "NexmoClient.xcframework")
    ]
)
