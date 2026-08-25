# Obsidian In-App Screenshot Skill

## Purpose
Capture pixel-perfect, native screenshots of the Obsidian application or active editor pane directly via Obsidian's internal rendering engine without requiring macOS screen recording permissions or OS-level screen capture tools.

## Available Capabilities
- **Tool**: `obsidian_take_screenshot`
  - `mode`: `"window"` (entire Obsidian application window) or `"active_pane"` (only the focused editor pane, active note, or graph)
  - `filename`: Optional custom filename (saved into `<vault>/.pi/screenshots/`)
- **Slash Command**: `/obsidian-screenshot [window|active_pane]`

## Directives
- When asked to capture Obsidian, an open note, graph view, or layout, ALWAYS use `obsidian_take_screenshot` instead of macOS `screencapture` or external tools.
- Use `mode: "active_pane"` for inspecting the note content or focused document.
- Use `mode: "window"` for verifying full workspace layout, sidebars, and ribbons.
- Screenshots are saved directly to `<vault>/.pi/screenshots/<filename>.png`.
