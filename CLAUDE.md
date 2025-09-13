# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is Nick Pozoulakis' personal website hosted at nick.bingo. It's a static GitHub Pages site featuring:
- Main site: HTML/CSS/JS with custom web components
- Interactive split-flap display component built in Gleam
- Professional portfolio showcasing software engineering work

## Development Commands

### Main Site Development
The main site consists of static HTML files with custom styling and JavaScript modules.

### Split-Flap Component Development
The interactive split-flap display is built using Gleam and Lustre:

```bash
# Navigate to split_flap directory first
cd split_flap

# Build the component (outputs to ../js/)
just build
# OR
gleam run -m lustre/dev build --outdir=../js

# Development with file watching
just dev
# OR  
watchexec --restart --verbose --wrap-process=session --stop-signal SIGTERM --exts gleam -- "just build"

# Run tests
gleam test

# Run the project
gleam run
```

## Architecture

### File Structure
- `index.html` - Main homepage using `<bingo-office>` component
- `bleed.html` - Alternative version using `<nick-dot-bingo>` component  
- `css/styles.css` - Global styles with monospace font stack
- `js/split_flap.mjs` - Compiled Gleam component (generated, do not edit)
- `split_flap/` - Gleam source code for the interactive display

### Split-Flap Component (Gleam)
- **Language**: Gleam targeting JavaScript
- **Framework**: Lustre for web components
- **Build tool**: Just for task automation
- **Entry point**: `split_flap/src/split_flap.gleam`
- **Components**: Located in `split_flap/src/components/`
  - `bingo.gleam` - Main bingo display logic
  - `char.gleam` - Character display components  
  - `display.gleam` - Display management
  - `office.gleam` - Office layout component
  - `progress_bar.gleam` - Progress indicators

### Web Component Integration
The Gleam code compiles to JavaScript modules that register custom web elements:
- `<bingo-office>` - Used in index.html
- `<nick-dot-bingo>` - Used in bleed.html

## Development Workflow

1. Make changes to Gleam source files in `split_flap/src/`
2. Run `just build` to compile to JavaScript
3. Test changes by opening HTML files in browser
4. The compiled output automatically updates `js/split_flap.mjs`

## Key Technical Details

- **Target**: GitHub Pages static hosting
- **Fonts**: Fragment Mono, Nanum Gothic Coding, Noto Music 
- **Meta**: Comprehensive SEO and social media tags
- **Security**: X-Frame-Options, CSP headers in HTML
- **Analytics**: Google Analytics integration
- **Mobile**: Responsive design with safe area insets

When working with this codebase:
- Changes to the interactive component require rebuilding the Gleam code
- Static HTML/CSS changes take effect immediately  
- The main entry points are the two HTML files in the root directory