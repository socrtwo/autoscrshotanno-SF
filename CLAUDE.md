# CLAUDE.md

A cross-platform screenshot + annotation PWA, plus a legacy AutoIt Windows
build kept for the Windows release archive. The PWA under `web/app/` is the
canonical user-facing app — assume edits there unless told otherwise.

## Repo map

- `web/app/` — the PWA: `index.html`, `app.js`, `manifest.webmanifest`,
  `service-worker.js`, icons. Ships to GitHub Pages and into every release zip.
- `web/index.html` — landing page that loads `README.md` and links to the app.
- `ScreenShotAndAnnotate.au3`, `src/`, `HOOK.DLL`, `*.exe` — legacy AutoIt
  build. Only bundled in the Windows release archive under `legacy/`.
- `scripts/build-releases.sh` — release packager; produces per-platform zips
  and `SHA256SUMS.txt` in `dist/`.
- `.github/workflows/` — `build.yml` (CI), `pages.yml` (deploy on push to
  `main`), `release.yml` (publish on `v*` tag).

## Branch policy

`main` is the deploy branch — both Pages and Releases trigger from it. When
working on a feature branch:

1. Commit and push the feature branch.
2. Merge into `main` (fast-forward when possible) and push `main` so Pages
   and Release pipelines fire.
3. Leave the feature branch alone — the maintainer decides when to delete it.

## Releasing

- Local build: `bash scripts/build-releases.sh vX.Y.Z` → `dist/`.
- Publish: push a `v*` tag to `main`, or run **Actions → Release →
  workflow_dispatch** (it tags and publishes).
- Platform archives produced: `web`, `windows` (also includes the legacy
  AutoIt build), `macos`, `linux`, `chromeos`, `android`, `ios`, plus
  `source` and `SHA256SUMS.txt`.

## Verifying changes

The PWA has no test suite. After touching `web/app/`, open `web/app/index.html`
locally (or serve via `python3 -m http.server`) and exercise the capture +
annotate flow. Service worker changes need a hard reload or cache clear to
take effect.

## Gotchas

- `printf '-foo'` treats `-foo` as a flag. Use `printf '%s' '-foo'` or a
  heredoc when emitting strings beginning with `-` (e.g. CSS `-webkit-…`).
- `navigator.mediaDevices.getDisplayMedia` requires HTTPS or localhost. Pages
  serves over HTTPS, so production is fine — local testing needs `localhost`,
  not `file://`.
- iOS Safari does not expose `getDisplayMedia`. The app falls back to
  Open / Paste on that platform — don't remove those code paths.
- Bumping anything cached by the service worker? Bump the cache version in
  `web/app/service-worker.js` or clients will serve stale assets.
