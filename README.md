<!--MODERNIZED:v2-->
# autoscrshotanno

Capture and annotate screenshots — across **Windows, macOS, Linux, ChromeOS, Android, iOS, and the Web**.

[![Live app](https://img.shields.io/badge/launch-app-ff2e93?style=for-the-badge)](https://socrtwo.github.io/autoscrshotanno-SF/app/)
[![Releases](https://img.shields.io/github/v/release/socrtwo/autoscrshotanno-SF?style=for-the-badge&color=7c3aed)](https://github.com/socrtwo/autoscrshotanno-SF/releases)
[![License](https://img.shields.io/github/license/socrtwo/autoscrshotanno-SF?style=for-the-badge&color=22d3ee)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/socrtwo/autoscrshotanno-SF/build.yml?style=for-the-badge&color=34d399)](https://github.com/socrtwo/autoscrshotanno-SF/actions)

🚀 **Launch:** https://socrtwo.github.io/autoscrshotanno-SF/app/  
📦 **Download:** [Releases](https://github.com/socrtwo/autoscrshotanno-SF/releases)  
📂 **Source:** [`socrtwo/autoscrshotanno-SF`](https://github.com/socrtwo/autoscrshotanno-SF)

---

## What it is

A modern, installable PWA for grabbing a screen, window, or tab and annotating it
with arrows, shapes, text, freehand, or blur/redact regions. Save as PNG, copy
to clipboard, or export an HTML log of the session.

The original Windows AutoIt build (auto-captures on UI events) is still
included in the Windows release archive under `legacy/`.

## Platforms

| Platform   | Install path |
|------------|--------------|
| **Web**        | Open the [live app](https://socrtwo.github.io/autoscrshotanno-SF/app/) |
| **Windows**    | PWA (Edge/Chrome → Install) **or** legacy `ScreenShotAndAnnotate.exe` |
| **macOS**      | Safari → File → Add to Dock, **or** Chrome → Install |
| **Linux**      | Chromium-based browser → Install ScrShotAnno… |
| **ChromeOS**   | Address-bar install → app launcher |
| **Android**    | Chrome → Install app, or build a TWA wrapper |
| **iOS / iPadOS** | Safari → Share → Add to Home Screen |

Pre-built archives for every platform are attached to each [release](https://github.com/socrtwo/autoscrshotanno-SF/releases) — each archive contains the PWA plus platform-specific install notes.

## Features

- **Capture** screen, window, or tab via the browser Screen Capture API
- **Open** any image, or **Paste** from clipboard (Ctrl/Cmd+V)
- Annotation tools: pen, rectangle, ellipse, arrow, text, blur/redact
- Color picker, adjustable stroke width, undo, clear
- **Save PNG**, **Copy to clipboard**, **Export HTML log**
- Installable as a PWA — works offline after first load
- Keyboard shortcuts: `Ctrl/Cmd+Alt+C` capture · `Ctrl/Cmd+Z` undo · `Ctrl/Cmd+S` save · `Ctrl/Cmd+V` paste

### Legacy Windows build (still shipped)

The original AutoIt script auto-captures whenever the user changes window,
right-clicks, or selects a sub-menu, and logs to Word and/or HTML.

- Hotkeys: `Ctrl+Alt+C` capture · `Ctrl+Alt+P` pause · `Ctrl+Alt+M` toggle mouse · `Ctrl+Alt+X` exit
- Source: [`ScreenShotAndAnnotate.au3`](ScreenShotAndAnnotate.au3) and [`src/`](src/)

## Building releases locally

```bash
bash scripts/build-releases.sh v2.0.0
ls dist/
```

This produces a zip per platform plus `SHA256SUMS.txt`. The
[`Release` workflow](.github/workflows/release.yml) runs the same script on tag
push (`v*`) and uploads the archives to the GitHub Release.

## Project layout

```
web/app/             cross-platform PWA (HTML / JS / manifest / service worker)
web/index.html       landing page (loads README, links to app)
ScreenShotAndAnnotate.au3, src/, HOOK.DLL, *.exe
                     legacy AutoIt build (Windows)
scripts/build-releases.sh  packages dist/ archives for each platform
.github/workflows/   CI + release automation, GitHub Pages deploy
```

## Origin

Originally hosted on [SourceForge](https://sourceforge.net/projects/autoscrshotanno/),
migrated via [SF2GH Migrator](https://github.com/socrtwo/sf-to-github). This
GitHub repo is the canonical home; all updates, issues, and releases happen
here.

## Contributing

Pull requests welcome. For substantial changes, please open an issue first.

## License

MIT — see [LICENSE](LICENSE).

---

*Maintained by [@socrtwo](https://github.com/socrtwo)*
