# GameDropMM

Tiny macOS utility: drag ROMs onto a square drop zone and they land in the right OnionOS folders on your Miyoo Mini microSD card.

## What it does

1. Watches `/Volumes` for a Miyoo Mini / OnionOS SD card (`Roms` plus markers like `Emu`, `Bios`, `RetroArch`, …).
2. Lets you drop ROM files (or folders of ROMs) onto the app.
3. Detects the console from the file extension (and folder-name hints).
4. Copies into `Roms/<OnionFolder>/` on the card — e.g. `.smc` → `Roms/SFC/`.

If a file can’t be identified (common with `.zip`), you’ll get a console picker.

## Requirements

- macOS 14+
- Xcode 16+ (to build)
- SD card set up with [OnionOS](https://onionui.github.io/) (or stock-style `Roms` + `Emu` layout)

## Build & run

```bash
open GameDropMM.xcodeproj
```

Or from the terminal:

```bash
xcodebuild -scheme GameDropMM -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/GameDropMM-*/Build/Products/Debug/GameDropMM.app
```

Sandboxing is off so the app can see removable volumes under `/Volumes`.

## Common mappings

| Console        | Extensions (examples) | Onion folder |
|----------------|------------------------|--------------|
| SNES           | `.smc` `.sfc`          | `SFC`        |
| NES            | `.nes`                 | `FC`         |
| Game Boy       | `.gb`                  | `GB`         |
| Game Boy Color | `.gbc`                 | `GBC`        |
| GBA            | `.gba`                 | `GBA`        |
| NDS            | `.nds`                 | `NDS`        |
| Genesis        | `.md` `.gen`           | `MD`         |
| PlayStation    | `.pbp` `.chd`          | `PS`         |

Full Onion folder list: [onionui.github.io/docs/emulators/folders](https://onionui.github.io/docs/emulators/folders)

After copying, on the Miyoo: **Games → SELECT → Refresh all roms**.

## License

MIT — see [LICENSE](LICENSE).
