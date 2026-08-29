import Foundation

/// OnionOS rom folder names (case-sensitive).
/// https://onionui.github.io/docs/emulators/folders
enum ROMSystem: String, CaseIterable, Identifiable {
    case amiga = "AMIGA"
    case cpc = "CPC"
    case arcade = "ARCADE"
    case atari2600 = "ATARI"
    case atari5200 = "FIFTYTWOHUNDRED"
    case atari7800 = "SEVENTYEIGHTHUNDRED"
    case lynx = "LYNX"
    case sufami = "SUFAMI"
    case wonderswan = "WS"
    case c64 = "COMMODORE"
    case cps1 = "CPS1"
    case cps2 = "CPS2"
    case cps3 = "CPS3"
    case coleco = "COLECO"
    case fairchild = "FAIRCHILD"
    case fds = "FDS"
    case gameAndWatch = "GW"
    case vectrex = "VECTREX"
    case odyssey = "ODYSSEY"
    case intellivision = "INTELLIVISION"
    case megaduck = "MEGADUCK"
    case dos = "DOS"
    case msx = "MSX"
    case sgfx = "SGFX"
    case pcecd = "PCECD"
    case pce = "PCE"
    case nds = "NDS"
    case nes = "FC"
    case gb = "GB"
    case gba = "GBA"
    case gbc = "GBC"
    case pokemini = "POKE"
    case satellaview = "SATELLAVIEW"
    case sgb = "SGB"
    case snes = "SFC"
    case virtualBoy = "VB"
    case pico8 = "PICO"
    case ports = "PORTS"
    case scummvm = "SCUMMVM"
    case sega32x = "THIRTYTWOX"
    case segaCD = "SEGACD"
    case gameGear = "GG"
    case genesis = "MD"
    case masterSystem = "MS"
    case sg1000 = "SEGASGONE"
    case zxSpectrum = "ZXS"
    case neogeo = "NEOGEO"
    case neoCD = "NEOCD"
    case ngp = "NGP"
    case playstation = "PS"
    case tic80 = "TIC"
    case vic20 = "VIC20"
    case videopac = "VIDEOPAC"
    case supervision = "SUPERVISION"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .amiga: return "Amiga"
        case .cpc: return "Amstrad CPC"
        case .arcade: return "Arcade"
        case .atari2600: return "Atari 2600"
        case .atari5200: return "Atari 5200"
        case .atari7800: return "Atari 7800"
        case .lynx: return "Atari Lynx"
        case .sufami: return "Sufami Turbo"
        case .wonderswan: return "WonderSwan"
        case .c64: return "Commodore 64"
        case .cps1: return "CPS1"
        case .cps2: return "CPS2"
        case .cps3: return "CPS3"
        case .coleco: return "ColecoVision"
        case .fairchild: return "Fairchild Channel F"
        case .fds: return "Famicom Disk System"
        case .gameAndWatch: return "Game & Watch"
        case .vectrex: return "Vectrex"
        case .odyssey: return "Odyssey 2"
        case .intellivision: return "Intellivision"
        case .megaduck: return "Mega Duck"
        case .dos: return "MS-DOS"
        case .msx: return "MSX"
        case .sgfx: return "SuperGrafx"
        case .pcecd: return "TurboGrafx CD"
        case .pce: return "TurboGrafx-16"
        case .nds: return "Nintendo DS"
        case .nes: return "NES / Famicom"
        case .gb: return "Game Boy"
        case .gba: return "Game Boy Advance"
        case .gbc: return "Game Boy Color"
        case .pokemini: return "Pokémon Mini"
        case .satellaview: return "Satellaview"
        case .sgb: return "Super Game Boy"
        case .snes: return "SNES / Super Famicom"
        case .virtualBoy: return "Virtual Boy"
        case .pico8: return "PICO-8"
        case .ports: return "Ports"
        case .scummvm: return "ScummVM"
        case .sega32x: return "Sega 32X"
        case .segaCD: return "Sega CD"
        case .gameGear: return "Game Gear"
        case .genesis: return "Genesis / Mega Drive"
        case .masterSystem: return "Master System"
        case .sg1000: return "SG-1000"
        case .zxSpectrum: return "ZX Spectrum"
        case .neogeo: return "Neo Geo"
        case .neoCD: return "Neo Geo CD"
        case .ngp: return "Neo Geo Pocket"
        case .playstation: return "PlayStation"
        case .tic80: return "TIC-80"
        case .vic20: return "VIC-20"
        case .videopac: return "Videopac"
        case .supervision: return "Watara Supervision"
        }
    }

    /// Folder aliases people commonly use in their collections.
    var aliases: [String] {
        switch self {
        case .snes: return ["snes", "sfc", "super nintendo", "super famicom", "super_nintendo"]
        case .nes: return ["nes", "fc", "famicom", "nintendo entertainment system"]
        case .gba: return ["gba", "game boy advance", "gameboy advance", "game_boy_advance"]
        case .gbc: return ["gbc", "game boy color", "gameboy color", "game_boy_color"]
        case .gb: return ["gb", "game boy", "gameboy", "dmg", "game_boy"]
        case .nds: return ["nds", "nintendo ds", "ds"]
        case .genesis: return ["md", "genesis", "mega drive", "megadrive", "smd", "mega_drive"]
        case .masterSystem: return ["ms", "sms", "master system", "mastersystem"]
        case .gameGear: return ["gg", "game gear", "gamegear"]
        case .playstation: return ["ps", "ps1", "psx", "psone", "playstation", "sony playstation", "sony psx"]
        case .pce: return ["pce", "tg16", "turbografx", "turbografx-16", "pc engine", "pcengine"]
        case .pcecd: return ["pcecd", "tgcd", "turbografx cd", "pc engine cd", "pce cd"]
        case .arcade: return ["arcade", "mame", "fba"]
        case .neogeo: return ["neogeo", "neo geo", "neo-geo"]
        case .neoCD: return ["neocd", "neo geo cd", "neogeo cd"]
        case .ngp: return ["ngp", "ngpc", "neo geo pocket"]
        case .wonderswan: return ["ws", "wsc", "wonderswan"]
        case .lynx: return ["lynx", "atari lynx"]
        case .atari2600: return ["atari", "a2600", "atari 2600", "2600"]
        case .atari5200: return ["a5200", "atari 5200", "5200", "fiftytwohundred"]
        case .atari7800: return ["a7800", "atari 7800", "7800", "seventyeighthundred"]
        case .c64: return ["c64", "commodore", "commodore 64"]
        case .fds: return ["fds", "famicom disk"]
        case .virtualBoy: return ["vb", "virtual boy", "virtualboy"]
        case .segaCD: return ["segacd", "sega cd", "mega cd", "megacd"]
        case .sega32x: return ["32x", "sega 32x", "thirtytwox"]
        case .amiga: return ["amiga", "adf", "uae"]
        case .cpc: return ["cpc", "amstrad", "amstrad cpc"]
        case .msx: return ["msx", "msx2"]
        case .dos: return ["dos", "msdos", "ms-dos", "pc"]
        case .scummvm: return ["scummvm", "scumm"]
        case .pico8: return ["pico", "pico-8", "pico8"]
        case .tic80: return ["tic", "tic80", "tic-80"]
        case .zxSpectrum: return ["zxs", "zx", "spectrum", "zx spectrum"]
        case .coleco: return ["coleco", "colecovision"]
        case .intellivision: return ["intellivision", "intv"]
        case .vic20: return ["vic20", "vic-20", "vic"]
        case .megaduck: return ["megaduck", "mega duck"]
        case .sufami: return ["sufami"]
        case .satellaview: return ["satellaview", "bsx"]
        case .sg1000: return ["sg1000", "sg-1000", "segasgone"]
        case .gameAndWatch: return ["gw", "game & watch", "game and watch"]
        case .pokemini: return ["poke", "pokemini", "pokemon mini"]
        case .supervision: return ["supervision", "watara"]
        case .videopac: return ["videopac", "odyssey2"]
        case .odyssey: return ["odyssey", "odyssey 2"]
        case .fairchild: return ["fairchild", "channelf", "channel f"]
        case .vectrex: return ["vectrex"]
        case .cps1: return ["cps1"]
        case .cps2: return ["cps2"]
        case .cps3: return ["cps3"]
        case .sgfx: return ["sgfx", "supergrafx"]
        case .sgb: return ["sgb", "super game boy"]
        case .ports: return ["ports"]
        }
    }
}

