# Changelog

All notable changes to this project are recorded in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- **`StoreShotEnvironment`, the contract between a capture script and the UI test.** It reads the
  store locale, the device language and region, the device name and the output directory from
  `STORE_SHOTS_*` variables, and turns them into launch arguments. A missing variable is an error that
  names it, instead of a silent fall back to one language.
- **`StoreShooter.shoot(_:)`.** Takes a screenshot, keeps it as an attachment that survives a passing
  test, and also writes `<name>.png` to the output directory, so the images can be collected even when
  `xcodebuild` never finishes writing the result bundle.
- **Waiting helpers** on `XCUIElement` and `XCUIElementQuery` that fail the test with the name of what
  did not appear, so a capture never silently shoots the wrong screen.
- **`XCUIElement.hold(for:in:)`**, a long press that adds the delay iPad simulators show before a press
  reaches the app.
- **`XCUIApplication.openTab(index:title:in:)`**, which taps tabs by position on iPhone and by title on
  iPad, where the tab bar moves to the top.
