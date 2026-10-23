#!/bin/bash
# Builds "dist/MacMasters.app".
#
# Wine is compiled from the CrossOver 26.3 open-source tree (LGPL), which
# includes CodeWeavers' Rosetta fixes, plus the patches in patches/. The x86_64
# runtime libraries Wine loads (FreeType, GnuTLS, MoltenVK...) and Wine Gecko
# are taken from the WineHQ macOS build. No Microsoft or game files are
# included: the app downloads what it needs on first run.
#
# Requirements: Xcode command line tools and Homebrew with
#   brew install bison flex pkgconf freetype gnutls mingw-w64
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
CACHE="$ROOT/build/cache"
WORK="$ROOT/build/work"
APP="$ROOT/dist/MacMasters.app"
JOBS="$(sysctl -n hw.ncpu)"

CX_VERSION="26.3.0"
CX_URL="https://media.codeweavers.com/pub/crossover/source/crossover-sources-$CX_VERSION.tar.gz"
CX_SHA="ac99c8ca4b3848f3e81784135f023df266b61c2345726ea55a50b3e030dd6872"

# Only used for its x86_64 runtime libraries and Wine Gecko.
WINEHQ_VERSION="11.16"
WINEHQ_URL="https://github.com/Gcenx/macOS_Wine_builds/releases/download/$WINEHQ_VERSION/wine-devel-$WINEHQ_VERSION-osx64.tar.xz"
WINEHQ_SHA="6f9af818b7af6001aeed7818cb32bf0155598c5ea4e3b33380a03cf814e033cd"

CABEXTRACT_VERSION="1.11"
CABEXTRACT_URL="https://www.cabextract.org.uk/cabextract-$CABEXTRACT_VERSION.tar.gz"
CABEXTRACT_SHA="b5546db1155e4c718ff3d4b278573604f30dd64c3c5bfd4657cd089b823a3ac6"

