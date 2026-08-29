import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var history: TransferHistory
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var detector: SDCardDetector
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    @State private var isTargeted = false
    @State private var isImporting = false
    @State private var pendingURLs: [URL] = []
    @State private var showSystemPicker = false
    @State private var manualSystem: ROMSystem = .snes
    @State private var statusBanner: StatusBanner?

    var body: some View {
        ZStack {
            dropZone
                .frame(width: 380, height: 380)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            if let statusBanner {
                VStack {
                    Spacer(minLength: 0)
                    statusPill(statusBanner)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 40)
        .padding(.bottom, 28)
        .frame(minWidth: 560, minHeight: 560)
        .navigationTitle("GameDropMM")
        .onAppear { detector.start() }
        .onDisappear { detector.stop() }
        .sheet(isPresented: $showSystemPicker) {
            systemPickerSheet
        }
        .toolbar {
            if #available(macOS 26.0, *) {
                ToolbarItem(placement: .secondaryAction) {
                    sdStatusLabel
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .secondaryAction) {
                    sdStatusLabel
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    ejectSelectedCard()
                } label: {
                    Image(systemName: "eject.circle")
                }
                .disabled(detector.selectedCard == nil || detector.isEjecting || isImporting)
                .help(detector.selectedCard.map { "Eject \($0.name)" } ?? "No SD card to eject")
            }

            if #available(macOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .primaryAction)
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    openWindow(id: "history")
                } label: {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .help("View previously transferred files")
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    openSettings()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .help("Configure SD ROM folder path")
            }
        }
    }

    private var sdStatusLabel: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(detector.selectedCard == nil ? Color.secondary : Color.green)
                .frame(width: 8, height: 8)

            if let card = detector.selectedCard {
                Text(card.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
            } else {
                Text("No SD card")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .help("Miyoo Mini SD card")
    }

    private func ejectSelectedCard() {
        guard let name = detector.selectedCard?.name else { return }
        do {
            try detector.ejectSelected()
            showStatus(.success, "Ejected \(name).")
        } catch {
            showStatus(.error, "Couldn’t eject \(name): \(error.localizedDescription)")
        }
    }

    private func showStatus(_ kind: StatusBanner.Kind, _ message: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            statusBanner = StatusBanner(kind: kind, message: message)
        }
    }

    private var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(zoneFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(zoneStroke, style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                )

            VStack(spacing: 14) {
                Spacer()

                Image(systemName: isImporting ? "arrow.down.circle" : "square.and.arrow.down")
                    .font(.system(size: 56, weight: .medium))
                    .symbolEffect(.pulse, isActive: isImporting)

                Text(isImporting ? "Copying…" : "Drop your ROMs here")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text("SNES, GBA, PS1, and more will be added automatically")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.horizontal, 28)
            .foregroundStyle(detector.selectedCard == nil ? .secondary : .primary)
            .opacity(detector.selectedCard == nil ? 0.55 : 1)
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers)
        }
    }

    private func statusPill(_ banner: StatusBanner) -> some View {
        HStack(spacing: 8) {
            Image(systemName: banner.kind.symbolName)
                .imageScale(.medium)
            Text(banner.message)
                .font(.callout.weight(.medium))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(banner.kind.foreground)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(banner.kind.background, in: Capsule(style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 2)
    }

    private var zoneFill: Color {
        if isTargeted { return Color.accentColor.opacity(0.12) }
        return Color(nsColor: .controlBackgroundColor)
    }

    private var zoneStroke: Color {
        if isTargeted { return Color.accentColor }
        return Color.secondary.opacity(0.45)
    }

    private var systemPickerSheet: some View {
        VStack(spacing: 16) {
            Text("Which console?")
                .font(.headline)
            Text("Couldn’t auto-detect these files. Pick a destination folder.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Picker("System", selection: $manualSystem) {
                ForEach(ROMSystem.allCases.sorted(by: { $0.displayName < $1.displayName })) { system in
                    Text("\(system.displayName) (\(system.rawValue))").tag(system)
                }
            }
            .pickerStyle(.menu)

            HStack {
                Button("Cancel") {
                    pendingURLs = []
                    showSystemPicker = false
                }
                .keyboardShortcut(.cancelAction)

                Button("Copy to SD") {
                    showSystemPicker = false
                    let urls = pendingURLs
                    pendingURLs = []
                    Task { await runImport(urls, override: manualSystem) }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(detector.selectedCard == nil)
            }
        }
        .padding(24)
        .frame(width: 360)
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard detector.selectedCard != nil else {
            showStatus(.warning, "Plug in a Miyoo Mini SD card first.")
            return false
        }

        let group = DispatchGroup()
        var urls: [URL] = []
        let lock = NSLock()

        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                defer { group.leave() }
                let url: URL?
                if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else if let u = item as? URL {
                    url = u
                } else {
                    url = nil
                }
                if let url {
                    lock.lock()
                    urls.append(url)
                    lock.unlock()
                }
            }
        }

        group.notify(queue: .main) {
            guard !urls.isEmpty else { return }
            let map = settings.extensionFolderMap
            let unknown = urls.filter {
                ROMMapper.detectDestination(for: $0, extensionMap: map) == nil && !isDirectory($0)
            }
            let filesOnly = urls.filter { !isDirectory($0) }
            if !filesOnly.isEmpty, unknown.count == filesOnly.count {
                pendingURLs = urls
                showSystemPicker = true
            } else {
                Task { await runImport(urls, override: nil) }
            }
        }

        return true
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
    }

    @MainActor
    private func runImport(_ urls: [URL], override: ROMSystem?) async {
        guard let card = detector.selectedCard else {
            showStatus(.error, "No Miyoo Mini SD card detected.")
            return
        }

        isImporting = true
        withAnimation { statusBanner = nil }
        defer { isImporting = false }

        let extensionMap = settings.extensionFolderMap
        let destinationOverride = override.map(DetectedDestination.init(system:))

        do {
            let imported = try await Task.detached(priority: .userInitiated) {
                try ROMImporter().importURLs(
                    urls,
                    to: card,
                    extensionMap: extensionMap,
                    destinationOverride: destinationOverride
                )
            }.value

            history.add(from: imported, cardName: card.name)

            let copied = imported.filter { $0.success && !$0.skipped }.count
            let skipped = imported.filter(\.skipped).count
            let fail = imported.filter { !$0.success }.count

            var parts: [String] = []
            if copied > 0 { parts.append("Copied \(copied)") }
            if skipped > 0 { parts.append("skipped \(skipped)") }
            if fail > 0 { parts.append("failed \(fail)") }

            if parts.isEmpty {
                showStatus(.warning, "Nothing to transfer.")
            } else if fail > 0 {
                showStatus(.error, parts.joined(separator: ", ") + ".")
            } else if skipped > 0 && copied == 0 {
                showStatus(.warning, "All \(skipped) already on \(card.name) — skipped.")
            } else if skipped > 0 {
                showStatus(.warning, parts.joined(separator: ", ") + ".")
            } else {
                showStatus(.success, parts.joined(separator: ", ") + ".")
            }
        } catch {
            showStatus(.error, error.localizedDescription)
        }
    }
}

