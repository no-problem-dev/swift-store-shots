English | [日本語](./README.ja.md)

# StoreShots

Capture App Store screenshots of the real app in every language from one UI test, without copying the same helpers into each app.

![Swift 6.2+](https://img.shields.io/badge/Swift-6.2+-orange.svg)
![iOS 17+](https://img.shields.io/badge/iOS-17+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

- **The whole app, not a cut-out view.** The test launches the app with demo data and shoots the screen, so the tab bar, status bar and maps look exactly as they do for users.
- **One contract with the capture script.** Locale, device language, region, device name and output directory arrive as `STORE_SHOTS_*` variables. A missing one stops the test instead of shooting every image in the wrong language.
- **Images survive a stuck `xcodebuild`.** Each screenshot is kept as an attachment and also written straight to a folder on the Mac, so the set can be collected even when the result bundle is never finished.
- **Waits that fail loudly.** Every wait names what did not appear, so a capture never moves on and shoots the wrong screen.
- **iPad quirks handled.** Long presses add the delay iPad simulators show, and tabs are found by title when the tab bar moves to the top.
- **XCTest only.** Nothing else is resolved into your UI test bundle.

## Usage

```swift
import StoreShots
import XCTest

final class StoreShots: XCTestCase {
    @MainActor
    func test_storeShots() throws {
        let environment = try StoreShotEnvironment.current()
        let shooter = StoreShooter(self, environment: environment)
        let app = shooter.launch(arguments: ["-demo-data", environment.locale])

        app.buttons["home.add"].waitToAppear("the add button on Home")
        shooter.shoot("home")
    }
}
```

Run it through a capture script that prepares a simulator per device, switches the device language
for each locale, passes the `STORE_SHOTS_*` variables to `xcodebuild` as `TEST_RUNNER_STORE_SHOTS_*`,
and checks the size and count of the images it collects.

## Documentation

The API reference is the DocC catalog under `Sources/*/*.docc/` (Xcode › Product › Build Documentation).
covers the environment contract, the waiting helpers and the file layout.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-store-shots.git", from: "1.0.0")
]
```

Add `StoreShots` to the UI test target that captures the screenshots.

## License

MIT. See [LICENSE](./LICENSE).
