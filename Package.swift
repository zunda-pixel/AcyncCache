// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AsyncCache",
  platforms: [.iOS(.v15),],
  products: [
    .library(
      name: "AsyncCache",
      targets: ["AsyncCache"]),
  ],
  dependencies: [
    .package(url: "https://github.com/hyperoslo/Cache", .upToNextMajor(from: "6.0.0")),
  ],
  targets: [
    .target(
      name: "AsyncCache",
      dependencies: [
        .product(name: "Cache", package: "Cache"),
      ]
    ),
    .testTarget(
      name: "AsyncCacheTests",
      dependencies: ["AsyncCache"]
    ),
  ]
)
