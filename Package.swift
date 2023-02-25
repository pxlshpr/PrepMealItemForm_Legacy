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
        .package(url: "https://github.com/pxlshpr/PrepCoreDataStack", from: "0.0.30"),
        .package(url: "https://github.com/pxlshpr/FoodLabel", from: "0.0.59"),
        .package(url: "https://github.com/pxlshpr/PrepDataTypes", from: "0.0.278"),
//        .package(url: "https://github.com/pxlshpr/PrepFoodSearch", from: "0.0.86"),
        .package(url: "https://github.com/pxlshpr/PrepGoalSetsList", from: "0.0.2"),
        .package(url: "https://github.com/pxlshpr/PrepViews", from: "0.0.147"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.369"),
        .package(url: "https://github.com/pxlshpr/Timeline", from: "0.0.68"),

        .package(url: "https://github.com/pxlshpr/PrepFoodForm", from: "0.1.120"),
        .package(url: "https://github.com/pxlshpr/FoodLabelExtractor", from: "0.0.32"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepMealItemForm",
            dependencies: [
                .product(name: "FoodLabel", package: "foodlabel"),
                .product(name: "PrepCoreDataStack", package: "prepcoredatastack"),
                .product(name: "PrepDataTypes", package: "prepdatatypes"),
//                .product(name: "PrepFoodSearch", package: "prepfoodsearch"),
                .product(name: "PrepGoalSetsList", package: "prepgoalsetslist"),
                .product(name: "PrepViews", package: "prepviews"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
                .product(name: "Timeline", package: "timeline"),

                .product(name: "PrepFoodForm", package: "prepfoodform"),
                .product(name: "FoodLabelExtractor", package: "foodlabelextractor"),
            ]),
        .testTarget(
            name: "PrepMealItemFormTests",
            dependencies: ["PrepMealItemForm"]),
    ]
)
