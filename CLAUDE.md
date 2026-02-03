# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal website (nick.bingo) featuring an interactive split-flap display animation built with Gleam and Lustre, compiled to JavaScript.

## Architecture

- `src/` - Gleam source code
  - `bingo.gleam` - Entry point and main Lustre app (scenes, pagination, auto-play)
  - `scenes.gleam` - Scene definitions (content and timing)
  - `model.gleam` - Type definitions
  - `browser.gleam` - Browser FFI bindings (timers, resize observer)
  - `browser.ffi.mjs` - JavaScript FFI implementation (GSAP animation logic)
  - `utils.gleam` - Utility functions
- `assets/` - Source assets (css, img, js) used by Lustre dev tools
- `dist/` - Build output
  - `bingo.js` - Compiled Gleam application
  - `css/`, `img/`, `js/` - Static assets
- `index.html` - Main page
- `meet.html` - Meeting scheduler page

## Common Commands

```bash
# Build the Gleam project (outputs to dist/)
just build

# Start Lustre dev server
just dev

# Serve the site locally
just serve
```

## Key Concepts

The split-flap animation works by:
1. Gleam manages app state (current scene, auto-play, pagination)
2. When content changes, Gleam sets `data-dest` attributes on character elements
3. Gleam calls `browser.animate()` to trigger animation
4. JavaScript reads the DOM, calculates character transitions via adjacency list, and uses GSAP to animate the flaps
