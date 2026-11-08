// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-store-shots",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "StoreShots",
            targets: ["StoreShots"]
        ),
    ],
    targets: [
        // Depends on XCTest alone, so a UI test bundle that links it resolves nothing else.
        .target(
            name: "StoreShots"
        ),
        .testTarget(
            name: "StoreShotsTests",
            dependencies: ["StoreShots"]
        ),
    ]
)
