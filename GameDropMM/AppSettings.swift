import Foundation
import Combine

struct ExtensionRule: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    /// File extension without a leading dot (e.g. `smc`).
    var fileExtension: String
    /// Destination folder on the SD card (e.g. `SFC`).
    var folder: String

    init(id: UUID = UUID(), fileExtension: String, folder: String) {
        self.id = id
        self.fileExtension = fileExtension
        self.folder = folder
    }
}

@MainActor
final class AppSettings: ObservableObject {
    private enum Keys {
        static let romsRootFolder = "romsRootFolder"
        static let extensionOverrides = "extensionOverrides"
        static let legacyExtensionRules = "extensionRules"
    }

    /// Folder on the SD card root where console folders live (Onion default: `Roms`).
    @Published var romsRootFolder: String {
        didSet {
            let cleaned = Self.sanitizePath(romsRootFolder)
            if cleaned != romsRootFolder {
                romsRootFolder = cleaned
                return
            }
            UserDefaults.standard.set(cleaned, forKey: Keys.romsRootFolder)
        }
    }

    /// User-added overrides only (defaults live in `ROMMapper`).
    @Published var extensionOverrides: [ExtensionRule] {
        didSet {
            let normalized = Self.normalize(extensionOverrides)
            if normalized != extensionOverrides {
                extensionOverrides = normalized
                return
            }
            if let data = try? JSONEncoder().encode(normalized) {
                UserDefaults.standard.set(data, forKey: Keys.extensionOverrides)
            }
        }
    }

    /// Effective map used during import: defaults + overrides (overrides win).
    var extensionFolderMap: [String: String] {
        var map = ROMMapper.defaultExtensionFolderMap
        for rule in extensionOverrides {
            map[rule.fileExtension.lowercased()] = rule.folder
        }
        return map
    }

    static let defaultRomsRootFolder = "Roms"

    init() {
        let storedRoot = UserDefaults.standard.string(forKey: Keys.romsRootFolder)
        romsRootFolder = Self.sanitizePath(storedRoot ?? Self.defaultRomsRootFolder)

        if let data = UserDefaults.standard.data(forKey: Keys.extensionOverrides),
           let decoded = try? JSONDecoder().decode([ExtensionRule].self, from: data) {
            extensionOverrides = Self.normalize(decoded)
        } else if let legacy = UserDefaults.standard.data(forKey: Keys.legacyExtensionRules),
                  let decoded = try? JSONDecoder().decode([ExtensionRule].self, from: legacy) {
            // Migrate old full-list settings into overrides-only (only non-default rows).
            let defaults = ROMMapper.defaultExtensionFolderMap
            extensionOverrides = Self.normalize(decoded.filter { rule in
                defaults[rule.fileExtension.lowercased()] != rule.folder
            })
            UserDefaults.standard.removeObject(forKey: Keys.legacyExtensionRules)
        } else {
            extensionOverrides = []
        }
    }

    func resetRomsRootFolder() {
        romsRootFolder = Self.defaultRomsRootFolder
    }

    func addExtensionOverride(fileExtension: String, folder: String) {
        let ext = Self.sanitizeExtension(fileExtension)
        let folderName = Self.sanitizeFolder(folder)
        guard !ext.isEmpty, !folderName.isEmpty else { return }

        if let index = extensionOverrides.firstIndex(where: { $0.fileExtension == ext }) {
            extensionOverrides[index].folder = folderName
        } else {
            extensionOverrides.append(ExtensionRule(fileExtension: ext, folder: folderName))
        }
    }

    func removeExtensionOverrides(at offsets: IndexSet) {
        extensionOverrides.remove(atOffsets: offsets)
    }

    func removeExtensionOverride(_ rule: ExtensionRule) {
        extensionOverrides.removeAll { $0.id == rule.id }
    }

    func clearExtensionOverrides() {
        extensionOverrides = []
    }

    private static func sanitizePath(_ value: String) -> String {
        var path = value.trimmingCharacters(in: .whitespacesAndNewlines)
        while path.hasPrefix("/") { path.removeFirst() }
        while path.hasSuffix("/") { path.removeLast() }
        path = path.replacingOccurrences(of: "\\", with: "/")
        if path.isEmpty { return defaultRomsRootFolder }
        return path
    }

    private static func sanitizeExtension(_ value: String) -> String {
        var ext = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if ext.hasPrefix(".") { ext.removeFirst() }
        return ext
    }

    private static func sanitizeFolder(_ value: String) -> String {
        var folder = value.trimmingCharacters(in: .whitespacesAndNewlines)
        while folder.hasPrefix("/") { folder.removeFirst() }
        while folder.hasSuffix("/") { folder.removeLast() }
        return folder
    }

    private static func normalize(_ rules: [ExtensionRule]) -> [ExtensionRule] {
        var seen = Set<String>()
        var result: [ExtensionRule] = []

        for rule in rules {
            let ext = sanitizeExtension(rule.fileExtension)
            let folder = sanitizeFolder(rule.folder)
            guard !ext.isEmpty, !folder.isEmpty, !seen.contains(ext) else { continue }
            seen.insert(ext)
            result.append(ExtensionRule(id: rule.id, fileExtension: ext, folder: folder))
        }
        return result.sorted { $0.fileExtension < $1.fileExtension }
    }
}