struct DetectedDestination: Equatable, Sendable {
    let folder: String
    let displayName: String

    init(folder: String, displayName: String? = nil) {
        self.folder = folder
        if let displayName {
            self.displayName = displayName
        } else if let system = ROMSystem(rawValue: folder) {
            self.displayName = system.displayName
        } else {
            self.displayName = folder
        }
    }

    init(system: ROMSystem) {
        self.folder = system.rawValue
        self.displayName = system.displayName
    }
}

enum ROMMapper {
    /// Built-in Onion-oriented defaults (`extension` → folder).
    static let defaultExtensionFolderMap: [String: String] = [
        // Nintendo
        "smc": "SFC", "sfc": "SFC", "fig": "SFC", "swc": "SFC", "bs": "SATELLAVIEW",
        "nes": "FC", "unf": "FC", "unif": "FC", "nez": "FC", "fds": "FDS",
        "gb": "GB", "sgb": "SGB", "gbc": "GBC", "cgb": "GBC",
        "gba": "GBA", "agb": "GBA", "mb": "GBA", "srl": "GBA",
        "nds": "NDS", "dsi": "NDS", "ids": "NDS",
        "vb": "VB", "vboy": "VB",
        "min": "POKE",

        // Sega
        "md": "MD", "gen": "MD", "smd": "MD", "sgd": "MD",
        "gg": "GG",
        "sms": "MS",
        "32x": "THIRTYTWOX",
        "sg": "SEGASGONE",

        // NEC
        "pce": "PCE", "sgx": "SGFX",

        // Atari
        "a26": "ATARI",
        "a52": "FIFTYTWOHUNDRED",
        "a78": "SEVENTYEIGHTHUNDRED",
        "lnx": "LYNX", "lyx": "LYNX",

        // SNK / Bandai / others
        "ws": "WS", "wsc": "WS",
        "ngp": "NGP", "ngc": "NGP", "npc": "NGP",
        "neo": "NEOGEO",

        // Home computers / niche
        "adf": "AMIGA", "adz": "AMIGA", "dms": "AMIGA", "fdi": "AMIGA", "ipf": "AMIGA", "hdf": "AMIGA", "hfe": "AMIGA",
        "dsk": "CPC", "cdt": "CPC", "cpr": "CPC",
        "d64": "COMMODORE", "g64": "COMMODORE", "t64": "COMMODORE", "tap": "COMMODORE", "prg": "COMMODORE", "crt": "COMMODORE",
        "cas": "MSX", "mx1": "MSX", "mx2": "MSX",
        "z80": "ZXS", "sna": "ZXS", "szx": "ZXS", "tzx": "ZXS", "scl": "ZXS", "trd": "ZXS",
        "col": "COLECO",
        "int": "INTELLIVISION",
        "vec": "VECTREX", "gam": "VECTREX",
        "sv": "SUPERVISION",
        "chf": "FAIRCHILD",

        // PlayStation singles (cue/bin/iso handled as ambiguous)
        "pbp": "PS", "ecm": "PS", "mds": "PS",

        // Fantasy consoles
        "p8": "PICO",
        "tic": "TIC",

        // ScummVM / DOS project files
        "scummvm": "SCUMMVM", "svm": "SCUMMVM",
        "dosz": "DOS",
    ]

