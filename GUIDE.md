# How to use diskreceipt

*Also on the web, with the per-tool cleanup guides it links to: [shedi.app/guides/diskreceipt](https://shedi.app/guides/diskreceipt?ref=diskreceipt).*

This guide covers installing diskreceipt, reading your first receipt and getting space back without breaking a project. It assumes nothing beyond a Mac and Terminal.

**Contents**

1. [Install](#1-install)
2. [Print your first receipt](#2-print-your-first-receipt)
3. [Read the receipt](#3-read-the-receipt)
4. [Get space back, safely](#4-get-space-back-safely)
5. [Scan less, scan faster](#5-scan-less-scan-faster)
6. [Keep a history](#6-keep-a-history)
7. [Use it in scripts](#7-use-it-in-scripts)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Install

With Homebrew:

```sh
brew install abdiraimov-otabek/tap/diskreceipt
```

Without Homebrew, download the script and make it executable:

```sh
curl -fsSL https://raw.githubusercontent.com/abdiraimov-otabek/diskreceipt/main/diskreceipt -o /usr/local/bin/diskreceipt
chmod +x /usr/local/bin/diskreceipt
```

Check that it works:

```sh
diskreceipt --version
```

To update, run `brew upgrade diskreceipt`, or run the `curl` line again. To remove it, run `brew uninstall diskreceipt` or delete `/usr/local/bin/diskreceipt`. diskreceipt writes no settings or files of its own, so there's nothing else to clean up.

## 2. Print your first receipt

```sh
diskreceipt
```

Here's what happens:

1. **The scan.** A spinner shows what's being weighed and a running total, for example `⠹ Weighing node_modules #30  11.5 GB found so far`. First it checks about 30 known cache folders, which takes a second or two. Then it searches your home folder for project folders (`node_modules`, `target/`, `.venv` and so on), which takes most of the time, about 20 seconds on a typical developer Mac.
2. **The receipt.** It prints line by line, biggest item first.

You can press `Ctrl-C` at any time. Nothing has been changed, because diskreceipt never changes anything.

## 3. Read the receipt

Here is a shortened real receipt, part by part.

```
--------------------------------------------------------
node_modules ×47          ██████████████          7.7 GB
  check · Your install command brings it back
uv cache                  ██████░░░░░░░░          3.4 GB
  safe  · uv cache prune
```

Each item takes two lines:

- **First line:** the name, a bar showing its size next to your biggest item, and the size. `×47` means it found 47 of these folders and added them up.
- **Second line:** the label and how to clean it.

The label is the most important part:

| Label | What it means | What to do |
|---|---|---|
| **safe** (green) | A cache. The tool that made it rebuilds it on the next build or install. | Clean it whenever you need the space. The only cost is a slower first build or install afterwards. |
| **check** (yellow) | Comes back, but only when you reinstall. | Clean it for projects you no longer work on. For active projects, deleting it just means running your install command again. |
| **keep** (red) | Your own files. They don't come back. | Only delete them if you know you don't need them. For example, Xcode Archives are the builds you shipped. |

```
========================================================
TOTAL                                            26.8 GB
  of which safe to clean                         10.3 GB
PAID WITH                                YOUR FREE SPACE
FREE SPACE LEFT                                  65.4 GB
```

`TOTAL` adds up every line. `of which safe to clean` adds up the green lines only, which is what you can clean without a second thought. `FREE SPACE LEFT` is the free space on your startup disk right now.

```
QUICK WINS (safe, paste into Terminal)
  $ uv cache prune                    # 3.4 GB
  $ npm cache npx rm                  # 2.4 GB
  $ npx @puppeteer/browsers clear     # 1.1 GB
  up to 6.8 GB back, and all of it rebuilds on its own
```

Quick wins are the three biggest **safe** items that have an official one-line command. It says "up to" because some commands, like `uv cache prune`, only remove the parts that aren't being used.

The cashier's note at the end is a joke. Ignore it or screenshot it.

## 4. Get space back, safely

Work from the top of this list down, and run `diskreceipt` again afterwards to see the new total.

### Start with the quick wins

Copy the `QUICK WINS` commands into Terminal one at a time. They are the official cleanup commands of each tool, so the tool itself decides what to remove.

### Xcode

- **DerivedData** (safe): quit Xcode, then move `~/Library/Developer/Xcode/DerivedData` to the Trash. Each project rebuilds its own folder the next time you build it.
- **DeviceSupport** (safe): inside `~/Library/Developer/Xcode/iOS DeviceSupport`, move folders for iOS versions you no longer debug on to the Trash. A folder comes back if you connect a device running that version.
- **Simulator devices** (check): run `xcrun simctl delete unavailable` to remove simulators for runtimes you no longer have installed.
- **Archives** (keep): open Xcode, then Window > Organizer > Archives, and delete only the builds you're sure about.

### JavaScript

- **npm, pnpm, Yarn, Bun caches** (safe): `npm cache clean --force`, `pnpm store prune`, `yarn cache clean`, `bun pm cache rm`.
- **node_modules** (check): find the projects you haven't touched in a while and remove their `node_modules` folder. If you ever need the project again, run `npm install` (or `pnpm install`, `yarn`, `bun install`) and it comes back.

### Python

- **uv** (safe): `uv cache prune` removes unused entries. `uv cache clean` removes everything.
- **pip, Poetry** (safe): `pip cache purge`, `poetry cache clear --all PyPI`.
- **.venv** (check): delete the `.venv` folder of old projects. Recreate it later with your usual command, for example `uv sync` or `python -m venv .venv && pip install -r requirements.txt`.

### Docker

The Docker line (check) is the size of Docker Desktop's whole disk image. Run this first to see what's inside:

```sh
docker system df
```

Then remove what you don't need. `docker image prune -a` removes every image no container is using, and `docker builder prune` clears the build cache. Volumes hold data, so look at `docker volume ls` before you remove any. Docker Desktop may not shrink its disk image file right away after a prune.

### Rust, Go, Swift and Java

- **Rust** (safe): run `cargo clean` inside a project to remove its `target/`. You can move `~/.cargo/registry` to the Trash, and Cargo downloads again what it needs.
- **Go** (safe): `go clean -cache` and `go clean -modcache`.
- **SwiftPM** (safe): run `swift package clean` inside a package, and `swift package purge-cache` for the global cache.
- **Gradle, Maven** (safe): stop daemons with `./gradlew --stop`, then move `~/.gradle/caches` or `~/.m2/repository` to the Trash.

## 5. Scan less, scan faster

| You want | Run |
|---|---|
| Global caches only, about 1 second | `diskreceipt --no-projects` |
| Only the projects in one folder | `diskreceipt --root ~/code` |
| A shallower search | `diskreceipt --depth 3` |
| The receipt at once, no animation | `diskreceipt --no-anim` |
| No colors | `diskreceipt --no-color`, or `NO_COLOR=1 diskreceipt` |

`--depth` counts folder levels below `--root`. With `--root ~/code --depth 3`, a project at `~/code/client/app/node_modules` is found, but one nested deeper is not. The project search always skips `~/Library`, the Trash, `.git`, `.cache`, `.npm` and `.cargo`. The caches inside those folders are already covered by the known-cache list.

## 6. Keep a history

Redirect the receipt to a file to keep it. Redirected output is plain text with no colors or animation:

```sh
mkdir -p ~/receipts
diskreceipt > ~/receipts/$(date +%F).txt
```

Compare two months later:

```sh
diff ~/receipts/2026-10-18.txt ~/receipts/2026-11-18.txt
```

A shorter command if you check often:

```sh
echo "alias receipt='diskreceipt --no-projects'" >> ~/.zshrc
```

## 7. Use it in scripts

- **Plain output when piped.** When the output isn't a terminal, diskreceipt skips colors, the spinner and the printing delay, so `diskreceipt | grep TOTAL` returns quickly.
- **Animation only on screen.** The spinner writes to stderr and only on a terminal, so it never ends up in files.
- **Exit codes.** It exits with `0` on success, `2` for an unknown option and `130` if you press `Ctrl-C`.

To print just the total:

```sh
diskreceipt --no-projects | grep '^TOTAL'
```

## 8. Troubleshooting

**The scan seems slow.**
Almost all the time goes into searching for project folders. Narrow it with `--root ~/code` or `--depth 3`, or skip it with `--no-projects`.

**A folder I know about isn't on the receipt.**
Check these in order:

1. Items under 1 MB are left off.
2. A project folder only counts when its marker file is next to it: `package.json` for `node_modules`, `Cargo.toml` for `target/`, `Package.swift` for `.build`, `Podfile` for `Pods/`.
3. It may sit deeper than `--depth` (6 by default).
4. It may be outside `--root` (your home folder by default).

**The numbers don't match Finder.**
diskreceipt uses `du`, which counts the disk blocks actually in use. Finder sometimes shows the logical file size instead. They differ most for Docker's disk image, which is a sparse file, and for APFS clones, which share blocks. `du` reflects what deleting the item would actually free.

**macOS asks whether Terminal can access data from other apps.**
That can happen when diskreceipt measures Docker Desktop's disk image, which lives inside Docker's app container. Allowing it lets the Docker line show up. Denying it hides the Docker line, and everything else still works.

**I want it to clean things for me.**
diskreceipt only reads, on purpose. To clean with a click instead of pasting commands, use [Shedi](https://shedi.app/?ref=diskreceipt-guide), the Mac app from the same author. It explains every item, pre-selects only the safe ones and moves everything to the Trash first.
