import { defineConfig } from "vite"
import { viteSingleFile } from "vite-plugin-singlefile"
import { compile } from "coffeescript"
import { createReadStream } from "node:fs"
import { copyFile, mkdir, rename } from "node:fs/promises"
import { resolve } from "node:path"

// Compile .coffee modules. CoffeeScript 2 passes ESM import/export through,
// so the emitted JS is a real module Vite/Rollup can analyse.
function coffee() {
  return {
    name: "coffee",
    enforce: "pre",
    transform(code, id) {
      if (!id.endsWith(".coffee")) return null
      const js = compile(code, { bare: true, inlineMap: true, filename: id })
      return { code: js, map: null }
    },
  }
}

// Serve worker-html.js from node_modules during dev; copy it to dist/assets/workers/ at build time.
// ACE needs the worker as a separate file (workers can't be inlined into the main bundle).
function aceWorkers(outDir) {
  const workerSrc = resolve(__dirname, "node_modules/ace-builds/src-noconflict/worker-html.js")
  return {
    name: "ace-workers",
    configureServer(server) {
      server.middlewares.use("/assets/workers/worker-html.js", (_req, res) => {
        res.setHeader("Content-Type", "application/javascript; charset=utf-8")
        createReadStream(workerSrc).pipe(res)
      })
    },
    async closeBundle() {
      const dir = resolve(outDir, "assets/workers")
      await mkdir(dir, { recursive: true })
      await copyFile(workerSrc, resolve(dir, "worker-html.js"))
    },
  }
}

// vite-plugin-singlefile emits dist/index.html; the competition expects editor.html.
function renameToEditorHtml(outDir) {
  return {
    name: "rename-to-editor-html",
    closeBundle: async () => {
      await rename(resolve(outDir, "index.html"), resolve(outDir, "editor.html"))
    },
  }
}

const outDir = resolve(__dirname, "dist")

export default defineConfig({
  root: "app",
  // Relative base so the built single file works opened directly from file://.
  base: "./",
  plugins: [coffee(), viteSingleFile(), aceWorkers(outDir), renameToEditorHtml(outDir)],
  // .coffee confuses the dependency scanner, so name these explicitly.
  optimizeDeps: { include: ["jquery", "underscore", "ace-builds"] },
  css: {
    preprocessorOptions: {
      scss: { api: "modern-compiler" },
    },
  },
  build: {
    outDir,
    emptyOutDir: true,
    rollupOptions: {
      input: resolve(__dirname, "app/index.html"),
    },
  },
})