    /// Multi-track / disc / archive formats that need path or sidecar hints.
    private static let ambiguousExtensions: Set<String> = [
        "bin", "cue", "iso", "img", "mdf", "ccd", "sub", "toc", "m3u",
        "chd", "zip", "7z", "rar", "rom", "wav", "ape", "flac"
    ]

    static func detectSystem(for url: URL) -> ROMSystem? {
        detectDestination(for: url, extensionMap: defaultExtensionFolderMap).flatMap {
            ROMSystem(rawValue: $0.folder)
        }
    }

    static func detectDestination(
        for url: URL,
        extensionMap: [String: String] = defaultExtensionFolderMap
    ) -> DetectedDestination? {
        let ext = url.pathExtension.lowercased()
        let stem = url.deletingPathExtension().lastPathComponent
        let stemLower = stem.lowercased()

        func destination(forFolder folder: String) -> DetectedDestination {
            DetectedDestination(folder: folder)
        }

        func destination(for system: ROMSystem) -> DetectedDestination {
            DetectedDestination(system: system)
        }

        // PICO-8 carts are often named game.p8.png
        if ext == "png", stemLower.hasSuffix(".p8") {
            return extensionMap["p8"].map(destination(forFolder:)) ?? destination(for: .pico8)
        }

        // Path hints win for ambiguous formats (e.g. PS/Game.bin, Sega CD/Game.cue)
        if ambiguousExtensions.contains(ext), let fromPath = detectFromPathHints(url) {
            return destination(for: fromPath)
        }

        if !ambiguousExtensions.contains(ext), let folder = extensionMap[ext] {
            return destination(forFolder: folder)
        }

        // Disc image heuristics (PlayStation cue/bin are the common Miyoo case)
        if let discSystem = detectDiscImageSystem(for: url, extension: ext) {
            if let folder = extensionMap[ext] {
                return destination(forFolder: folder)
            }
            return destination(for: discSystem)
        }

        if let folder = extensionMap[ext] {
            return destination(forFolder: folder)
        }

        return detectFromPathHints(url).map(destination(for:))
    }

