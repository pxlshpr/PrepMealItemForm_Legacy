// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrepMealItemForm",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PrepMealItemForm",
            targets: ["PrepMealItemForm"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/FoodLabel", from: "0.0.28"),
        .package(url: "https://github.com/pxlshpr/PrepDataTypes", from: "0.0.97"),
        .package(url: "https://github.com/pxlshpr/PrepViews", from: "0.0.10"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.212"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepMealItemForm",
            dependencies: [
                .product(name: "FoodLabel", package: "foodlabel"),
                .product(name: "PrepDataTypes", package: "prepdatatypes"),
                .product(name: "PrepViews", package: "prepviews"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
            ]),
        .testTarget(
            name: "PrepMealItemFormTests",
            dependencies: ["PrepMealItemForm"]),
    ]
)
