#if os(iOS)
import XCTest

/// Takes store screenshots from inside a UI test.
///
/// Each call to ``shoot(_:file:line:)`` keeps the screenshot as an attachment and, when the script
/// gave an output directory, writes it there as `<name>.png` as well. The second copy matters because
/// `xcodebuild` in Xcode 27.1 sometimes stops before it finishes writing the result bundle, which
/// leaves the attachments unreadable.
@MainActor
public struct StoreShooter {
    /// The values the capture script passed in.
    public let environment: StoreShotEnvironment
    private let testCase: XCTestCase

    /// Creates a shooter that attaches screenshots to a test case.
    ///
    /// - Parameters:
    ///   - testCase: The running test, usually `self`.
    ///   - environment: The values from the capture script.
    public init(_ testCase: XCTestCase, environment: StoreShotEnvironment) {
        self.testCase = testCase
        self.environment = environment
    }

    /// Launches an app in the captured language with extra launch arguments.
    ///
    /// - Parameters:
    ///   - app: The app to launch.
    ///   - arguments: Arguments that select demo data or a screen, such as `["-demo-data", "en"]`.
    /// - Returns: The launched app.
    @discardableResult
    public func launch(_ app: XCUIApplication = XCUIApplication(), arguments: [String] = []) -> XCUIApplication {
        app.launchArguments = environment.launchArguments + arguments
        app.launch()
        return app
    }

    /// Takes a screenshot of the whole screen under a name.
    ///
    /// The attachment lifetime is `.keepAlways`; with the default, a passing test discards it.
    ///
    /// - Parameters:
    ///   - name: Lowercase letters, digits and hyphens, matching a scene in the capture configuration.
    ///   - file: The file to report a failure in.
    ///   - line: The line to report a failure on.
    public func shoot(_ name: String, file: StaticString = #filePath, line: UInt = #line) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
        guard let directory = environment.directory else { return }
        do {
            try ScreenshotFile.write(screenshot.pngRepresentation, named: name, in: directory)
        } catch {
            XCTFail("Could not write \(name).png to \(directory.path): \(error)", file: file, line: line)
        }
    }
}
#endif
