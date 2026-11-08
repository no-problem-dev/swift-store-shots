import Foundation

/// The rules for naming and writing a screenshot file.
public enum ScreenshotFile {
    /// Checks that a name can be used as a file name and as a scene name in the capture configuration.
    ///
    /// Names are lowercase letters, digits and hyphens, and start with a letter or digit, such as
    /// `home`, `habit-add` or `01-home`.
    ///
    /// - Parameter name: The name passed to ``StoreShooter/shoot(_:file:line:)``.
    /// - Returns: The file name, `<name>.png`.
    /// - Throws: ``StoreShotError/invalidName(_:)`` when the name has other characters.
    public static func fileName(for name: String) throws -> String {
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789-")
        guard let first = name.first, first != "-", name.allSatisfy(allowed.contains) else {
            throw StoreShotError.invalidName(name)
        }
        return "\(name).png"
    }

    /// Writes PNG data as `<name>.png` in a directory, creating the directory when needed.
    ///
    /// - Parameters:
    ///   - png: The encoded image.
    ///   - name: The screenshot name.
    ///   - directory: The directory to write into.
    /// - Returns: The URL of the written file.
    /// - Throws: ``StoreShotError/invalidName(_:)`` for a bad name, or the error from writing the file.
    @discardableResult
    public static func write(_ png: Data, named name: String, in directory: URL) throws -> URL {
        let url = directory.appendingPathComponent(try fileName(for: name))
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try png.write(to: url, options: .atomic)
        return url
    }
}
