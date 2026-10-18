#!/bin/bash
# Self-check: fake HOME with known caches and projects, then assert on the receipt.
set -u
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mk() { mkdir -p "$1" && dd if=/dev/zero of="$1/blob" bs=1024 count="$2" 2>/dev/null; }
mk "$T/Library/Developer/Xcode/DerivedData/App-abc" 3072
mk "$T/Library/Developer/Xcode/Archives/2026" 2048
mk "$T/.cache/uv" 2048
mk "$T/code/web/node_modules/react" 2048;  touch "$T/code/web/package.json"
mk "$T/code/web/node_modules/a/node_modules/b" 1024   # nested, must not double count
mk "$T/code/rs/target/debug" 4096;          touch "$T/code/rs/Cargo.toml"
mk "$T/code/notrust/target" 4096                        # no Cargo.toml, must be ignored
mk "$T/.npm/_cacache" 10                                # under 1 MB, hidden

out=$(HOME="$T" ./diskreceipt --no-color --root "$T")
fail=0
check() { echo "$out" | grep -q -- "$1" || { echo "FAIL: missing '$1'"; fail=1; }; }
refute() { echo "$out" | grep -q -- "$1" && { echo "FAIL: unexpected '$1'"; fail=1; }; }
check "Xcode DerivedData .* 3 MB"
check "Xcode Archives"
check "keep *· Xcode > Window"
check "uv cache .* 2 MB"
check "node_modules ×1 .* 3 MB"
check "Rust target/ ×1 .* 4 MB"
check "TOTAL .* 14 MB"
check "of which safe to clean .* 9 MB"
check "Nothing was deleted"
check "QUICK WINS"
check "\$ uv cache prune"
check "Cashier.s note"
refute "npm cache"
refute "×2"
[ -e "$T/code/web/node_modules/react/blob" ] || { echo "FAIL: something was deleted"; fail=1; }
[ $fail = 0 ] && echo "ok" || { echo "$out"; exit 1; }
