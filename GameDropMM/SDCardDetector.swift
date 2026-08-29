import Foundation
import AppKit
import Combine

struct MiyooSDCard: Identifiable, Equatable, Sendable {
    let url: URL
    let romsFolderName: String

    var id: URL { url }
    var name: String { url.lastPathComponent }

    var romsURL: URL {
        var result = url
        for part in romsFolderName.split(separator: "/") where !part.isEmpty {
            result = result.appendingPathComponent(String(part), isDirectory: true)
        }
        return result
    }
}

@MainActor
final class SDCardDetector: ObservableObject {
    @Published private(set) var cards: [MiyooSDCard] = []
    @Published var selectedCardID: URL?
    @Published private(set) var isEjecting = false

    private let settings: AppSettings
    private var timer: Timer?
    private var settingsObserver: AnyCancellable?
    private let fileManager = FileManager.default

    /// Folders that typically appear on OnionOS / Miyoo Mini cards.
    private let markers = [
        "Emu", "Bios", "BIOS", "RetroArch", "App",
        ".tmp_update", "miyoo", "Miyoo", "Saves", "Onion", "Roms", "roms"
    ]

    var selectedCard: MiyooSDCard? {
        if let id = selectedCardID {
            return cards.first { $0.id == id } ?? cards.first
        }
        return cards.first
    }

    init(settings: AppSettings) {
        self.settings = settings
        settingsObserver = settings.$romsRootFolder
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.scan()
            }
    }

    func start() {
        scan()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.scan()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Ejects the selected Miyoo SD volume (Finder-style unmount).
    func ejectSelected() throws {
        guard let card = selectedCard else { return }
        isEjecting = true
        defer {
            isEjecting = false
            scan()
        }
        try NSWorkspace.shared.unmountAndEjectDevice(at: card.url)
        selectedCardID = nil
    }

    func scan() {
        let romsFolder = settings.romsRootFolder
        let volumes = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: [.volumeIsRemovableKey, .volumeNameKey],
            options: [.skipHiddenVolumes]
        ) ?? []

        let found = volumes.compactMap { volume -> MiyooSDCard? in
            let path = volume.path
            if path == "/" || path.hasPrefix("/System") { return nil }

            let card = MiyooSDCard(url: volume, romsFolderName: romsFolder)
            let roms = card.romsURL

            var isDir: ObjCBool = false
            let romsExists = fileManager.fileExists(atPath: roms.path, isDirectory: &isDir) && isDir.boolValue

            let hasMarker = markers.contains { name in
                fileManager.fileExists(atPath: volume.appendingPathComponent(name).path)
            }

            let hasOnionFolder = ROMSystem.allCases.contains { system in
                fileManager.fileExists(
                    atPath: roms.appendingPathComponent(system.rawValue, isDirectory: true).path
                )
            }

            // Detect Miyoo cards even if the configured ROM root doesn’t exist yet —
            // import will create it.
            guard hasMarker || hasOnionFolder || romsExists else { return nil }
            return card
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        let previousIDs = Set(cards.map(\.id))
        let newIDs = Set(found.map(\.id))
        if previousIDs != newIDs || cards != found {
            cards = found
            if selectedCardID == nil || !(newIDs.contains(selectedCardID!)) {
                selectedCardID = found.first?.id
            }
        }
    }
}
