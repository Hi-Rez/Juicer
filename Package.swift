// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Juicer",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [.library(name: "Juicer", targets: ["Juicer"])],
    dependencies: [
        .package(url: "https://github.com/Hi-Rez/Satin", from: "2.1.0"),
        .package(url: "https://github.com/Hi-Rez/Easings", from: "0.0.4")
    ],
    targets: [.target(name: "Juicer", dependencies: ["Satin", "Easings"])],
    swiftLanguageVersions: [.v5]
)
