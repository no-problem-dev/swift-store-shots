import Foundation
import StoreShots
import XCTest

final class StoreShotEnvironmentTests: XCTestCase {
    private let full = [
        "STORE_SHOTS_LOCALE": "en-US",
        "STORE_SHOTS_LANGUAGE": "en",
        "STORE_SHOTS_REGION": "en_US",
        "STORE_SHOTS_DEVICE": "ipad",
        "STORE_SHOTS_DIR": "/tmp/shots",
        "SIMULATOR_MODEL_IDENTIFIER": "iPad17,1",
    ]

    func testReadsEveryValue() throws {
        let environment = try StoreShotEnvironment(full)
        XCTAssertEqual(environment.locale, "en-US")
        XCTAssertEqual(environment.language, "en")
        XCTAssertEqual(environment.region, "en_US")
        XCTAssertEqual(environment.device, "ipad")
        XCTAssertEqual(environment.directory?.path, "/tmp/shots")
        XCTAssertTrue(environment.isPad)
    }

    func testMissingValueIsAnErrorThatNamesIt() {
        for key in ["STORE_SHOTS_LOCALE", "STORE_SHOTS_LANGUAGE", "STORE_SHOTS_REGION", "STORE_SHOTS_DEVICE"] {
            var environment = full
            environment[key] = ""
            XCTAssertThrowsError(try StoreShotEnvironment(environment)) { error in
                XCTAssertEqual(error as? StoreShotError, .missingVariable(key))
                XCTAssertTrue("\(error)".contains("TEST_RUNNER_\(key)"))
            }
        }
    }

    func testDirectoryIsOptional() throws {
        var environment = full
        environment["STORE_SHOTS_DIR"] = nil
        XCTAssertNil(try StoreShotEnvironment(environment).directory)
    }

    func testLaunchArgumentsSetLanguageAndRegionForOneLaunch() throws {
        XCTAssertEqual(try StoreShotEnvironment(full).launchArguments, ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"])
    }

    func testPressLagOnlyOnIPad() throws {
        XCTAssertEqual(try StoreShotEnvironment(full).pressLag, 1.2)
        var phone = full
        phone["SIMULATOR_MODEL_IDENTIFIER"] = "iPhone18,2"
        XCTAssertEqual(try StoreShotEnvironment(phone).pressLag, 0)
    }

    func testEntryForLocale() throws {
        let environment = try StoreShotEnvironment(full)
        XCTAssertEqual(try environment.entry(in: ["en-US": "Home", "ja": "ホーム"]), "Home")
        XCTAssertThrowsError(try environment.entry(in: ["ja": "ホーム"])) { error in
            XCTAssertEqual(error as? StoreShotError, .unsupportedLocale("en-US", supported: ["ja"]))
        }
    }
}

final class ScreenshotFileTests: XCTestCase {
    func testNames() throws {
        XCTAssertEqual(try ScreenshotFile.fileName(for: "habit-add"), "habit-add.png")
        XCTAssertEqual(try ScreenshotFile.fileName(for: "01-home"), "01-home.png")
        for bad in ["", "-home", "Home", "home page", "home/1", "home.png"] {
            XCTAssertThrowsError(try ScreenshotFile.fileName(for: bad), bad)
        }
    }

    func testWriteCreatesTheDirectory() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("nested")
        defer { try? FileManager.default.removeItem(at: directory.deletingLastPathComponent()) }
        let url = try ScreenshotFile.write(Data([0x89, 0x50, 0x4E, 0x47]), named: "home", in: directory)
        XCTAssertEqual(url.lastPathComponent, "home.png")
        XCTAssertEqual(try Data(contentsOf: url), Data([0x89, 0x50, 0x4E, 0x47]))
    }
}
