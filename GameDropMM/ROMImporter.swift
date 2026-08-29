import Foundation

struct ImportResult: Identifiable {
    let id = UUID()
    let sourceName: String
    let systemFolder: String?
    let systemDisplayName: String?
    let destinationPath: String?
    let destinationAbsolutePath: String?
    let success: Bool
    let skipped: Bool
    let message: String
}

enum ImportError: LocalizedError {
    case noSDCard
    case unknownSystem(String)
    case copyFailed(String)

    var errorDescription: String? {
        switch self {
        case .noSDCard:
            return "No Miyoo Mini SD card detected."
        case .unknownSystem(let name):
            return "Couldn’t tell which console “\(name)” belongs to."
        case .copyFailed(let detail):
            return detail
        }
    }
}

struct ROMImporter {
    private let fileManager = FileManager.default

    func importURLs(
        _ urls: [URL],
        to card: MiyooSDCard,
        extensionMap: [String: String] = ROMMapper.defaultExtensionFolderMap,
        destinationOverride: DetectedDestination? = nil
    ) throws -> [ImportResult] {
        var results: [ImportResult] = []
        var pending: [URL] = []

        for url in urls {
            let scoped = url.startAccessingSecurityScopedResource()
            defer {
                if scoped { url.stopAccessingSecurityScopedResource() }
            }

            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                let children = (try? fileManager.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )) ?? []
                results.append(contentsOf: try importURLs(
                    children,
                    to: card,
                    extensionMap: extensionMap,
                    destinationOverride: destinationOverride
                ))
                continue
            }

            pending.append(url)
        }

        let expanded = expandDiscSets(pending)
        for url in expanded {
            results.append(importFile(
                url,
                to: card,
                extensionMap: extensionMap,
                destinationOverride: destinationOverride
            ))
        }

        return results
    }

    /// When a `.cue` / `.m3u` / `.bin` is dropped, also pull sibling track files.
    private func expandDiscSets(_ urls: [URL]) -> [URL] {
        var ordered: [URL] = []
        var seen = Set<String>()

        func appendUnique(_ url: URL) {
            let path = url.standardizedFileURL.path
            guard !seen.contains(path) else { return }
            seen.insert(path)
            ordered.append(url)
        }

        for url in urls {
            appendUnique(url)
            for companion in ROMMapper.companionURLs(for: url) {
                appendUnique(companion)
            }
        }

        return ordered
    }

    private func importFile(
        _ url: URL,
        to card: MiyooSDCard,
        extensionMap: [String: String],
        destinationOverride: DetectedDestination?
    ) -> ImportResult {
        let name = url.lastPathComponent
        let destination = destinationOverride
            ?? ROMMapper.detectDestination(for: url, extensionMap: extensionMap)

        guard let destination else {
            return ImportResult(
                sourceName: name,
                systemFolder: nil,
                systemDisplayName: nil,
                destinationPath: nil,
                destinationAbsolutePath: nil,
                success: false,
                skipped: false,
                message: "Unknown console — drop again after picking a system, or rename/place in a folder like SNES."
            )
        }

        let destDir = card.romsURL.appendingPathComponent(destination.folder, isDirectory: true)
        let relativeRoot = card.romsFolderName
        let createdFolder: Bool
        do {
            createdFolder = try ensureSystemFolder(
                destDir,
                relativeLabel: "\(relativeRoot)/\(destination.folder)"
            )
        } catch {
            return ImportResult(
                sourceName: name,
                systemFolder: destination.folder,
                systemDisplayName: destination.displayName,
                destinationPath: nil,
                destinationAbsolutePath: nil,
                success: false,
                skipped: false,
                message: "Couldn’t create \(relativeRoot)/\(destination.folder): \(error.localizedDescription)"
            )
        }

        let dest = destDir.appendingPathComponent(name)
        let relativePath = "\(relativeRoot)/\(destination.folder)/\(name)"
        if fileManager.fileExists(atPath: dest.path) {
            return ImportResult(
                sourceName: name,
                systemFolder: destination.folder,
                systemDisplayName: destination.displayName,
                destinationPath: relativePath,
                destinationAbsolutePath: dest.path,
                success: true,
                skipped: true,
                message: "Already on SD — skipped"
            )
        }

        do {
            try fileManager.copyItem(at: url, to: dest)
            let folderNote = createdFolder ? " · created \(relativeRoot)/\(destination.folder)" : ""
            return ImportResult(
                sourceName: name,
                systemFolder: destination.folder,
                systemDisplayName: destination.displayName,
                destinationPath: "\(relativeRoot)/\(destination.folder)/\(dest.lastPathComponent)",
                destinationAbsolutePath: dest.path,
                success: true,
                skipped: false,
                message: "→ \(destination.displayName) (\(destination.folder))\(folderNote)"
            )
        } catch {
            return ImportResult(
                sourceName: name,
                systemFolder: destination.folder,
                systemDisplayName: destination.displayName,
                destinationPath: nil,
                destinationAbsolutePath: nil,
                success: false,
                skipped: false,
                message: error.localizedDescription
            )
        }
    }

    /// Creates `<romsRoot>/<SYSTEM>` on the SD card when missing. Returns `true` if newly created.
    private func ensureSystemFolder(_ destDir: URL, relativeLabel: String) throws -> Bool {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: destDir.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return false
            }
            throw ImportError.copyFailed("\(relativeLabel) exists but isn’t a folder.")
        }

        try fileManager.createDirectory(at: destDir, withIntermediateDirectories: true)
        return true
    }
}
