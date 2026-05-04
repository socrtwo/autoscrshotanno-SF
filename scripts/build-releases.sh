#!/usr/bin/env bash
# Build platform-targeted release archives for autoscrshotanno.
# Each archive bundles the cross-platform PWA plus platform-specific
# install instructions. The Windows archive additionally includes the
# legacy AutoIt .exe and source.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
WEBAPP="$ROOT/web/app"
VERSION="${1:-$(git -C "$ROOT" describe --tags --abbrev=0 2>/dev/null || echo v2.0.0)}"
VERSION="${VERSION#v}"

rm -rf "$DIST"
mkdir -p "$DIST"

stage() {
  local name="$1"
  local dir="$DIST/stage/$name"
  rm -rf "$dir"
  mkdir -p "$dir/app"
  cp -r "$WEBAPP/." "$dir/app/"
  printf '%s\n' "$VERSION" > "$dir/VERSION"
  cp "$ROOT/LICENSE" "$dir/LICENSE"
  echo "$dir"
}

zip_dir() {
  local dir="$1"
  local archive="$2"
  ( cd "$(dirname "$dir")" && zip -qr "$archive" "$(basename "$dir")" )
  echo "  -> $(basename "$archive")"
}

write_install() {
  local file="$1"
  local platform="$2"
  shift 2
  {
    printf '# autoscrshotanno %s — %s\n\n' "$VERSION" "$platform"
    printf '## Quick start (PWA — recommended)\n\n'
    printf '1. Open `app/index.html` in a modern browser, **or** visit\n'
    printf '   https://socrtwo.github.io/autoscrshotanno-SF/app/\n'
    printf '2. Click the install / "Add to Home Screen" prompt to install as a native-feeling app.\n'
    printf '3. Press **Capture** to grab a screen, window, or tab — annotate, then save.\n\n'
    printf '## %s install notes\n\n' "$platform"
    for line in "$@"; do printf -- '%s\n' "$line"; done
    printf '\n## Tools\n\n'
    printf '%s\n' '- Pen, rectangle, ellipse, arrow, text, blur/redact'
    printf '%s\n\n' '- Undo / clear · Save PNG · Copy to clipboard · Export HTML log'
    printf '## License\n\nMIT — see LICENSE.\n'
  } > "$file"
}

###############################################################################
# Web — universal browser bundle
###############################################################################
echo "[build] web"
WEB_STAGE="$(stage "autoscrshotanno-web-$VERSION")"
write_install "$WEB_STAGE/INSTALL.md" "Web" \
  "- Host the contents of \`app/\` on any static web host (GitHub Pages, Netlify, Vercel, S3)." \
  "- Or open \`app/index.html\` directly in any modern browser." \
  "- The included service worker enables offline use after first load." \
  "- For HTTPS-only features (clipboard write, screen capture) the site must be served over HTTPS or localhost."
zip_dir "$WEB_STAGE" "$DIST/autoscrshotanno-web-$VERSION.zip"

###############################################################################
# Windows — legacy .exe + source + PWA
###############################################################################
echo "[build] windows"
WIN_STAGE="$(stage "autoscrshotanno-windows-$VERSION")"
mkdir -p "$WIN_STAGE/legacy/src"
cp "$ROOT/ScreenShotAndAnnotate.exe" "$WIN_STAGE/legacy/"
cp "$ROOT/ScreenShotAndAnnotate.au3" "$WIN_STAGE/legacy/"
cp "$ROOT/HOOK.DLL" "$WIN_STAGE/legacy/"
cp "$ROOT/config.txt" "$WIN_STAGE/legacy/"
cp -r "$ROOT/src/." "$WIN_STAGE/legacy/src/"
write_install "$WIN_STAGE/INSTALL.md" "Windows" \
  "### Option A — PWA (any Windows 10/11)" \
  "1. Open \`app/index.html\` in Edge or Chrome." \
  "2. Click the install icon in the address bar to add it to the Start menu." \
  "" \
  "### Option B — Legacy AutoIt build (Windows XP and later)" \
  "1. Run \`legacy/ScreenShotAndAnnotate.exe\` directly." \
  "2. Or install [AutoIt](https://www.autoitscript.com/) and run \`legacy/ScreenShotAndAnnotate.au3\`." \
  "3. Hotkeys: Ctrl+Alt+C capture · Ctrl+Alt+P pause · Ctrl+Alt+M toggle mouse · Ctrl+Alt+X exit."
zip_dir "$WIN_STAGE" "$DIST/autoscrshotanno-windows-$VERSION.zip"

