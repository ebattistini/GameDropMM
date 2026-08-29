import SwiftUI

@main
struct GameDropMMApp: App {
    @StateObject private var settings: AppSettings
    @StateObject private var history: TransferHistory
    @StateObject private var detector: SDCardDetector

    init() {
        let settings = AppSettings()
        _settings = StateObject(wrappedValue: settings)
        _history = StateObject(wrappedValue: TransferHistory())
        _detector = StateObject(wrappedValue: SDCardDetector(settings: settings))
    }

    var body: some Scene {
        WindowGroup("GameDropMM") {
            ContentView()
                .environmentObject(history)
                .environmentObject(settings)
                .environmentObject(detector)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 560, height: 620)

        Window("Transfer History", id: "history") {
            HistoryView()
                .environmentObject(history)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 520, height: 560)

        Settings {
            SettingsView()
                .environmentObject(settings)
                .environmentObject(detector)
        }
    }
}
