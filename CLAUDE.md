# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

The official editor for the [Code in the Dark](https://github.com/codeinthedark/codeinthedark.github.io) competition: a full-screen, ACE-based HTML editor with a "Power Mode" that spawns particles and shakes the screen as the typing streak grows. Contestants race to recreate a reference screenshot without seeing a live preview.

## Repository

This is the Angry Creative fork. Always push and pull from our own fork — `origin` (`github.com/Angrycreative/code-in-the-dark-editor`) — not the upstream `codeinthedark/editor`. `master` is our default branch.

## Commands

```bash
npm install        # install dependencies
npm run dev        # Vite dev server with HMR at http://localhost:5173 (use --port 9000 to match the old setup)
npm run build      # build the single-file distributable into dist/
npm run preview    # serve the built dist/ to sanity-check the production output
```

There is no test suite or linter. The build requires a modern Node (developed on Node 24); the old gulp/webpack toolchain has been removed.

## Build pipeline

The build is **Vite** (`vite.config.js`), which replaced the original gulp 3 + webpack 1 + node-sass stack (that toolchain can no longer run on modern Node). `npm run build` does everything in one step:

1. Vite/Rollup bundles the entry (`app/index.html` → `<script type="module" src="./scripts/app.coffee">`), compiling CoffeeScript via the small inline `coffee()` plugin in `vite.config.js` and SCSS via dart-sass (`sass`).
2. `vite-plugin-singlefile` inlines all JS, CSS, fonts, and logo images (as `data:` URIs) directly into the HTML — one self-contained file that runs from `file://` with no server. `base: "./"` keeps any remaining references relative so offline use works.
3. The `renameToEditorHtml()` plugin renames Vite's `index.html` output to **`dist/editor.html`** (the name the competition expects).
4. Files under `app/public/` are copied verbatim, producing `dist/assets/{page.png,instructions.html,result.html,beach.jpg}` — kept as separate files so organizers can swap the reference image and instructions between rounds without rebuilding.

**Asset split is deliberate** (see `vite.config.js` and the SCSS):
- *Inlined* assets are referenced from `app/styles/index.scss` via relative `url(../assets/…)` — the font (`app/assets/fonts/`) and logos (`app/assets/images/`). Vite processes and inlines these.
- *External / swappable* assets live in `app/public/assets/` and are referenced by literal relative `assets/…` URLs in `index.html`. Keep new swappable assets in `public/`, not `app/assets/`.

CoffeeScript's `import` statements (not `require`) are required so the compiled output is a real ES module Rollup can analyse. `optimizeDeps.include` lists `jquery`/`underscore`/`brace` explicitly because Vite's dependency scanner can't parse `.coffee` to discover them.

## Architecture

Everything lives in one class in `app/scripts/app.coffee` (~300 lines), instantiated on `$ -> new App`. The rest of `app/` is the HTML shell (`index.html`), styles (`app/styles/index.scss`), and competition assets (`app/assets/`).

- **Editor**: ACE (via the `brace` npm package) with the `vibrant_ink` theme and `html` mode. The web worker is disabled (`useWorker: false`) so there is no live linting/preview — by design for the competition.
- **Streak / Power Mode**: every `insertText` change increments `currentStreak`. At `POWER_MODE_ACTIVATION_THRESHOLD` (200) Power Mode activates (`body.power-mode` class drives CSS effects). A debounced `endStreak` (`STREAK_TIMEOUT`, 10s of no typing) resets the streak. The streak bar is a CSS `scaleX` transition that visually counts down to that reset.
- **Particles**: a fixed-size ring buffer (`MAX_PARTICLES`, `particlePointer`) avoids per-frame allocation. Spawned at the cursor's pixel position, colored by the ACE **token type** under the cursor (`PARTICLE_COLORS` maps token names to RGB). Animated on a `requestAnimationFrame` loop (`onFrame` → `drawParticles`) onto a full-window `<canvas class="canvas-overlay">`.
- **Performance guards**: `_.debounce` for save/end-streak, `_.throttle` for shake (100ms) and particle spawning (25ms). Worth preserving — the typing loop is hot.
- **Persistence**: editor content and the player name are stored in `localStorage` (`content`, `name`); there is no backend.
- **Result viewer**: the "Finish" button (after a confirm prompt) `postMessage`s the editor's HTML into the `iframe.result` (`app/public/assets/result.html`), which renders it via `document.documentElement.innerHTML`. The origin check there allows `file://` so the built `editor.html` works offline.

## Conventions

- Source is **CoffeeScript** (`app/scripts/app.coffee`) and **SCSS** (`app/styles/index.scss`). Top-of-file dependencies use ES `import` (CoffeeScript 2 passes module syntax through) — do not reintroduce `require`, or the single-file build breaks.
- Tuning constants (thresholds, particle physics, colors, exclamations) are class properties at the top of `App` — change behavior there, not scattered through methods.
- Bound methods use CoffeeScript's fat arrow (`=>`) where they're used as callbacks/handlers; keep that distinction when adding methods.
- `index.html` is parsed strictly by Vite (parse5) at build time — keep it valid HTML (e.g. close tags properly), unlike the old webpack pipeline which tolerated malformed markup.