###############################################################################
# macOS
###############################################################################
echo "[build] macos"
MAC_STAGE="$(stage "autoscrshotanno-macos-$VERSION")"
write_install "$MAC_STAGE/INSTALL.md" "macOS" \
  "1. Open \`app/index.html\` in **Safari** or **Chrome**." \
  "2. **Safari:** File → Add to Dock (macOS Sonoma+) installs it as a native-feeling app." \
  "3. **Chrome / Edge:** click the install icon in the address bar." \
  "4. Screen capture uses the macOS screen-recording permission — grant it when prompted."
zip_dir "$MAC_STAGE" "$DIST/autoscrshotanno-macos-$VERSION.zip"

###############################################################################
# Linux
###############################################################################
echo "[build] linux"
LIN_STAGE="$(stage "autoscrshotanno-linux-$VERSION")"
write_install "$LIN_STAGE/INSTALL.md" "Linux" \
  "1. Open \`app/index.html\` in Chrome, Chromium, Edge, Brave, or Firefox." \
  "2. In a Chromium-based browser: ⋮ menu → **Install ScrShotAnno…** to add a desktop launcher." \
  "3. Or run a one-liner local server: \`python3 -m http.server -d app 8080\` and open http://localhost:8080" \
  "4. On Wayland, screen capture goes through the xdg-desktop-portal — install it if capture fails."
zip_dir "$LIN_STAGE" "$DIST/autoscrshotanno-linux-$VERSION.zip"

###############################################################################
# ChromeOS
###############################################################################
echo "[build] chromeos"
CROS_STAGE="$(stage "autoscrshotanno-chromeos-$VERSION")"
write_install "$CROS_STAGE/INSTALL.md" "ChromeOS" \
  "1. Open \`app/index.html\` in Chrome, **or** visit https://socrtwo.github.io/autoscrshotanno-SF/app/" \
  "2. Click the install icon in the address bar — the app appears in the launcher." \
  "3. Pin to shelf for quick access." \
  "4. ChromeOS will request screen-share permission on first capture."
zip_dir "$CROS_STAGE" "$DIST/autoscrshotanno-chromeos-$VERSION.zip"

###############################################################################
# Android
###############################################################################
echo "[build] android"
AND_STAGE="$(stage "autoscrshotanno-android-$VERSION")"
write_install "$AND_STAGE/INSTALL.md" "Android" \
  "1. Open https://socrtwo.github.io/autoscrshotanno-SF/app/ in Chrome." \
  "2. Tap **Install app** in the menu, or accept the install banner." \
  "3. The app launches full-screen from your home screen." \
  "" \
  "### Annotating existing images" \
  "Tap **Open** to pick an image from gallery, or **Paste** to annotate a screenshot you just took with the system shortcut (Power + Volume-Down)." \
  "" \
  "### Tip" \
  "For the smoothest experience build a Trusted Web Activity (TWA) wrapper with [Bubblewrap](https://github.com/GoogleChromeLabs/bubblewrap) pointing at the hosted PWA URL."
zip_dir "$AND_STAGE" "$DIST/autoscrshotanno-android-$VERSION.zip"

###############################################################################
# iOS
###############################################################################
echo "[build] ios"
IOS_STAGE="$(stage "autoscrshotanno-ios-$VERSION")"
write_install "$IOS_STAGE/INSTALL.md" "iOS / iPadOS" \
  "1. Open https://socrtwo.github.io/autoscrshotanno-SF/app/ in **Safari** (required for install)." \
  "2. Tap the Share button → **Add to Home Screen**." \
  "3. The app launches in standalone mode with no browser chrome." \
  "" \
  "### Annotating existing images" \
  "Tap **Open** to pick from Photos, or **Paste** to annotate the most recent screenshot copied to the clipboard." \
  "" \
  "### Note" \
  "iOS Safari does not currently expose \`getDisplayMedia\` — to annotate live screen content, take a screenshot first (Side+Volume-Up) and tap **Open** or **Paste**."
zip_dir "$IOS_STAGE" "$DIST/autoscrshotanno-ios-$VERSION.zip"

###############################################################################
# Source archive
###############################################################################
echo "[build] source"
git -C "$ROOT" archive --format=zip --prefix="autoscrshotanno-source-$VERSION/" -o "$DIST/autoscrshotanno-source-$VERSION.zip" HEAD

rm -rf "$DIST/stage"

###############################################################################
# Checksums
###############################################################################
( cd "$DIST" && sha256sum *.zip > SHA256SUMS.txt )

echo
echo "Built artifacts:"
ls -la "$DIST"
