# The official editor for [Code in the Dark](https://github.com/codeinthedark/codeinthedark.github.io)
*Read more about the Code in the Dark competition [here](https://github.com/codeinthedark/codeinthedark.github.io)*

![image](https://cloud.githubusercontent.com/assets/688415/11479175/f3aedfbe-9790-11e5-9ad9-ce930fe5a3a8.png)

**Try the editor online: http://codeinthedark.com/editor/**

## How to Use
* Grab the contents of the [`dist/`](https://github.com/codeinthedark/editor/tree/master/dist) folder, or download [this zip](https://github.com/codeinthedark/editor/releases/download/v0.1.0/editor.zip). All contestants should be given a copy of the editor.
* Replace `assets/page.png` in the editor files with a screenshot of the page that is to be built in the competition. 
* Add any extra assets (e.g. images) that are required to build the page in the `assets/` folder.
* Edit the `assets/instructions.html` file with information about the extra assets and their dimensions.

## Developing
Here's how to install the dependencies and run the editor locally (needs a recent Node.js):
```bash
$ npm install
$ npm run dev
```

To build the editor, run:
```bash
$ npm run build
```
This compiles all scripts and styles and inlines them into a single `dist/editor.html` file. It also creates a `dist/assets/` folder, which separately contains the instructions and page screenshot so that they can easily be changed between different rounds of the competition.

The editor is built with [Vite](https://vitejs.dev). Earlier versions used gulp and webpack; see `CLAUDE.md` for the current build details.

## Contributing
Contributions to the editor welcome. If you've fixed a bug or implemented a cool new feature that you would like to share, please feel free to open a pull request here.