    /// Companion files that belong with a `.cue` (or similar) disc set.
    static func companionURLs(for url: URL) -> [URL] {
        let ext = url.pathExtension.lowercased()
        let directory = url.deletingLastPathComponent()
        let stem = url.deletingPathExtension().lastPathComponent
        var companions: [URL] = []

        if ext == "cue" {
            companions.append(contentsOf: referencedFiles(inCue: url))
            let sidecarExtensions = ["bin", "img", "iso", "wav", "ape", "flac", "ccd", "sub", "toc", "mdf"]
            for sidecarExt in sidecarExtensions {
                let candidate = directory.appendingPathComponent("\(stem).\(sidecarExt)")
                if FileManager.default.fileExists(atPath: candidate.path) {
                    companions.append(candidate)
                }
            }
        } else if ["bin", "img", "iso", "mdf"].contains(ext) {
            let cue = directory.appendingPathComponent("\(stem).cue")
            if FileManager.default.fileExists(atPath: cue.path) {
                companions.append(cue)
                companions.append(contentsOf: companionURLs(for: cue).filter { $0.standardizedFileURL != url.standardizedFileURL })
            }
        } else if ext == "ccd" {
            for sidecarExt in ["img", "sub", "cue"] {
                let candidate = directory.appendingPathComponent("\(stem).\(sidecarExt)")
                if FileManager.default.fileExists(atPath: candidate.path) {
                    companions.append(candidate)
                }
            }
        } else if ext == "m3u" {
            if let text = try? String(contentsOf: url, encoding: .utf8) {
                for line in text.components(separatedBy: .newlines) {
                    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
                    let candidate = directory.appendingPathComponent(trimmed)
                    if FileManager.default.fileExists(atPath: candidate.path) {
                        companions.append(candidate)
                        if candidate.pathExtension.lowercased() == "cue" {
                            companions.append(contentsOf: companionURLs(for: candidate))
                        }
                    }
                }
            }
        }

        // Unique by path
        var seen = Set<String>()
        return companions.filter { companion in
            let path = companion.standardizedFileURL.path
            guard !seen.contains(path), path != url.standardizedFileURL.path else { return false }
            seen.insert(path)
            return true
        }
    }

    private static func detectDiscImageSystem(for url: URL, extension ext: String) -> ROMSystem? {
        switch ext {
        case "cue", "bin", "iso", "img", "mdf", "ccd", "sub", "toc", "m3u", "chd":
            let directory = url.deletingLastPathComponent()
            let stem = url.deletingPathExtension().lastPathComponent
            let cueURL = ext == "cue" ? url : directory.appendingPathComponent("\(stem).cue")

            if FileManager.default.fileExists(atPath: cueURL.path) || ext == "cue" || ext == "pbp" {
                // Default multi-track dumps without folder hints to PlayStation (Miyoo norm)
                return .playstation
            }

            // Lone .chd / .iso with no cues — still usually PS on Miyoo collections
            if ["chd", "iso", "img", "pbp"].contains(ext) {
                return .playstation
            }

            // Lone .bin is too ambiguous (Genesis soft-dips, etc.)
            return nil
        default:
            return nil
        }
    }

    private static func referencedFiles(inCue cueURL: URL) -> [URL] {
        let text = (try? String(contentsOf: cueURL, encoding: .utf8))
            ?? (try? String(contentsOf: cueURL, encoding: .isoLatin1))
        guard let text else { return [] }

        let directory = cueURL.deletingLastPathComponent()
        var files: [URL] = []
        // FILE "track.bin" BINARY  or  FILE track.bin BINARY
        let pattern = #"FILE\s+(?:"([^"]+)"|(\S+))"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match else { return }
            for index in 1...2 {
                if let r = Range(match.range(at: index), in: text) {
                    let name = String(text[r])
                    let candidate = directory.appendingPathComponent(name)
                    if FileManager.default.fileExists(atPath: candidate.path) {
                        files.append(candidate)
                    }
                    break
                }
            }
        }
        return files
    }

    static func detectFromPathHints(_ url: URL) -> ROMSystem? {
        let components = url.pathComponents.map { $0.lowercased() }
        let filename = url.lastPathComponent.lowercased()

        // Prefer longer aliases first so "game boy color" beats "game boy"
        let systems = ROMSystem.allCases.flatMap { system in
            system.aliases.map { alias in (system, alias) }
        }
        .sorted { $0.1.count > $1.1.count }

        for (system, alias) in systems {
            if components.contains(alias) { return system }

            if alias.count <= 3 {
                let pattern = "(^|[^a-z0-9])\(NSRegularExpression.escapedPattern(for: alias))([^a-z0-9]|$)"
                if filename.range(of: pattern, options: .regularExpression) != nil {
                    return system
                }
            } else if filename.contains(alias) || components.contains(where: { $0.contains(alias) }) {
                return system
            }
        }
        return nil
    }
}
