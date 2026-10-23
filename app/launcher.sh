#!/bin/bash
# MacMasters entry point. It only ever runs the game's own launcher
# (DMLauncher.exe) inside a private Wine prefix; it never opens other programs.
set -u
RES="$(cd "$(dirname "$0")/../Resources" && pwd)"
source "$RES/common.sh"

ensure_rosetta() {
    /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null && return 0
    [ "$(ask "Wine necesita Rosetta 2 para funcionar en Macs con Apple Silicon. ¿Instalarlo ahora?" "Salir" "Instalar")" = "Instalar" ] ||
        exit 0
    osascript -e 'do shell script "/usr/sbin/softwareupdate --install-rosetta --agree-to-license" with administrator privileges' >> "$LOG_FILE" 2>&1 ||
        fail "No se pudo instalar Rosetta 2."
}

log "=== launch"
ensure_rosetta

if pgrep -qf 'DMLauncher\.exe|DigimonMasters\.exe'; then
    notify "DMO ya se está ejecutando."
    exit 0
fi

if [ ! -f "$SETUP_STAMP" ]; then
    [ "$(ask "Primera ejecución: se descargarán unos 100 MB de DirectX desde Microsoft y se preparará el juego. ¿Continuar?" "Salir" "Continuar")" = "Continuar" ] ||
        exit 0
    "$RES/setup.sh" || exit 1
    notify "Instalación completa."
fi

GAME_DIR="$(find_game_dir)"
[ -n "$GAME_DIR" ] || fail "No se encontró el juego. Borra la carpeta \"$SUPPORT_DIR\" para reinstalarlo."

cd "$GAME_DIR" || fail "No se pudo abrir la carpeta del juego."
# The installer may already have started the game's launcher.
if ! pgrep -qf 'DMLauncher\.exe|DigimonMasters\.exe'; then
    "$WINE" DMLauncher.exe >> "$LOG_FILE" 2>&1 &
    for _ in $(seq 30); do
        pgrep -qf 'DMLauncher\.exe' && break
        sleep 1
    done
fi
# Wait until the launcher, its updater, the game and XIGNCODE have all exited
# on their own. Closing the game takes about 20 seconds (patches/0002 fixed the
# hang). Polling avoids a race with `wineserver -w`, which returns at once if
# the server has not started yet.
while pgrep -qf 'DMLauncher\.exe|UpdateManager\.exe|DigimonMasters\.exe|xxd-0\.xem'; do
    sleep 5
done
"$WINESERVER" -w
log "=== exit"
