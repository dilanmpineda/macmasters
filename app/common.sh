#!/bin/bash
# Shared paths and helpers for the launcher and the first-run setup.

APP_NAME="MacMasters"
RES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WINE_DIR="$RES_DIR/wine"
WINE="$WINE_DIR/bin/wine"
WINESERVER="$WINE_DIR/bin/wineserver"
CABEXTRACT="$RES_DIR/bin/cabextract"

SUPPORT_DIR="$HOME/Library/Application Support/$APP_NAME"
CACHE_DIR="$HOME/Library/Caches/$APP_NAME"
LOG_DIR="$HOME/Library/Logs/$APP_NAME"

export WINEPREFIX="$SUPPORT_DIR/prefix"
# Wine loads FreeType, GnuTLS and MoltenVK by name from the bundled lib folder.
export DYLD_FALLBACK_LIBRARY_PATH="$WINE_DIR/lib"
export WINEDEBUG="${WINEDEBUG:--all}"
# No .NET in this prefix: DMO does not need it, and this stops the Mono prompt.
export WINEDLLOVERRIDES="mscoree="

SYSWOW64="$WINEPREFIX/drive_c/windows/syswow64"
SETUP_STAMP="$SUPPORT_DIR/setup-complete"

mkdir -p "$SUPPORT_DIR" "$CACHE_DIR" "$LOG_DIR"
LOG_FILE="$LOG_DIR/launcher.log"

log() {
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

# osascript strings are passed as arguments so quotes in messages are safe.
alert() {
    osascript - "$APP_NAME" "$1" <<'EOF' >/dev/null 2>&1
on run argv
    display alert (item 1 of argv) message (item 2 of argv) as warning buttons {"OK"} default button "OK"
end run
EOF
}

notify() {
    osascript - "$APP_NAME" "$1" <<'EOF' >/dev/null 2>&1
on run argv
    display notification (item 2 of argv) with title (item 1 of argv)
end run
EOF
}

# ask "message" "button1" "button2" ["button3"] -> prints the chosen button,
# or nothing if the dialog was cancelled.
ask() {
    local msg="$1"; shift
    osascript - "$APP_NAME" "$msg" "$@" <<'EOF' 2>/dev/null
on run argv
    set btns to items 3 thru -1 of argv
    try
        set r to display dialog (item 2 of argv) with title (item 1 of argv) buttons btns default button (item -1 of btns)
        return button returned of r
    on error
        return ""
    end try
end run
EOF
}

choose_file() {
    osascript - "$1" <<'EOF' 2>/dev/null
on run argv
    try
        return POSIX path of (choose file with prompt (item 1 of argv))
    on error
        return ""
    end try
end run
EOF
}

fail() {
    log "ERROR: $*"
    alert "$*"$'\n\n'"Más detalles en: $LOG_FILE"
    exit 1
}

# download URL SHA256 DEST: downloads once into the cache and verifies the hash.
download() {
    local url="$1" sha="$2" dest="$3"
    if [ -f "$dest" ] && [ "$(shasum -a 256 "$dest" | cut -d' ' -f1)" = "$sha" ]; then
        log "cache ok: $dest"
        return 0
    fi
    log "downloading $url"
    curl -fL --retry 3 -o "$dest.part" "$url" >> "$LOG_FILE" 2>&1 || return 1
    if [ "$(shasum -a 256 "$dest.part" | cut -d' ' -f1)" != "$sha" ]; then
        log "hash mismatch for $url"
        rm -f "$dest.part"
        return 1
    fi
    mv "$dest.part" "$dest"
}

find_game_dir() {
    local exe
    exe="$(find "$WINEPREFIX/drive_c" -maxdepth 4 -type f -name DMLauncher.exe 2>/dev/null | head -1)"
    [ -n "$exe" ] && dirname "$exe"
}
