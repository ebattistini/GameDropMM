import Foundation
import AppKit

struct TransferRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let sourceName: String
    let systemFolder: String?
    let systemDisplayName: String?
    /// Absolute path on disk (used for Finder reveal).
    let destinationPath: String?
    /// Relative path on the SD card, e.g. `Roms/SFC/Game.sfc`.
    let relativeDestinationPath: String?
    let cardName: String
    let date: Date
    let success: Bool
    let skipped: Bool
    let failureMessage: String?

    var destinationURL: URL? {
        guard let destinationPath, !destinationPath.isEmpty else { return nil }
        return URL(fileURLWithPath: destinationPath)
    }

    var displayPath: String? {
        if let relativeDestinationPath, !relativeDestinationPath.isEmpty {
            return relativeDestinationPath
        }
        return destinationPath
    }

    var exists: Bool {
        guard let destinationPath else { return false }
        return FileManager.default.fileExists(atPath: destinationPath)
    }

    var canRevealInFinder: Bool {
        exists || parentExists
    }

    private var parentExists: Bool {
        guard let url = destinationURL else { return false }
        return FileManager.default.fileExists(atPath: url.deletingLastPathComponent().path)
    }

    enum CodingKeys: String, CodingKey {
        case id, sourceName, systemFolder, systemDisplayName
        case destinationPath, relativeDestinationPath, cardName, date, success, skipped, failureMessage
    }

    init(
        id: UUID = UUID(),
        sourceName: String,
        systemFolder: String?,
        systemDisplayName: String?,
        destinationPath: String?,
        relativeDestinationPath: String? = nil,
        cardName: String,
        date: Date = Date(),
        success: Bool,
        skipped: Bool = false,
        failureMessage: String? = nil
    ) {
        self.id = id
        self.sourceName = sourceName
        self.systemFolder = systemFolder
        self.systemDisplayName = systemDisplayName
        self.destinationPath = destinationPath
        self.relativeDestinationPath = relativeDestinationPath
        self.cardName = cardName
        self.date = date
        self.success = success
        self.skipped = skipped
        self.failureMessage = failureMessage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        sourceName = try container.decode(String.self, forKey: .sourceName)
        systemFolder = try container.decodeIfPresent(String.self, forKey: .systemFolder)
        systemDisplayName = try container.decodeIfPresent(String.self, forKey: .systemDisplayName)
        destinationPath = try container.decodeIfPresent(String.self, forKey: .destinationPath)
        relativeDestinationPath = try container.decodeIfPresent(String.self, forKey: .relativeDestinationPath)
        cardName = try container.decode(String.self, forKey: .cardName)
        date = try container.decode(Date.self, forKey: .date)
        // Older history entries were success-only
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? true
        skipped = try container.decodeIfPresent(Bool.self, forKey: .skipped) ?? false
        failureMessage = try container.decodeIfPresent(String.self, forKey: .failureMessage)
    }
}

@MainActor
final class TransferHistory: ObservableObject {
    @Published private(set) var records: [TransferRecord] = []

    private let maxRecords = 200
    private let legacyDefaultsKey = "transferHistory"

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            if let string = try? container.decode(String.self) {
                if let date = ISO8601DateFormatter().date(from: string) {
                    return date
                }
            }
            if let interval = try? container.decode(Double.self) {
                return Date(timeIntervalSinceReferenceDate: interval)
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date format"
            )
        }
        return decoder
    }()

    private var storageURL: URL {
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        let folder = appSupport.appendingPathComponent("GameDropMM", isDirectory: true)
        return folder.appendingPathComponent("transfer-history.json")
    }

    init() {
        load()
    }

    func add(from results: [ImportResult], cardName: String) {
        let newRecords = results.map { result in
            TransferRecord(
                sourceName: result.sourceName,
                systemFolder: result.systemFolder,
                systemDisplayName: result.systemDisplayName,
                destinationPath: result.destinationAbsolutePath,
                relativeDestinationPath: result.destinationPath,
                cardName: cardName,
                success: result.success,
                skipped: result.skipped,
                failureMessage: result.success ? (result.skipped ? result.message : nil) : result.message
            )
        }

        guard !newRecords.isEmpty else { return }
        records = (newRecords + records).prefix(maxRecords).map { $0 }
        save()
    }

    func clear() {
        records = []
        save()
    }

    func revealInFinder(_ record: TransferRecord) {
        guard let url = record.destinationURL else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            let parent = url.deletingLastPathComponent()
            if FileManager.default.fileExists(atPath: parent.path) {
                NSWorkspace.shared.open(parent)
            }
        }
    }

    private func load() {
        let fm = FileManager.default
        let url = storageURL

        if fm.fileExists(atPath: url.path),
           let data = try? Data(contentsOf: url),
           let decoded = try? Self.decoder.decode([TransferRecord].self, from: data) {
            records = decoded
            return
        }

        // Migrate older UserDefaults history if present
        if let data = UserDefaults.standard.data(forKey: legacyDefaultsKey),
           let decoded = try? Self.decoder.decode([TransferRecord].self, from: data) {
            records = decoded
            save()
            UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
            return
        }

        records = []
    }

    private func save() {
        let fm = FileManager.default
        let url = storageURL
        let folder = url.deletingLastPathComponent()

        do {
            try fm.createDirectory(at: folder, withIntermediateDirectories: true)
            let data = try Self.encoder.encode(records)
            try data.write(to: url, options: [.atomic])
        } catch {
            assertionFailure("Failed to save transfer history: \(error)")
        }
    }
}