# needed_libs LIBDIR FILE...: prints the dylibs in LIBDIR that FILE... need,
# directly or through other dylibs in LIBDIR.
needed_libs() {
    local libdir="$1" name dep
    shift
    local -a queue=() seen=()
    for name in "$@"; do queue+=("$name"); done
    while [ ${#queue[@]} -gt 0 ]; do
        name="${queue[0]}"
        queue=("${queue[@]:1}")
        case " ${seen[*]-} " in *" $(basename "$name") "*) continue ;; esac
        [ -f "$name" ] || name="$libdir/$name"
        [ -f "$name" ] || continue
        [ "$(dirname "$name")" = "$libdir" ] && seen+=("$(basename "$name")")
        # A symlink is copied as is, so its target is needed too.
        [ -L "$name" ] && queue+=("$(basename "$(readlink "$name")")")
        for dep in $(otool -L "$name" | tail -n +2 | awk '{print $1}' | grep -vE '^/(System|usr/lib)/'); do
            dep="$(basename "$dep")"
            [ -f "$libdir/$dep" ] && queue+=("$dep")
        done
    done
    printf '%s\n' "${seen[@]}" | sort
}

fetch() {
    local url="$1" sha="$2" dest="$CACHE/$(basename "$1")"
    if [ ! -f "$dest" ] || [ "$(shasum -a 256 "$dest" | cut -d' ' -f1)" != "$sha" ]; then
        echo "Descargando $url" >&2
        curl -fL --retry 3 -o "$dest" "$url"
    fi
    [ "$(shasum -a 256 "$dest" | cut -d' ' -f1)" = "$sha" ] || { echo "Hash incorrecto: $dest" >&2; exit 1; }
    echo "$dest"
}

for tool in bison flex freetype gnutls nettle p11-kit; do
    brew --prefix "$tool" >/dev/null 2>&1 || { echo "Falta '$tool': brew install bison flex pkgconf freetype gnutls mingw-w64" >&2; exit 1; }
done
command -v i686-w64-mingw32-gcc >/dev/null || { echo "Falta mingw-w64: brew install mingw-w64" >&2; exit 1; }

mkdir -p "$CACHE"
rm -rf "$WORK" "$APP"
mkdir -p "$WORK" "$APP/Contents/MacOS" "$APP/Contents/Resources/bin" "$APP/Contents/Resources/licenses"

echo "==> Librerías x86_64 y Wine Gecko (WineHQ $WINEHQ_VERSION)"
winehq_tar="$(fetch "$WINEHQ_URL" "$WINEHQ_SHA")"
tar -xf "$winehq_tar" -C "$WORK"
# A path without spaces: it ends up in compiler and linker flags.
mv "$WORK/Wine Devel.app/Contents/Resources/wine" "$WORK/winehq"
RUNTIME_LIBS="$WORK/winehq/lib"

echo "==> Código de Wine (CrossOver $CX_VERSION)"
cx_tar="$(fetch "$CX_URL" "$CX_SHA")"
tar -xzf "$cx_tar" -C "$WORK" sources/wine
for patch in "$ROOT"/patches/*.patch; do
    echo "    aplicando $(basename "$patch")"
    patch -d "$WORK/sources/wine" -p1 --quiet < "$patch"
done

echo "==> Compilando Wine (x86_64 + i386, puede tardar 15-30 min)"
mkdir -p "$WORK/wine-build"
# The font tool runs during the build and needs FreeType; make runs it through
# /bin/sh, which drops DYLD_* variables, so the library sits next to it.
cp "$RUNTIME_LIBS"/{libfreetype.dylib,libz.1.dylib,libbz2.1.0.dylib,libpng16.16.dylib,libbrotlidec.1.dylib,libbrotlicommon.1.dylib} "$WORK/wine-build/"
(
    cd "$WORK/wine-build"
    export PATH="$(brew --prefix bison)/bin:$(brew --prefix flex)/bin:$PATH"
    export PKG_CONFIG_LIBDIR=/nonexistent MACOSX_DEPLOYMENT_TARGET=11.0
    # The WineHQ libraries use bare install names, which configure cannot
    # turn into SONAMEs, so these are given explicitly.
    arch -x86_64 ../sources/wine/configure --prefix="$WORK/wine-install" \
        --enable-archs=i386,x86_64 --disable-tests \
        CC="clang -arch x86_64" CXX="clang++ -arch x86_64" OBJC="clang -arch x86_64" \
        CFLAGS="-O2" CROSSCFLAGS="-O2" LDFLAGS="-L$RUNTIME_LIBS" \
        FREETYPE_CFLAGS="-I$(brew --prefix freetype)/include/freetype2" FREETYPE_LIBS="-L$RUNTIME_LIBS -lfreetype" \
        GNUTLS_CFLAGS="-I$(brew --prefix gnutls)/include -I$(brew --prefix nettle)/include -I$(brew --prefix p11-kit)/include" \
        GNUTLS_LIBS="-L$RUNTIME_LIBS -lgnutls" \
        ac_cv_lib_soname_freetype=libfreetype.6.dylib ac_cv_lib_soname_gnutls=libgnutls.30.dylib \
        ac_cv_lib_soname_vulkan=libvulkan.1.dylib ac_cv_lib_soname_MoltenVK=libMoltenVK.dylib \
        --without-x --without-alsa --without-oss --without-pulse --without-capi --without-cups \
        --without-sane --without-gphoto --without-v4l2 --without-pcap --without-usb --without-krb5 \
        --without-netapi --without-dbus --without-gstreamer --without-sdl --without-ffmpeg \
        --without-inotify --without-unwind --without-opencl --without-pcsclite \
        > "$ROOT/build/configure.log" 2>&1 || { echo "configure falló: build/configure.log" >&2; exit 1; }
    make -j"$JOBS" > "$ROOT/build/make.log" 2>&1 || { echo "make falló: build/make.log" >&2; exit 1; }
    make install > "$ROOT/build/install.log" 2>&1
)

WINE_OUT="$APP/Contents/Resources/wine"
mv "$WORK/wine-install" "$WINE_OUT"
# Only the runtime libraries this Wine links to or loads by name, with their
# dependencies (no FFmpeg, GStreamer, SDL...). -a keeps the symlinks.
needed_libs "$RUNTIME_LIBS" "$WINE_OUT"/bin/* "$WINE_OUT"/lib/wine/x86_64-unix/*.so \
    libfreetype.6.dylib libgnutls.30.dylib libvulkan.1.dylib libMoltenVK.dylib |
    while read -r lib; do cp -a "$RUNTIME_LIBS/$lib" "$WINE_OUT/lib/"; done
# DMLauncher.exe is 32-bit and only needs the x86 Wine Gecko.
mkdir -p "$WINE_OUT/share/wine/gecko"
cp -R "$WORK/winehq/share/wine/gecko/wine-gecko-2.47.4-x86" "$WINE_OUT/share/wine/gecko/"
# Only what running the game needs: no headers, man pages, import libraries
# or development tools.
rm -rf "$WINE_OUT/include" "$WINE_OUT/share/man" "$WINE_OUT/share/applications"
rm -f "$WINE_OUT"/bin/{function_grep.pl,widl,winebuild,winecpp,winedump,wineg++,winegcc,winemaker,wmc,wrc}
find "$WINE_OUT/lib/wine" -name '*.a' -delete

echo "==> cabextract $CABEXTRACT_VERSION (universal)"
cab_tar="$(fetch "$CABEXTRACT_URL" "$CABEXTRACT_SHA")"
tar -xzf "$cab_tar" -C "$WORK"
(
    cd "$WORK/cabextract-$CABEXTRACT_VERSION"
    CFLAGS="-O2 -arch arm64 -arch x86_64 -mmacosx-version-min=11.0" \
        ./configure --disable-dependency-tracking >/dev/null
    make -j"$JOBS" >/dev/null 2>&1
)
cp "$WORK/cabextract-$CABEXTRACT_VERSION/cabextract" "$APP/Contents/Resources/bin/"
cp "$WORK/cabextract-$CABEXTRACT_VERSION/COPYING" "$APP/Contents/Resources/licenses/cabextract-COPYING"

echo "==> Bundle"
cp "$ROOT/app/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/app/launcher.sh" "$APP/Contents/MacOS/MacMasters"
cp "$ROOT/app/common.sh" "$ROOT/app/setup.sh" "$ROOT/app/dmo.reg" "$APP/Contents/Resources/"
chmod +x "$APP/Contents/MacOS/MacMasters" "$APP/Contents/Resources/setup.sh"
cp "$ROOT/LICENSE" "$ROOT/THIRD_PARTY_NOTICES.md" "$APP/Contents/Resources/licenses/"
cp "$WORK/sources/wine/COPYING.LIB" "$APP/Contents/Resources/licenses/wine-COPYING.LIB"
mkdir -p "$APP/Contents/Resources/licenses/wine-patches"
cp "$ROOT"/patches/*.patch "$APP/Contents/Resources/licenses/wine-patches/"

# Ad-hoc signature so the bundle runs locally; it is not notarized.
codesign --force --deep --sign - "$APP"

echo "Listo: $APP ($(du -sh "$APP" | cut -f1))"