struct StatusBanner: Equatable {
    enum Kind: Equatable {
        case success, warning, error

        var symbolName: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }

        var foreground: Color {
            switch self {
            case .success: return Color(red: 0.12, green: 0.45, blue: 0.22)
            case .warning: return Color(red: 0.45, green: 0.30, blue: 0.05)
            case .error: return Color(red: 0.55, green: 0.12, blue: 0.12)
            }
        }

        var background: Color {
            switch self {
            case .success: return Color(red: 0.82, green: 0.94, blue: 0.85)
            case .warning: return Color(red: 0.98, green: 0.92, blue: 0.75)
            case .error: return Color(red: 0.97, green: 0.84, blue: 0.84)
            }
        }
    }

    let kind: Kind
    let message: String
}

struct HistoryView: View {
    @EnvironmentObject private var history: TransferHistory

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        Group {
            if history.records.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No transfers yet")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(history.records) { record in
                    historyRow(record)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 420)
        .frame(width: 520, height: 560)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Clear") {
                    history.clear()
                }
                .disabled(history.records.isEmpty)
            }
        }
    }

    @ViewBuilder
    private func historyRow(_ record: TransferRecord) -> some View {
        Button {
            if record.canRevealInFinder {
                history.revealInFinder(record)
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: rowIcon(for: record))
                    .foregroundStyle(rowIconColor(for: record))
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 3) {
                    Text(record.sourceName)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(subtitle(for: record))
                        .font(.caption)
                        .foregroundStyle(subtitleColor(for: record))
                        .lineLimit(3)
                    if let path = record.displayPath {
                        Text(path)
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .textSelection(.enabled)
                    }
                    Text(Self.dateFormatter.string(from: record.date))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer(minLength: 0)

                if record.canRevealInFinder {
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!record.canRevealInFinder)
        .help(rowHelp(for: record))
    }

    private func rowIcon(for record: TransferRecord) -> String {
        if !record.success { return "xmark.circle.fill" }
        if record.skipped { return "minus.circle.fill" }
        if record.exists { return "checkmark.circle.fill" }
        return "doc.questionmark"
    }

    private func rowIconColor(for record: TransferRecord) -> Color {
        if !record.success { return .red }
        if record.skipped { return .orange }
        if record.exists { return .green }
        return .secondary
    }

    private func subtitleColor(for record: TransferRecord) -> Color {
        if !record.success { return Color.red.opacity(0.85) }
        if record.skipped { return Color.orange.opacity(0.9) }
        return .secondary
    }

    private func rowHelp(for record: TransferRecord) -> String {
        if !record.success { return record.failureMessage ?? "Transfer failed" }
        if record.skipped { return "Already on SD — show in Finder" }
        if record.exists { return "Show in Finder" }
        return "File missing — open parent folder if available"
    }

    private func subtitle(for record: TransferRecord) -> String {
        if !record.success {
            return record.failureMessage ?? "Transfer failed"
        }
        if record.skipped {
            return record.failureMessage ?? "Already on SD — skipped"
        }

        var parts: [String] = []
        if let name = record.systemDisplayName, let folder = record.systemFolder {
            parts.append("\(name) (\(folder))")
        }
        parts.append(record.cardName)
        if !record.exists {
            parts.append("not on disk")
        }
        return parts.joined(separator: " · ")
    }
}
