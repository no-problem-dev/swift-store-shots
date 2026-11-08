#if os(iOS)
import XCTest

// Every helper fails the test when the wait runs out. A capture that went on after a missing screen
// would shoot whatever happened to be visible and still produce a full set of images.

@MainActor
extension XCUIElement {
    /// Waits until the element exists, and fails the test if it does not.
    ///
    /// - Parameters:
    ///   - what: What the element is, used in the failure message.
    ///   - timeout: Seconds to wait.
    ///   - file: The file to report a failure in.
    ///   - line: The line to report a failure on.
    /// - Returns: Whether the element appeared.
    @discardableResult
    public func waitToAppear(_ what: String, timeout: TimeInterval = 15, file: StaticString = #filePath, line: UInt = #line) -> Bool {
        let appeared = waitForExistence(timeout: timeout)
        if !appeared { XCTFail("\(what) did not appear within \(Int(timeout)) seconds", file: file, line: line) }
        return appeared
    }

    /// Waits until the element can be tapped, and fails the test if it cannot.
    ///
    /// A tap sent while a sheet is still rising does not reach the element, so wait for this first.
    ///
    /// - Parameters:
    ///   - what: What the element is, used in the failure message.
    ///   - timeout: Seconds to wait.
    ///   - file: The file to report a failure in.
    ///   - line: The line to report a failure on.
    /// - Returns: Whether the element became hittable.
    @discardableResult
    public func waitToBeHittable(_ what: String, timeout: TimeInterval = 10, file: StaticString = #filePath, line: UInt = #line) -> Bool {
        waitUntil("isHittable == true", what: "\(what) did not become tappable", timeout: timeout, file: file, line: line)
    }

    /// Waits until the element no longer exists, and fails the test if it remains.
    ///
    /// - Parameters:
    ///   - what: What the element is, used in the failure message.
    ///   - timeout: Seconds to wait.
    ///   - file: The file to report a failure in.
    ///   - line: The line to report a failure on.
    /// - Returns: Whether the element went away.
    @discardableResult
    public func waitToDisappear(_ what: String, timeout: TimeInterval = 10, file: StaticString = #filePath, line: UInt = #line) -> Bool {
        waitUntil("exists == false", what: "\(what) did not go away", timeout: timeout, file: file, line: line)
    }

    /// Waits until the element is enabled, and fails the test if it stays disabled.
    ///
    /// - Parameters:
    ///   - what: What the element is, used in the failure message.
    ///   - timeout: Seconds to wait.
    ///   - file: The file to report a failure in.
    ///   - line: The line to report a failure on.
    /// - Returns: Whether the element became enabled.
    @discardableResult
    public func waitToBeEnabled(_ what: String, timeout: TimeInterval = 15, file: StaticString = #filePath, line: UInt = #line) -> Bool {
        waitUntil("isEnabled == true", what: "\(what) did not become enabled", timeout: timeout, file: file, line: line)
    }

    /// Presses and holds the element, adding the delay an iPad simulator shows before a press arrives.
    ///
    /// Use it for SwiftUI long-press gestures. Synthetic taps from `simctl` or AXe do not always reach
    /// them; a press from XCUITest does.
    ///
    /// - Parameters:
    ///   - duration: How long the press should last inside the app.
    ///   - environment: The capture environment, which knows whether the device is an iPad.
    public func hold(for duration: TimeInterval, in environment: StoreShotEnvironment) {
        press(forDuration: duration + environment.pressLag)
    }

    private func waitUntil(_ predicate: String, what message: String, timeout: TimeInterval, file: StaticString, line: UInt) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: predicate), object: self)
        let done = XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
        if !done { XCTFail("\(message) within \(Int(timeout)) seconds", file: file, line: line) }
        return done
    }
}

@MainActor
extension XCUIElementQuery {
    /// The smallest hittable element among the matches.
    ///
    /// A card combined with `.accessibilityElement(children: .combine)` takes the identifier of the
    /// button inside it, so one identifier matches both. The smaller element is the button itself.
    ///
    /// - Parameters:
    ///   - what: What the element is, used in the failure message.
    ///   - file: The file to report a failure in.
    ///   - line: The line to report a failure on.
    /// - Returns: The smallest hittable match, or the first match after failing the test.
    public func smallestHittable(_ what: String, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let hittable = allElementsBoundByIndex.filter { $0.exists && $0.isHittable }
        guard let smallest = hittable.min(by: { $0.frame.width * $0.frame.height < $1.frame.width * $1.frame.height }) else {
            XCTFail("\(what) is not on screen in a tappable form", file: file, line: line)
            return firstMatch
        }
        return smallest
    }
}

@MainActor
extension XCUIApplication {
    /// Opens a tab by position on iPhone and by title on iPad.
    ///
    /// On iPhone the bottom tab bar is searched by index, so the title can change with the language.
    /// On iPad the tabs move to the top, `tabBars` can be empty and the row can hold other buttons,
    /// so the title is tried first.
    ///
    /// - Parameters:
    ///   - index: The position of the tab in the iPhone tab bar.
    ///   - title: The tab title in the captured language.
    ///   - environment: The capture environment, which knows whether the device is an iPad.
    ///   - timeout: Seconds to keep looking.
    ///   - file: The file to report a failure in.
    ///   - line: The line to report a failure on.
    public func openTab(index: Int, title: String, in environment: StoreShotEnvironment, timeout: TimeInterval = 15, file: StaticString = #filePath, line: UInt = #line) {
        let byIndex = tabBars.buttons.element(boundBy: index)
        let byTitle = [tabBars.buttons[title], buttons[title].firstMatch]
        let candidates = environment.isPad ? byTitle + [byIndex] : [byIndex] + byTitle
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let hit = candidates.first(where: { $0.exists && $0.isHittable }) {
                hit.tap()
                return
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        XCTFail("Tab \"\(title)\" is in neither the tab bar nor the top tabs", file: file, line: line)
    }
}
#endif
