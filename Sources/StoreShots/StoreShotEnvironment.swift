import Foundation

/// The values a capture script hands to a store screenshot test through the environment.
///
/// A script such as `pulse shots` passes each value to `xcodebuild` as `TEST_RUNNER_<name>`, and
/// `xcodebuild` strips the prefix before the test sees it. Every value except the output directory
/// is required: a test that silently fell back to one language would produce a full set of images
/// in the wrong language and still pass.
public struct StoreShotEnvironment: Sendable, Equatable {
    /// The names of the environment variables this type reads.
    public enum Key {
        /// The App Store locale being captured, such as `en-US` or `zh-Hans`.
        public static let locale = "STORE_SHOTS_LOCALE"
        /// The language passed to the app as `-AppleLanguages`, such as `en`.
        public static let language = "STORE_SHOTS_LANGUAGE"
        /// The region passed to the app as `-AppleLocale`, such as `en_US`.
        public static let region = "STORE_SHOTS_REGION"
        /// The name of the device in the capture configuration, such as `iphone` or `ipad`.
        public static let device = "STORE_SHOTS_DEVICE"
        /// A directory on the Mac where each screenshot is also written as `<name>.png`.
        public static let directory = "STORE_SHOTS_DIR"
        /// Set by the simulator to the model of the simulated device, such as `iPad17,1`.
        public static let simulatorModel = "SIMULATOR_MODEL_IDENTIFIER"
    }

    /// The App Store locale being captured.
    public let locale: String
    /// The language the app is launched in.
    public let language: String
    /// The region the app is launched in.
    public let region: String
    /// The device name from the capture configuration.
    public let device: String
    /// Where screenshots are also written, when the script asked for it.
    public let directory: URL?
    /// Whether the test runs on an iPad simulator.
    public let isPad: Bool

    /// Reads the values from an environment dictionary.
    ///
    /// - Parameter environment: The environment to read, usually `ProcessInfo.processInfo.environment`.
    /// - Throws: ``StoreShotError/missingVariable(_:)`` when a required value is absent or empty.
    public init(_ environment: [String: String]) throws {
        func required(_ key: String) throws -> String {
            guard let value = environment[key], !value.isEmpty else { throw StoreShotError.missingVariable(key) }
            return value
        }
        locale = try required(Key.locale)
        language = try required(Key.language)
        region = try required(Key.region)
        device = try required(Key.device)
        directory = environment[Key.directory].flatMap { $0.isEmpty ? nil : URL(fileURLWithPath: $0, isDirectory: true) }
        isPad = (environment[Key.simulatorModel] ?? "").hasPrefix("iPad")
    }

    /// Reads the values from the current process.
    ///
    /// - Throws: ``StoreShotError/missingVariable(_:)`` when a required value is absent or empty.
    public static func current() throws -> StoreShotEnvironment {
        try StoreShotEnvironment(ProcessInfo.processInfo.environment)
    }

    /// Launch arguments that open the app in ``language`` and ``region`` for this launch only.
    ///
    /// Nothing is written to the simulator, so a finished capture leaves no language setting behind.
    public var launchArguments: [String] {
        ["-AppleLanguages", "(\(language))", "-AppleLocale", region]
    }

    /// Looks up the entry for ``locale`` in a table the test defines, such as tab titles per locale.
    ///
    /// - Parameter table: Values keyed by App Store locale.
    /// - Returns: The value for ``locale``.
    /// - Throws: ``StoreShotError/unsupportedLocale(_:supported:)`` when the table has no entry for it.
    public func entry<Value>(in table: [String: Value]) throws -> Value {
        guard let value = table[locale] else {
            throw StoreShotError.unsupportedLocale(locale, supported: table.keys.sorted())
        }
        return value
    }

    /// Extra time to add to a long press so that it lasts long enough inside the app.
    ///
    /// On an iPad 13-inch simulator the start of a press reached the app about one second late, so a
    /// 1.6-second press released a gesture that was only half complete. iPhone simulators show no delay.
    public var pressLag: TimeInterval {
        isPad ? 1.2 : 0
    }
}
