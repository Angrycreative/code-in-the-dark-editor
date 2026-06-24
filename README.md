# Code in the Dark — Editor (Angry Creative fork)

An unofficial but actively maintained fork of the [official Code in the Dark editor](https://github.com/codeinthedark/editor), updated to run on modern Node.js and browsers. If the upstream editor no longer builds or runs for you, this fork does.

*Read more about the Code in the Dark competition [here](https://github.com/codeinthedark/codeinthedark.github.io).*

**Try it online: https://angrycreative.github.io/code-in-the-dark-editor/**

---

## What is Code in the Dark?

A live coding competition where contestants race to recreate a reference screenshot using only an HTML editor — no browser preview allowed. At the end of the round everyone hits "Finish" and the results are revealed on screen.

## What this fork adds

- **Modern build toolchain** — replaced the unmaintainable gulp 3 + webpack 1 + node-sass stack with [Vite](https://vitejs.dev). Builds cleanly on Node 18+.
- **Up-to-date ACE editor** — switched from the abandoned `brace` package to the official `ace-builds`, fixing a crash on every keypress and eliminating the `<ht></ht>` tag auto-closing bug.
- **HTML linting** — the ACE HTML worker is re-enabled, showing gutter error markers for unclosed tags, malformed structure, and embedded CSS/JS errors in real time.
- **Styled dialogs** — name entry, finish confirmation, and reset confirmation all use native `<dialog>` elements instead of browser prompts, styled to match the editor theme.
- **Name badge** — contestant name is entered on first load, persisted across reloads, and shown in the corner throughout the competition.
- **Asset browser** — a dedicated panel with image thumbnails; clicking a thumbnail copies the correct relative path to the clipboard so contestants don't have to type filenames by hand.
- **Finish counter (anti-cheat)** — tracks how many times "Finish" has been clicked and displays the count visibly, including on the results screen if it exceeds one.
- **Reset button** — lets a contestant start over with a confirmation step; clears all stored data.
- **Canvas resize** — the particle canvas now resizes correctly when the browser window is resized.
- **GitHub Actions deployment** — automatically builds and deploys to GitHub Pages on every push to `master`.

---

## Running a competition round

### Online (no setup required)

Point contestants to **https://angrycreative.github.io/code-in-the-dark-editor/**. The editor runs entirely in the browser — no installation needed.

For a custom reference image or assets, use the local/offline setup below.

### Local / offline

1. Run `npm run build` (see [Developing](#developing)) or grab the `dist/` folder from this repo.
2. Give each contestant a copy of the `dist/` folder (or host it on a local server).
3. Replace `dist/assets/page.png` with a screenshot of the page to be built.
4. Add any extra assets (images, fonts, etc.) to `dist/assets/` and open `dist/assets/beach.jpg` as a template — replace or add asset entries in `dist/assets/assets.html` so the asset browser shows them with correct filenames and dimensions.
5. Contestants open `dist/editor.html` directly in their browser — no server required.

> **Asset paths:** the result viewer loads from `assets/result.html`, so relative paths in contestant HTML resolve against `assets/`. The asset browser copies bare filenames (e.g. `beach.jpg`, not `assets/beach.jpg`), which is what contestants should use in their `<img src="...">` tags.

---

## Developing

Requires Node.js 18 or later (developed on Node 24).

```bash
npm install       # install dependencies
npm run dev       # Vite dev server with HMR at http://localhost:5173
npm run build     # build to dist/
npm run preview   # serve dist/ to check the production output
```

The build produces:
- `dist/editor.html` — the fully self-contained single-file editor (JS, CSS, and fonts all inlined)
- `dist/assets/` — organizer-swappable files: `page.png`, `instructions.html`, `assets.html`, `result.html`, `beach.jpg`, and the ACE HTML linting worker

Source is **CoffeeScript** (`app/scripts/app.coffee`) and **SCSS** (`app/styles/index.scss`). See `CLAUDE.md` for full build and architecture details.

---

## Contributing

Pull requests welcome. Please open an issue first for larger changes so we can discuss the approach.

This is a fork of [codeinthedark/editor](https://github.com/codeinthedark/editor) — if your change is broadly useful, consider also opening a PR upstream.
