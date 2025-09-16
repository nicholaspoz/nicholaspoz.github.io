# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal website repository (nicholaspoz.github.io) that serves as Nick Pozoulakis' portfolio site. The project has two main components:

1. **Static Website** - The main portfolio site with HTML, CSS, and JavaScript
2. **Split Flap Component** - A Gleam-based interactive component that compiles to JavaScript

## Architecture

The repository is structured as:

- Root contains the main static website files (`index.html`, `bleed.html`)
- `split_flap/` directory contains a Gleam project that builds JavaScript components
- `js/`, `css/`, `img/`, `static/` contain frontend assets
- The Gleam project outputs to `../js/` (root-level js directory)

The split_flap Gleam project uses Lustre framework and compiles to JavaScript that's consumed by the main website.

## Common Commands

### Website Development
```bash
# Serve the website locally
just serve
# or directly:
npx serve .

# Development with auto-rebuild (runs split_flap build + serve in parallel)
just dev
```

### Split Flap Component Development
```bash
# Build the Gleam component (outputs to ../js/)
cd split_flap && just build
# or:
cd split_flap && gleam run -m lustre/dev build --outdir=../js

# Watch and rebuild on changes
cd split_flap && just dev
# or:
cd split_flap && watchexec --restart --verbose --wrap-process=session --stop-signal SIGTERM --exts gleam -- "just build"

# Run tests
cd split_flap && gleam test

# Run the Gleam project
cd split_flap && gleam run
```

## Key Files

- `split_flap/src/split_flap.gleam` - Main entry point that registers all components
- `split_flap/src/components/` - Contains Gleam component definitions (bingo, char, display, progress_bar)
- `split_flap/gleam.toml` - Gleam project configuration with Lustre dependencies
- `justfile` - Build automation for the root project
- `split_flap/justfile` - Build automation for the Gleam component

## Development Workflow

When working on the split_flap component:
1. Make changes in `split_flap/src/`
2. Run `just build` in the split_flap directory to compile to JavaScript
3. The output goes to the root `js/` directory for the main website to consume
4. Use `just dev` for automatic rebuilding during development