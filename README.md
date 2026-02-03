# NICK (DOT) BINGO

**Live:** [nick.bingo](https://nick.bingo)

Welcome!

## About

This site emulates the mechanical split-flap displays found in train stations and airports. Each character flips through an adjacency sequence to reach its destination, creating a satisfying retro animation effect.

Built from scratch with

- [Gleam](https://gleam.run) and [Lustre](https://hexdocs.pm/lustre/), compiled to JavaScript.
- Animations powered by [GSAP](https://gsap.com).

## Features

- Split-flap character animations with realistic mechanical timing
- Multiple scenes (pages) with auto-play and pagination
- Responsive design adapting to portrait and landscape orientations
- Custom character sets including musical notation symbols

## Development

Requires [Gleam](https://gleam.run/getting-started/installing/) and [just](https://github.com/casey/just).

```bash
# Install dependencies
gleam deps download

# Start dev server with hot reload
just dev

# Build for production
just build

# Serve locally
just serve
```

## Architecture

```
src/
  bingo.gleam      # Main application entry point and Lustre app
  scenes.gleam     # Scene definitions (content and timing)
  model.gleam      # Type definitions
  browser.gleam    # Browser FFI bindings
  browser.ffi.mjs  # GSAP animation logic and DOM interactions
  utils.gleam      # Helper functions
```

Animation notes:

1. Gleam manages application state and renders the DOM with `data-dest` attributes
2. JavaScript reads destination characters and calculates flip sequences via adjacency lists
3. GSAP animates the flaps in sequence, creating the mechanical effect

## Contact

- [LinkedIn](https://www.linkedin.com/in/nicholaspozoulakis/)
- [GitHub](https://github.com/nicholaspoz)
- [Email](mailto:nicholaspoz@gmail.com)
- [Meet](https://nick.bingo/meet)
