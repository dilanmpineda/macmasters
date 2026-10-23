# Technical overview

How MacMasters works, what it changes in Wine, and how to build and release it.

## How the app works

`MacMasters.app` is a shell-script app bundle:

| Path in the bundle | Role |
| --- | --- |
| `Contents/MacOS/MacMasters` ([`app/launcher.sh`](../app/launcher.sh)) | Entry point. Checks Rosetta 2, runs the first-run setup, starts `DMLauncher.exe` and waits until every process of the prefix has exited (`wineserver -w`). It never starts any other Windows program. |
| `Contents/Resources/setup.sh` ([`app/setup.sh`](../app/setup.sh)) | First run: creates the prefix, downloads the DirectX June 2010 runtime from Microsoft (SHA-256 checked) and extracts `d3dcompiler_43.dll`, imports [`app/dmo.reg`](../app/dmo.reg), then runs the official game installer or clones an existing CrossOver install (APFS clone). |
| `Contents/Resources/common.sh` ([`app/common.sh`](../app/common.sh)) | Paths, dialogs (`osascript`), logging and checked downloads. |
| `Contents/Resources/wine` | Wine built from the CrossOver 26.3 source with this repository's patches, plus the x86_64 runtime libraries it needs and the 32-bit Wine Gecko. |
| `Contents/Resources/bin/cabextract` | Universal cabextract 1.11, used to extract the DirectX DLL. |
| `Contents/Resources/licenses` | Licenses and the Wine patches, for the LGPL. |

Files created on the user's Mac:

| Path | Contents |
| --- | --- |
| `~/Library/Application Support/MacMasters/prefix` | Wine prefix (win64 with WoW64) with the game wherever its installer puts it (for LDMO, `C:\MoveInteractive\LDMO`). The app finds it by looking for `DMLauncher.exe`. |
| `~/Library/Application Support/MacMasters/setup-complete` | Marks the first-run setup as done |
| `~/Library/Caches/MacMasters` | DirectX download |
| `~/Library/Logs/MacMasters/launcher.log` | Launcher log (Wine runs with `WINEDEBUG=-all`) |

## Why a custom Wine build

| Problem | Symptom | Fix |
| --- | --- | --- |
| Upstream Wine (11.16 and 11.18 tested) crashes with `nested exception on signal stack` in `_platform_memmove$VARIANT$Rosetta` while handling an exception raised by `DMLauncher.exe` under Rosetta | The game's launcher closes right after starting | Build from the CrossOver 26.3 open-source tree, which carries CodeWeavers' Rosetta changes (`CW HACK` comments in `dlls/ntdll/unix` and `dlls/wow64cpu`). Which of them fixes this crash has not been isolated yet; `CW HACK 20760` (32-to-64-bit thunks under Rosetta) is the likeliest candidate |
| Builtin `wininet` canonicalizes the request path with `UrlCanonicalizeW`, which treats `//file.bin` as a network path and appends `/` | Resource downloads get HTTP 404: "Falha ao receber dados de recursos" when entering the world | [`patches/0001`](../patches/0001-wininet-keep-leading-double-slash-in-request-path.patch) |
| When a socket is closed, pending overlapped reads complete on the IOCP with `STATUS_HANDLES_CLOSED` (error 676) instead of `STATUS_CANCELLED` (995) | The game's network thread never exits, so the game freezes on exit after entering the world | [`patches/0002`](../patches/0002-server-cancel-pending-socket-io-on-close.patch) |

Both patched bugs also affect upstream Wine 11.16 and CrossOver 26.3. Replacing `wininet` with the Windows 7 DLL avoids the trailing slash, but large HTTPS downloads then stop with `ERROR_INTERNET_TIMEOUT` (12002), so the patch is the better fix.

[`tools/repro/`](../tools/repro/) has a standalone reproducer for each bug. Build them with `i686-w64-mingw32-gcc wininet_slash.c -lwininet` and `i686-w64-mingw32-gcc iocp_close.c -lws2_32`.

## Build

```bash
xcode-select --install
brew install bison flex pkgconf freetype gnutls mingw-w64
./build.sh
```

[`build.sh`](../build.sh):

1. Downloads and checks (SHA-256) the CrossOver 26.3 source, the WineHQ 11.16 macOS build and the cabextract source.
2. Applies [`patches/`](../patches/) to the Wine tree.
3. Builds Wine for x86_64 with i386 PE support (`--enable-archs=i386,x86_64`). Homebrew only provides build tools and headers; the x86_64 libraries come from the WineHQ build, and their SONAMEs are passed to `configure` explicitly because they use bare install names.
4. Copies only the runtime libraries that Wine links to or loads by name (FreeType, GnuTLS, Vulkan loader, MoltenVK) with their dependencies, plus the x86 Wine Gecko.
5. Builds cabextract as a universal binary, assembles `dist/MacMasters.app` and signs it ad hoc.

The Wine build takes 10 to 30 minutes. Logs are written to `build/`.

## Release

```bash
./package.sh
```

Creates `dist/MacMasters-<version>.dmg` (the app, a link to Applications and the READMEs) and its `.sha256`. The version comes from `CFBundleShortVersionString` in [`app/Info.plist`](../app/Info.plist). Release notes live in [`docs/release-notes/`](release-notes/). Upload the `.dmg` and `.sha256` as release assets; they are not committed.

The app is signed ad hoc, not notarized, so users must allow it once in System Settings → Privacy & Security.

## Licenses

- This repository's code: MIT ([`LICENSE`](../LICENSE)).
- Wine: LGPL 2.1 or later. The binary is built from [crossover-sources-26.3.0.tar.gz](https://media.codeweavers.com/pub/crossover/source/crossover-sources-26.3.0.tar.gz) plus [`patches/`](../patches/), and `build.sh` reproduces it.
- Bundled libraries and cabextract: see [`THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md).
- Microsoft files and the game client are never included: each user downloads them from the official sites.
