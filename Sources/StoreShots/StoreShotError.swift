import Foundation

/// A reason a store screenshot test cannot continue.
public enum StoreShotError: Error, Equatable, CustomStringConvertible {
    /// A required environment variable is absent or empty.
    case missingVariable(String)
    /// A screenshot name that cannot be used as a file name.
    case invalidName(String)
    /// The locale has no entry in the table the test was given.
    case unsupportedLocale(String, supported: [String])

    /// A sentence that says what is wrong and how to fix it.
    public var description: String {
        switch self {
        case .missingVariable(let key):
            "\(key) is not set. Run the capture through a script that sets it (pulse shots), or pass TEST_RUNNER_\(key) to xcodebuild."
        case .invalidName(let name):
            "\"\(name)\" is not a screenshot name. Use lowercase letters, digits and hyphens, such as \"habit-add\" or \"01-home\"."
        case .unsupportedLocale(let locale, let supported):
            "No capture is defined for \(locale). Defined: \(supported.joined(separator: ", "))."
        }
    }
}
