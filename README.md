# MacMasters

**English** · [Español](README.es.md) · [Português](README.pt-BR.md)

A free, unofficial Mac app to play **Digimon Masters Online** on macOS. Open it, install the game once, and play. No CrossOver license or Windows needed.

> Unofficial project, not affiliated with Move Games, Gameking, Bandai Namco or CodeWeavers. Check the game's terms of service before using it: you play at your own risk.

## What the app does

DMO is a Windows game. The app contains [Wine](https://www.winehq.org/), a free compatibility layer that runs Windows programs on macOS, and sets it up for DMO only:

1. **Creates a private Windows environment** for the game in your user folder. It is separate from everything else on your Mac.
2. **Downloads one Windows component from Microsoft** on first run: DirectX (100 MB), which the game needs for its graphics. The download is checked against a known fingerprint (SHA-256).
3. **Installs the game** with the official installer you download from [dmo.gameking.com](https://dmo.gameking.com/Main/Main.aspx), or copies it from CrossOver if you already have it there.
4. **Opens the game's own launcher**, which updates the game and lets you log in as usual.

It also includes two fixes to Wine that DMO needs on Mac. Without them, the game shows "Falha ao receber dados de recursos" when entering the world and freezes when you close it.

## What the app does not do

- It does **not** modify the game, its files or the XIGNCODE anti-cheat.
- It does **not** run other Windows programs: it only opens DMO.
- It does **not** collect or send any data. The only downloads are DirectX from Microsoft and whatever the game itself downloads.
- It does **not** include the game or any Microsoft files: each player downloads them from the official sites.

## Requirements

- A Mac with Apple Silicon (M1 to M4) or Intel, running macOS 11 or later.
- Rosetta 2 on Apple Silicon. The app offers to install it if missing.
- About 30 GB of free disk space for the game.

Tested on an Apple M4 with macOS 26.5.2. If you try it on another Mac, please share how it went in an issue.

## Install and play

1. Download `MacMasters-<version>.dmg` from [Releases](../../releases), open it and drag **MacMasters** to **Applications**.
2. Open the app. The first time, macOS blocks it because it is not notarized by Apple. Go to **System Settings → Privacy & Security**, scroll to the message about "MacMasters" and click **Open Anyway**.
3. The app's messages are in Spanish for now. Click **Continuar** (Continue) to download DirectX and prepare the environment (about a minute).
4. Choose how to get the game:
   - **Instalar de nuevo** (Install again): download the official installer from [dmo.gameking.com](https://dmo.gameking.com/Main/Main.aspx) and select it. When it finishes, the game's launcher downloads the latest updates, which can take a while.
   - **Usar la de CrossOver** (Use the CrossOver one): only shown if you already have DMO in a CrossOver bottle named `DMO`. It is copied instantly without using extra disk space.
5. Log in and play. From then on, opening the app goes straight to the game's launcher.

## Troubleshooting

| What you see | What to do |
| --- | --- |
| "MacMasters can't be opened" | Allow it in **System Settings → Privacy & Security → Open Anyway** (step 2 above). |
| Closing the game takes about 20 seconds | Normal: the game saves its settings, disconnects and closes the anti-cheat. |
| Any other problem | Open an issue and attach `~/Library/Logs/MacMasters/launcher.log`. |

## Uninstall

Delete the app and these folders (in Finder, use **Go → Go to Folder…**):

| Folder | Contents |
| --- | --- |
| `~/Library/Application Support/MacMasters` | The Windows environment with the game |
| `~/Library/Caches/MacMasters` | The DirectX download |
| `~/Library/Logs/MacMasters` | The log file |

## For developers

How the app works, the Wine fixes, how to build it and the licenses: [docs/technical.md](docs/technical.md).

## License

The app's code is MIT licensed. Wine and the other bundled components keep their own licenses: see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
