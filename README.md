# Hex Base Builder — Godot 4 Starter Project

This is a working Phase 1–4 implementation of the plan in
`hex-base-builder-design-plan.md`: hex grid + RTS camera + card-driven
placement + resource/strength economy. No external art — every tile and
highlight is a procedurally generated hex-prism mesh, so it opens and runs
immediately.

https://github.com/user-attachments/assets/d1fdff8b-ca88-400a-9c6e-b7e83f9cd26e





## Requirements
- **Godot 4.3+** (uses typed Dictionaries/Arrays syntax and `RefCounted`
  static-method classes available in 4.x)

## Opening it
1. Open Godot 4, choose "Import", point it at this folder's `project.godot`.
2. Press **F5** (or the Play button) — it should run `scenes/main.tscn`.

## Controls
- **WASD** — pan camera (also pans near screen edges)
- **Middle-click + drag** — pan the camera directly
- **Q / E** — rotate camera around the base
- **Mouse wheel** — zoom in/out
- **Click a card** in the bottom HUD to select it — cyan hex outlines appear
  around every valid placement spot
- **Left-click** a highlighted (green when hovered) hex to place the tile
- **Right-click**, or click the same card again, to cancel selection

## What's implemented
- `HexMath` — axial coordinate ↔ world position conversion, neighbor lookup
- `HexGridManager` (autoload) — placed-tile registry, valid-placement query
- `ResourceManager` (autoload) — wood/stone/food economy, Strength total,
  a production tick every 3s that sums `resource_yield` across placed tiles
- `CardManager` (autoload) — deck/hand, selection, spend-and-redraw
- `PlacementController` — the ghost-highlight ring + hover/click placement
- `RTSCamera` — WASD/edge pan, middle-drag pan, Q/E rotate, wheel zoom, no
  Input Map setup required
- 5 starter cards (`data/cards/*.tres`): Lumber Camp, Quarry, Farm, Wall,
  Turret — edit these `.tres` files directly in the Godot inspector to
  rebalance costs/yields/strength without touching code
- A pre-placed `TileCore` at the grid center on scene start

## Known placeholder shortcuts (see the design doc for the full plan)
- **Combat is not implemented yet** — Strength accumulates but nothing
  consumes it. That's Phase 5 (abstracted wave-power-vs-Strength check) in
  the design doc.
- Tiles are flat-colored hex prisms generated in code (`HexMeshBuilder`) —
  swap in real meshes/materials on `TileBase._ready()` whenever you have art.
- HUD is built in code (`hand_ui.gd`, `stats_bar.gd`, `ui_root.gd`) rather
  than hand-laid-out in the editor — quick to reskin, but you'll likely want
  to rebuild it as real `.tscn` UI once you're designing the final look.
- Card art (`icon`) field exists on `CardData` but isn't wired into the HUD
  yet — buttons are currently text-only.

## Suggested next steps (matches the roadmap in the design doc)
1. Tune `RTSCamera` angle/zoom/speed and the ground plane size to taste.
2. Wire up card `icon` textures in `hand_ui.gd`.
3. Add Phase 5: a `WaveManager` autoload that spawns waves on a timer and
   compares wave power to `ResourceManager.total_strength`.
4. Replace procedural hex meshes with real models per tile type.
5. Add a map-radius cap or infinite-scroll decision (see design doc §12).

See `hex-base-builder-design-plan.md` for the full system-by-system
rationale and the phase-by-phase build order this project follows.
# TownTileMaker
