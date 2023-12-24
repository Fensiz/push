// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Push",
	platforms: [
		.macOS(.v13)
	],
    dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.3.0")),
		.package(url: "https://github.com/drmohundro/SWXMLHash", .upToNextMajor(from: "7.0.2")),
		.package(url: "https://github.com/jpsim/Yams", .upToNextMajor(from: "5.0.6"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "Push",
            dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "SWXMLHash", package: "SWXMLHash"),
				.product(name: "Yams", package: "Yams")
			]),
        .testTarget(
            name: "PushTests",
            dependencies: ["Push"]),
    ]
)
