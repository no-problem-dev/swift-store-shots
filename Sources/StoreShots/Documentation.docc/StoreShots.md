# ``StoreShots``

Write the UI test that captures App Store screenshots, and leave the simulator, language and file
handling to the script that runs it.

## Overview

A store screenshot test launches the whole app with demo data, walks to each screen, and shoots it.
Real tab bars, status bars and maps appear exactly as users see them, which a snapshot of a single
view cannot show.

The test only knows about screens. A capture script, such as `pulse shots`, prepares a simulator for
each device, pins the status bar, switches the device language, runs the test once per locale, and
collects the images. The two sides meet in ``StoreShotEnvironment``.

```swift
import StoreShots
import XCTest

final class StoreShots: XCTestCase {
    private static let homeTab = ["ja": "ホーム", "en-US": "Home"]

    @MainActor
    func test_storeShots() throws {
        let environment = try StoreShotEnvironment.current()
        let shooter = StoreShooter(self, environment: environment)
        let app = shooter.launch(arguments: ["-demo-data", environment.locale])

        app.buttons["home.add"].waitToAppear("the add button on Home")
        shooter.shoot("home")

        app.buttons["home.card"].hold(for: 1.6, in: environment)
        shooter.shoot("reward")

        app.openTab(index: 0, title: try environment.entry(in: Self.homeTab), in: environment)
    }
}
```

Each name passed to ``StoreShooter/shoot(_:file:line:)`` matches a scene listed in the capture
configuration. The script checks that every scene was shot at the expected size before it places any
image where the upload step reads it.

## Topics

### The contract with the capture script

- ``StoreShotEnvironment``
- ``StoreShotError``

### Shooting

- ``StoreShooter``
- ``ScreenshotFile``
