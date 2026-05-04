# CLAUDE.md

Project conventions for Claude Code sessions on this repo.

## Branch policy

**Always merge feature branches to `main` when work is complete.** This repo
deploys from `main`:

- `.github/workflows/pages.yml` triggers on push to `main` and rebuilds the
  GitHub Pages site (including `/app/`).
- `.github/workflows/release.yml` triggers on `v*` tag push from `main`.

If a session is asked to develop on a feature branch:

1. Develop, commit, and push to the feature branch.
2. **Merge the branch into `main`** (fast-forward when possible) and push
   `main` so Pages and Release pipelines can fire.
3. Do not delete the feature branch automatically — leave that decision to
   the maintainer.

## Releases

- Build artifacts: `bash scripts/build-releases.sh vX.Y.Z` produces per-platform
  zips in `dist/`.
- Publish: push a `v*` tag to `main`, or run the **Release** workflow via
  Actions → workflow_dispatch (it creates the tag and publishes).
- Platform archives: `web`, `windows` (also bundles legacy AutoIt build),
  `macos`, `linux`, `chromeos`, `android`, `ios`, plus `source` and
  `SHA256SUMS.txt`.

## Code layout

- `web/app/` — cross-platform PWA (HTML/JS/manifest/service worker). The
  user-facing app. Edits here ship to GitHub Pages and to every release zip.
- `web/index.html` — landing page that loads the README and links to the app.
- `ScreenShotAndAnnotate.au3`, `src/`, `HOOK.DLL`, `*.exe` — legacy AutoIt
  Windows build. Only ships in the Windows release archive.
- `scripts/build-releases.sh` — release packager.
- `.github/workflows/` — `build.yml` (CI), `pages.yml` (deploy), `release.yml`
  (publish).

## Gotchas

- `bash printf '-foo'` treats `-foo` as a flag. Use `printf '%s' '-foo'` or a
  heredoc when emitting strings that begin with `-` (e.g. CSS `-webkit-…`).
- The PWA's screen capture relies on `navigator.mediaDevices.getDisplayMedia`,
  which requires HTTPS or localhost. Pages serves over HTTPS — fine.
- iOS Safari does not expose `getDisplayMedia`. The app falls back to
  Open / Paste on that platform; do not remove those code paths.
