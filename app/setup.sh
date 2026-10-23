#!/bin/bash
# First-run setup: creates the Wine prefix, downloads the DirectX shader
# compiler straight from Microsoft (it cannot be redistributed), applies the
# DMO settings and installs or imports the game.
set -u
source "$(dirname "$0")/common.sh"

# DirectX June 2010 redistributable: d3dcompiler_43.dll (same as `winetricks d3dcompiler_43`).
DX_URL="https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"
DX_SHA="053f76dcbb28802e23341b6a787e3b0791c0fa5c8d4d011b1044172dbf89c73b"

CROSSOVER_DRIVE_C="$HOME/Library/Application Support/CrossOver/Bottles/DMO/drive_c"
GAME_SITE="https://dmo.gameking.com/Main/Main.aspx"

# The install folder depends on the server's installer (for example
# C:\MoveInteractive\LDMO), so look for the game's launcher instead.
crossover_game_dir() {
    local exe
    exe="$(find "$CROSSOVER_DRIVE_C" -maxdepth 4 -type f -name DMLauncher.exe 2>/dev/null | head -1)"
    [ -n "$exe" ] && dirname "$exe"
}

create_prefix() {
    log "creating prefix $WINEPREFIX"
    "$WINE" wineboot --init >> "$LOG_FILE" 2>&1 || fail "No se pudo crear el entorno de Wine."
    "$WINESERVER" -w
}

install_d3dcompiler() {
    local exe="$CACHE_DIR/directx_Jun2010_redist.exe" tmp="$CACHE_DIR/dx" cab
    notify "Descargando DirectX (junio 2010) desde Microsoft (100 MB)…"
    download "$DX_URL" "$DX_SHA" "$exe" || fail "No se pudo descargar DirectX desde Microsoft."
    rm -rf "$tmp"; mkdir -p "$tmp"
    "$CABEXTRACT" -q -d "$tmp" -L -F '*d3dcompiler_43*x86*' "$exe" >> "$LOG_FILE" 2>&1
    for cab in "$tmp"/*.cab; do
        "$CABEXTRACT" -q -d "$tmp/out" -L -F d3dcompiler_43.dll "$cab" >> "$LOG_FILE" 2>&1
    done
    cp "$tmp/out/d3dcompiler_43.dll" "$SYSWOW64/d3dcompiler_43.dll" ||
        fail "No se pudo extraer d3dcompiler_43.dll."
    rm -rf "$tmp"
    log "installed d3dcompiler_43"
}

apply_registry() {
    "$WINE" regedit /S "Z:$RES_DIR/dmo.reg" >> "$LOG_FILE" 2>&1 || fail "No se pudo aplicar la configuración del registro."
    "$WINESERVER" -w
    log "registry applied"
}

install_game() {
    local choice="" installer crossover_game dest
    if [ -n "$(find_game_dir)" ]; then
        log "game already present at $(find_game_dir)"
        return 0
    fi

    crossover_game="$(crossover_game_dir)"
    if [ -n "$crossover_game" ]; then
        choice="$(ask "Se encontró DMO instalado en CrossOver. ¿Quieres usar esa instalación? Se copia sin ocupar espacio extra en el disco." "Instalar de nuevo" "Usar la de CrossOver")"
        log "CrossOver install found at $crossover_game; user chose: ${choice:-<cancelled>}"
    fi

    if [ "$choice" = "Usar la de CrossOver" ]; then
        # Same path inside the new prefix, e.g. drive_c/MoveInteractive/LDMO.
        dest="$WINEPREFIX/drive_c/${crossover_game#"$CROSSOVER_DRIVE_C"/}"
        mkdir -p "$(dirname "$dest")"
        # APFS clone: instant, and shares blocks until either copy changes.
        cp -cRp "$crossover_game" "$dest" >> "$LOG_FILE" 2>&1 ||
            fail "No se pudo copiar la instalación de CrossOver."
        log "imported game from CrossOver bottle to $dest"
        return 0
    fi

    choice="$(ask "Descarga el instalador oficial de DMO desde dmo.gameking.com y luego selecciónalo aquí." "Cancelar" "Abrir la página" "Ya lo descargué")"
    [ "$choice" = "Abrir la página" ] && open "$GAME_SITE" &&
        choice="$(ask "Cuando termine la descarga, selecciona el instalador." "Cancelar" "Seleccionar")"
    [ -z "$choice" ] || [ "$choice" = "Cancelar" ] && fail "Instalación cancelada."

    installer="$(choose_file "Selecciona el instalador de DMO (.exe)")"
    [ -n "$installer" ] || fail "No se seleccionó ningún instalador."
    log "running installer $installer"
    # wine returns when the installer exits. Its last page may start
    # DMLauncher.exe, which keeps running, so do not wait for every process.
    "$WINE" "$installer" >> "$LOG_FILE" 2>&1
    [ -n "$(find_game_dir)" ] || fail "El instalador terminó, pero no se encontró DMLauncher.exe."
}

log "=== setup start"
[ -d "$WINEPREFIX/drive_c" ] || create_prefix
install_d3dcompiler
apply_registry
install_game
touch "$SETUP_STAMP"
log "=== setup complete"
