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

### Zero-effort: use it as-is

The GitHub Pages deployment at **https://angrycreative.github.io/code-in-the-dark-editor/** comes with a ready-to-go challenge of medium difficulty — a reference screenshot and a matching set of assets. Just point contestants at the URL and go. No downloads, no configuration.

### Custom challenge: fork and swap the assets

To run your own challenge, fork this repo and replace the files in `app/public/assets/`:

1. Replace `page.png` with a screenshot of the page contestants should recreate.
2. Add your image assets (SVGs, JPGs, etc.) to the same folder.
3. Update `assets.html` with a card for each asset (filename, dimensions, thumbnail) — the asset browser reads this file directly.
4. Push to `master` — GitHub Actions rebuilds and deploys automatically.

Contestants use the same URL; the new challenge is live within a minute.

### Local / offline

1. Run `npm run build` (see [Developing](#developing)) or grab the `dist/` folder from this repo.
2. Give each contestant a copy of the `dist/` folder (or host it on a local server).
3. Contestants open `dist/editor.html` directly in their browser — no server required.

> **Asset paths:** the result viewer loads from `assets/result.html`, so relative paths in contestant HTML resolve against `assets/`. The asset browser copies bare filenames (e.g. `logo.svg`, not `assets/logo.svg`), which is what contestants should use in their `<img src="...">` tags.

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
- `dist/assets/` — organizer-swappable files: `page.png`, `instructions.html`, `assets.html`, `result.html`, competition assets, and the ACE HTML linting worker

Source is **CoffeeScript** (`app/scripts/app.coffee`) and **SCSS** (`app/styles/index.scss`). See `CLAUDE.md` for full build and architecture details.

---

## Contributing

Pull requests welcome. Please open an issue first for larger changes so we can discuss the approach.

This is a fork of [codeinthedark/editor](https://github.com/codeinthedark/editor) — if your change is broadly useful, consider also opening a PR upstream.
