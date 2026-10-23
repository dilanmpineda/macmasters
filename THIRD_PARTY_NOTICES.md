# Third-party notices

## Included in the app

| Component | Version | License | Source |
| --- | --- | --- | --- |
| Wine, built by this project from the CrossOver open-source tree | CrossOver 26.3.0 (Wine 11.0) + `patches/` | LGPL 2.1 or later (`licenses/wine-COPYING.LIB`) | <https://media.codeweavers.com/pub/crossover/source/crossover-sources-26.3.0.tar.gz> (SHA-256 `ac99c8ca4b3848f3e81784135f023df266b61c2345726ea55a50b3e030dd6872`) plus the patches in [`patches/`](patches/), also shipped in `licenses/wine-patches/`. `build.sh` reproduces the build. |
| x86_64 runtime libraries (FreeType, GnuTLS and its dependencies, MoltenVK, Vulkan loader, and others) and Wine Gecko 2.47.4 | As shipped in the WineHQ macOS build 11.16 | Their own licenses (LGPL, MIT, Apache 2.0, zlib, MPL 2.0…) | <https://github.com/Gcenx/macOS_Wine_builds/releases/tag/11.16> |
| cabextract | 1.11 | GPL 3.0 or later (`licenses/cabextract-COPYING`) | <https://www.cabextract.org.uk/cabextract-1.11.tar.gz> |

The libraries are copied unmodified from the WineHQ build. Before publishing release binaries, list each one with its license and keep this table up to date.

CrossOver's proprietary components (its interface, bottle tools, CrossTie, D3DMetal integration) are not used or included. Only the open-source Wine tree that CodeWeavers publishes under the LGPL is.

## Downloaded on the user's Mac, never redistributed

This file belongs to Microsoft and cannot be redistributed. The app downloads it from Microsoft on first run and checks the package's SHA-256 hash.

| File | Taken from | SHA-256 of the package |
| --- | --- | --- |
| `d3dcompiler_43.dll` (x86) | DirectX End-User Runtimes (June 2010) | `053f76dcbb28802e23341b6a787e3b0791c0fa5c8d4d011b1044172dbf89c73b` |

## The game

Digimon Masters Online and its client belong to their owners. The client is downloaded by each user from the official site and is never included in this project. This project is not affiliated with Move Games, Gameking, Bandai Namco or CodeWeavers.
