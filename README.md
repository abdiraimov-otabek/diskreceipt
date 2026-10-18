# diskreceipt

**The receipt for the developer caches on your Mac.** One command shows where your disk space went: Xcode DerivedData, `node_modules`, Python `.venv` folders, Docker, Rust `target/`, and the npm, uv, pip, Gradle, Go and Homebrew caches. Each line says whether it's safe to delete and gives the official command to clean it.

It only reads. Nothing is ever deleted.

```
                D I S K   R E C E I P T
        developer caches on Otabek's MacBook Pro
                  Oct 18, 2026  14:55
--------------------------------------------------------
node_modules ×47                                  7.7 GB
  check · Your install command brings it back
Python .venv ×17                                  7.5 GB
  check · Your install command brings it back
uv cache                                          3.4 GB
  safe · uv cache prune
SwiftPM .build ×3                                 2.5 GB
  safe · swift package clean, in the package
npx packages                                      2.4 GB
  safe · npm cache npx rm
...
========================================================
TOTAL                                            26.8 GB
  of which safe to clean                         10.3 GB
PAID WITH                                YOUR FREE SPACE
FREE SPACE LEFT                                  65.4 GB
```

That's a real run on my Mac, not a mockup.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/abdiraimov-otabek/diskreceipt/main/diskreceipt -o /usr/local/bin/diskreceipt
chmod +x /usr/local/bin/diskreceipt
```

Or clone the repo and run `./diskreceipt`. It's one Bash script with no dependencies, and it runs on the Bash that ships with macOS.

## Usage

```sh
diskreceipt                    # caches + project folders under ~
diskreceipt --root ~/code      # look for projects only in ~/code
diskreceipt --no-projects      # global caches only, fast
diskreceipt --no-color > receipt.txt
```

Scanning your whole home folder takes about 20 seconds. Items under 1 MB are left off.

## What the labels mean

| Label | Meaning |
|---|---|
| **safe** | A cache. It comes back on its own the next time you build or install. |
| **check** | Comes back, but look first: a `node_modules` or `.venv` from a project you still use costs a reinstall. |
| **keep** | Your files. Xcode Archives and Android emulators don't come back. Delete them by hand if you're sure. |

## What it checks

| Cache | Where | Clean with |
|---|---|---|
| Xcode DerivedData | `~/Library/Developer/Xcode/DerivedData` | Quit Xcode, move to Trash |
| Xcode DeviceSupport | `~/Library/Developer/Xcode/*DeviceSupport` | Move old OS versions to Trash |
| Xcode Archives | `~/Library/Developer/Xcode/Archives` | Organizer > Archives (keep) |
| SwiftUI Previews | `~/Library/Developer/Xcode/UserData/Previews` | Quit Xcode, move to Trash |
| Simulator devices | `~/Library/Developer/CoreSimulator/Devices` | `xcrun simctl delete unavailable` |
| SwiftPM, CocoaPods, Carthage | `~/Library/Caches/...` | `swift package purge-cache`, `pod cache clean --all` |
| Homebrew downloads | `~/Library/Caches/Homebrew` | `brew cleanup` |
| npm, npx, pnpm, Yarn, Bun | `~/.npm`, `~/Library/pnpm/store`, `~/.bun/install/cache` | `npm cache clean --force`, `pnpm store prune`, `yarn cache clean` |
| pip, Poetry, uv | `~/Library/Caches/pip`, `~/.cache/uv` | `pip cache purge`, `uv cache prune` |
| Cargo, Go | `~/.cargo/registry`, `~/Library/Caches/go-build`, `~/go/pkg/mod` | `go clean -cache`, `go clean -modcache` |
| Gradle, Maven | `~/.gradle/caches`, `~/.m2/repository` | Stop daemons, move to Trash |
| Android | `~/Library/Android/sdk/system-images`, `~/.android/avd` | `sdkmanager --uninstall`, `avdmanager delete avd` |
| JetBrains, VS Code | `~/Library/Caches/JetBrains`, `~/Library/Application Support/Code` | Invalidate Caches, or quit and move to Trash |
| Playwright, Puppeteer, Electron | `~/Library/Caches/ms-playwright`, `~/.cache/puppeteer` | `npx playwright uninstall --all` |
| Docker Desktop | `~/Library/Containers/com.docker.docker/.../Docker.raw` | `docker system df`, then `docker image prune -a` |
| `node_modules` | next to a `package.json` | your install command |
| Rust `target/` | next to a `Cargo.toml` | `cargo clean` |
| SwiftPM `.build` | next to a `Package.swift` | `swift package clean` |
| CocoaPods `Pods/` | next to a `Podfile` | `pod install` |
| Python `.venv` | in any project | your install command |

Project folders only count when the file next to them proves what they are, so a random folder called `target` is ignored. Nested `node_modules` are counted once.

## Why "System Data" is so big on a developer Mac

macOS files most of these caches under **System Data** in Settings > General > Storage, so a developer Mac can show 50 to 100 GB there with no explanation. diskreceipt shows where that space actually is. The paths and commands follow the guide at [shedi.app](https://shedi.app/?ref=diskreceipt), which has the full table with typical sizes.

## Want it cleaned, not just counted?

[Shedi](https://shedi.app/?ref=diskreceipt) is the Mac app from the same author. It finds the same caches, explains every item, pre-selects only the safe ones and moves them to the Trash first.

## Test

```sh
./test.sh
```

Builds a fake home folder with known caches and checks the receipt, including that nothing was deleted.

## License

MIT
