#!/bin/bash
# Packages dist/MacMasters.app (run ./build.sh first) into a
# compressed disk image for a release, plus its SHA-256 checksum.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/dist/MacMasters.app"
[ -d "$APP" ] || { echo "Primero ejecuta ./build.sh" >&2; exit 1; }

VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist")"
NAME="MacMasters-$VERSION"
DMG="$ROOT/dist/$NAME.dmg"
STAGE="$ROOT/build/dmg"

codesign --verify --deep --strict "$APP"

rm -rf "$STAGE" "$DMG" "$DMG.sha256"
mkdir -p "$STAGE"
cp -a "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
cp "$ROOT/README.md" "$STAGE/README.md"
cp "$ROOT/README.es.md" "$STAGE/LEEME.md"
cp "$ROOT/README.pt-BR.md" "$STAGE/LEIA-ME.md"

# ULFO (LZFSE) compresses better than UDZO; it needs macOS 10.11+, below the
# app's own minimum of macOS 11.
hdiutil create -volname "MacMasters $VERSION" -srcfolder "$STAGE" -fs HFS+ -format ULFO -ov "$DMG" >/dev/null
rm -rf "$STAGE"

(cd "$ROOT/dist" && shasum -a 256 "$NAME.dmg" > "$NAME.dmg.sha256")
echo "Listo: $DMG ($(du -h "$DMG" | cut -f1))"
cat "$DMG.sha256"
