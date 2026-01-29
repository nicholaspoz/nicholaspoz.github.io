# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal website (nick.bingo) featuring an interactive split-flap display animation built with Gleam and Lustre, compiled to JavaScript.

## Architecture

- `src/` - Gleam source code
  - `split_flap.gleam` - Entry point
  - `browser.gleam` - Browser FFI (timers, resize observer, GSAP animation trigger)
  - `components/bingo.gleam` - Main app component (scenes, pagination, auto-play)
  - `components/bingo/` - Scene definitions and model types
  - `components/display_fns.gleam` - Display helper functions
  - `utils.gleam` - Utility functions
- `src/browser.ffi.mjs` - JavaScript FFI implementation (GSAP animation logic)
- `js/` - Static JS assets (GSAP) + Gleam build output
- `css/` - Stylesheets
- `img/` - Images
- `index.html` - Main page

## Common Commands

```bash
# Build the Gleam project (outputs to js/)
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
