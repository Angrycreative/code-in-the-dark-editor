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
- **Multi-challenge support** — run 2–3 parallel challenges (e.g. Easy/Normal/Hard) from one build. Each challenge has its own reference screenshot and asset set; contestants pick their challenge on first load and must reset to switch. No rebuild needed to configure challenges between rounds.

---

## Running a competition round

### Zero-effort: use it as-is

The GitHub Pages deployment at **https://angrycreative.github.io/code-in-the-dark-editor/** comes with a ready-to-go set of challenges. Just point contestants at the URL and go. No downloads, no configuration.

### Setting up challenges

Each challenge lives in its own subfolder under `dist/assets/challenges/`. The build ships three by default: `easy/`, `normal/`, and `hard/`. To configure them for your round (no rebuild required):

**1. Add the reference screenshot**

Drop a `page.png` into each challenge folder:

```
dist/assets/challenges/
  easy/page.png
  normal/page.png
  hard/page.png
```

**2. Add the challenge assets**

Put any SVGs, images, or other files contestants can reference into the same folder alongside `page.png`. Then update `assets.html` in that folder with a card for each file — the asset browser reads this file directly.

Note that `assets.html` uses paths relative to itself for image previews (e.g. `src="logo.svg"`), but the `data-path` values must be prefixed with `challenges/{id}/` so that the copied path resolves correctly from the result viewer (e.g. `data-path="challenges/easy/logo.svg"`). The included placeholder `assets.html` files are already set up this way.

**3. Name the challenges (optional)**

Edit `dist/assets/challenges-config.js` to set the label shown on the challenge selection screen:

```js
window.CHALLENGES = [
  { id: "easy",   label: "Easy"   },
  { id: "normal", label: "Normal" },
  { id: "hard",   label: "Hard"   }
];
```

The `id` must match the subfolder name. Add or remove entries to change how many challenges are offered. This is the only file that needs editing between rounds if you're keeping the same structure.

**4. Distribute**

Give each contestant the full `dist/` folder (or host it). They open `dist/editor.html` in their browser, pick a challenge, and start coding. Switching challenges requires a full reset (which wipes their code), so accidental switches aren't silent.

### Fork and customise

To run your own branded version with custom challenges baked into the source:

1. Fork this repo and update the files in `app/public/assets/challenges/`.
2. Adjust the challenge labels in `app/public/assets/challenges-config.js`.
3. Push to `master` — GitHub Actions rebuilds and deploys automatically.

Contestants use your GitHub Pages URL; the new challenges are live within a minute.

### Local / offline

1. Run `npm run build` (see [Developing](#developing)) or grab the `dist/` folder from this repo.
2. Give each contestant a copy of the `dist/` folder.
3. Contestants open `dist/editor.html` directly in their browser — no server required.

> **Asset paths in contestant code:** the result viewer loads from `assets/result.html`, so paths in contestant HTML resolve relative to `assets/`. Challenge assets are under `assets/challenges/{id}/`, so contestants use paths like `challenges/easy/logo.svg` in their `<img src="...">` tags. The asset browser copies these paths automatically when a thumbnail is clicked.

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
- `dist/assets/challenges-config.js` — editable challenge list (names and IDs); the only file that needs changing between rounds
- `dist/assets/challenges/{easy,normal,hard}/` — one folder per challenge, each containing `page.png`, `assets.html`, and the competition SVGs; swap these out per round without rebuilding
- `dist/assets/` — shared files: `instructions.html`, `result.html`, and the ACE HTML linting worker

Source is **CoffeeScript** (`app/scripts/app.coffee`) and **SCSS** (`app/styles/index.scss`). See `CLAUDE.md` for full build and architecture details.

---

## Contributing

Pull requests welcome. Please open an issue first for larger changes so we can discuss the approach.

This is a fork of [codeinthedark/editor](https://github.com/codeinthedark/editor) — if your change is broadly useful, consider also opening a PR upstream.
