// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Juicer",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [.library(name: "Juicer", targets: ["Juicer"])],
    dependencies: [
        .package(url: "https://github.com/Hi-Rez/Satin", .branch("master")),
        .package(url: "https://github.com/Hi-Rez/Easings", .branch("master"))
    ],
    targets: [.target(name: "Juicer", dependencies: ["Satin", "Easings"])],
    swiftLanguageVersions: [.v5]
)
