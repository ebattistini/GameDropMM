import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var detector: SDCardDetector
    @State private var showAddSheet = false

    var body: some View {
        TabView {
            romLocationTab
                .tabItem {
                    Label("Location", systemImage: "folder")
                }

            extensionRulesTab
                .tabItem {
                    Label("Extensions", systemImage: "doc.badge.gearshape")
                }
        }
        .frame(width: 480, height: 360)
        .sheet(isPresented: $showAddSheet) {
            AddExtensionRuleSheet { ext, folder in
                settings.addExtensionOverride(fileExtension: ext, folder: folder)
            }
        }
    }

    private var romLocationTab: some View {
        Form {
            Section {
                TextField("ROM folder", text: $settings.romsRootFolder)
                    .textFieldStyle(.roundedBorder)

                Text("Relative to the SD card root. Console folders (SFC, GBA, PS, …) are created inside this path.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let card = detector.selectedCard {
                    LabeledContent("Current SD") {
                        Text(card.name)
                    }
                    LabeledContent("Games path") {
                        Text(card.romsURL.path)
                            .textSelection(.enabled)
                            .font(.caption.monospaced())
                    }
                } else {
                    Text("No Miyoo SD card detected right now.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("Reset to Onion default (Roms)") {
                    settings.resetRomsRootFolder()
                }
            } header: {
                Text("SD card ROM location")
            } footer: {
                Text("If transferred games don’t show on your Miyoo, confirm this matches the folder Onion (or your CFW) uses.")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var extensionRulesTab: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Built-in mappings stay in place. Add overrides only when you need a special case.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 12)
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .help("Add extension override")

                Button {
                    settings.clearExtensionOverrides()
                } label: {
                    Image(systemName: "trash")
                }
                .help("Clear all overrides")
                .disabled(settings.extensionOverrides.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            if settings.extensionOverrides.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No custom overrides")
                        .foregroundStyle(.secondary)
                    Text("Press + to map an extension to a folder.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(settings.extensionOverrides) { rule in
                        HStack {
                            Text(".\(rule.fileExtension)")
                                .font(.body.monospaced())
                                .frame(width: 80, alignment: .leading)
                            Image(systemName: "arrow.right")
                                .foregroundStyle(.secondary)
                            Text(rule.folder)
                                .font(.body.weight(.medium))
                            if let system = ROMSystem(rawValue: rule.folder) {
                                Text(system.displayName)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                settings.removeExtensionOverride(rule)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red.opacity(0.85))
                            }
                            .buttonStyle(.plain)
                            .help("Remove override")
                        }
                    }
                    .onDelete(perform: settings.removeExtensionOverrides)
                }
            }
        }
    }
}

private struct AddExtensionRuleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fileExtension = ""
    @State private var folder = "SFC"
    @State private var selectedPreset = "SFC"

    let onAdd: (String, String) -> Void

    private var canAdd: Bool {
        let ext = fileExtension.trimmingCharacters(in: .whitespacesAndNewlines)
        let folderName = folder.trimmingCharacters(in: .whitespacesAndNewlines)
        return !ext.isEmpty && !folderName.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add extension override")
                .font(.headline)

            Text("Choose a file extension and the SD folder it should go into.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack {
                Text("Extension")
                    .frame(width: 90, alignment: .leading)
                Text(".")
                    .foregroundStyle(.secondary)
                TextField("smc", text: $fileExtension)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }

            HStack(alignment: .firstTextBaseline) {
                Text("Folder")
                    .frame(width: 90, alignment: .leading)
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Folder", selection: $selectedPreset) {
                        ForEach(ROMSystem.allCases.sorted(by: { $0.displayName < $1.displayName })) { system in
                            Text("\(system.displayName) (\(system.rawValue))")
                                .tag(system.rawValue)
                        }
                        Text("Custom…").tag("__custom__")
                    }
                    .labelsHidden()
                    .onChange(of: selectedPreset) { _, newValue in
                        if newValue != "__custom__" {
                            folder = newValue
                        }
                    }

                    if selectedPreset == "__custom__" {
                        TextField("CUSTOMFOLDER", text: $folder)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 180)
                    } else {
                        Text(folder)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Add") {
                    onAdd(fileExtension, folder)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canAdd)
            }
        }
        .padding(24)
        .frame(width: 420)
        .onAppear {
            folder = selectedPreset
        }
    }
}
