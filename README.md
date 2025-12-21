# Blockminers – Tabletop Simulator Scripting Template

This repository contains the **public reference codebase** used during the development of  
the board game **Blockminers**, implemented in Tabletop Simulator.

It is intentionally published as a **starter template** for TTS Lua scripting projects and
a **learning resource**, showing real-world, production-quality structure.

If you find this guide helpful, please consider subscribing to the [Blockminers YouTube channel](https://www.youtube.com/@blockminers-the-board-game?sub_confirmation=1)

---

## Purpose of this repository

This repo exists to answer a common question:

> “How should I structure a non-trivial Tabletop Simulator scripting project?”

Rather than isolated examples, this repository shows:
- a clean `src/` module layout
- separation of concerns via small managers
- safe config access and shared utilities
- zone- and card-driven game logic

You are encouraged to **reuse the structure and core modules**, and adapt or discard the current game logic.

---

## Core (reusable) modules

The following files are intended to be useful in *any* Tabletop Simulator project:

- `src/base.lua`
- `src/zone_manager.lua`
- `src/card_manager.lua`

If you are starting a new game, these are the files you should keep.

### `src/base.lua`

Shared helpers and safe access to global configuration.

Provides:
- `base.log_info({ message })` / `base.log_warning({ message })`  
  Broadcast helpers using configured colors.
- `base.len({ table })`  
  Counts keys in a table (useful for non-array tables).
- `base.has_tag({ object, tag })`  
  Checks for a specific TTS object tag.
- `base.config()`  
  Safe access to `CONFIG`, retrieving it from `Global` if needed.

Design goal:
- keep small, dependency-free utilities in one place
- avoid duplicated “config plumbing” across modules

---

### `src/zone_manager.lua`

Low-level utilities for working with Zones.

Provides:
- `is_in_zone({ object, zone_guid })`
- `find_zone_by_name({ name })`
- `get_zone_center_and_yaw({ zone_guid })`
- `get_objects_in_zone({ zone_guid })`

Typical uses:
- aligning decks and cards to zones
- scanning zones for markers or piles
- checking whether cards are “in play” or discarded

This module is intentionally generic and has no knowledge of game rules.

---

### `src/card_manager.lua`

Reusable card and deck primitives.

Provides:
- card/deck type checks
- tag-based card classification
- pile discovery within zones
- shuffle, draw, discard, and reshuffle logic
- consistent card orientation and placement

Design notes:
- assumes decks live in zones
- handles “deck empty → reshuffle discard” flows
- uses `Wait.time` for TTS-safe sequencing

This file tends to be the most reused across projects.

---

## Example implementation (Blockminers-specific)

All other files in `src/` are **specific to the Blockminers example implementation**.

They demonstrate how the core modules can be composed into a full game:
- phase/state management
- character ownership
- card flow
- marker economy
- snap point generation
- turn ordering and UI

These files are meant to be:
- read
- learned from
- modified or removed

They are **not** required for new projects.

---

## Using this repo as a starting point

Recommended workflow:

1. Set up VSCode and the TTS Editor for VS Code (linked below)
2. Keep:
   - the project structure
   - `base.lua`, `zone_manager.lua`, `card_manager.lua`
3. Replace `Global.lua` with your own entry point
4. Delete Blockminers-specific managers
5. Build your own game logic on top of the core utilities

---

## Tooling & learning resources

- **VS Code extension (recommended)**  
  [TTS Editor for VS Code](https://marketplace.visualstudio.com/items?itemName=sebaestschjin.tts-editor)  
  Improves syntax highlighting, autocomplete, and local editing workflow.

- **YouTube**  
  *My first 30 days of scripting in Tabletop Simulator*  
  https://www.youtube.com/watch?v=shPikb1fZA4  

  This video focuses on Tabletop Simulator setup practices such as using zones instead of deck GUIDs, tagging objects, scripted snap points, and general workflow in VS Code, and it briefly touches on scripting structure. The setup concepts remain valid, while this repository uses a more modern, modular `src/`-based layout.

---

## Versioning & maintenance

This repository represents a **public snapshot** of Blockminers development.

- It may receive occasional updates or cleanups
- It is not guaranteed to match the private development branch
- Stability is provided via tagged releases

---

## Credits and thanks

Most of what I have learned comes from the discord server [TTSClub](https://discord.gg/C7DJxqsy), and in particular I would like to thank (in no particular order):

- @Chr1Z
- @Kinithin
- @Eldin

---

## License

MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

> Note: This license applies to the code in this repository only.  
> The Blockminers game, rules, and assets are not included.
