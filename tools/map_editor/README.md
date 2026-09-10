# pokered Map Editor

A browser-based editor for drafting overworld maps using this repo's actual
tileset/blockset graphics, then exporting files to drop into the disassembly.

## Running it

No server or build step needed — just open `tools/map_editor/index.html`
directly in a browser (Chrome, Firefox, etc.).

If you change gfx/blocksets, gfx/tilesets, or the map/tileset constants,
regenerate the editor's data with:

```
python3 tools/map_editor/build_data.py
```

## Using it

- **Set up the map**: name, `MAP_CONSTANT`, tileset, width/height (in blocks),
  border block, in the top toolbar.
- **Paint**: pick a block from the left palette (click, or drag it onto the
  map) and paint with Paint mode. Erase mode paints block 0.
- **Categories**: the palette is split into tabs (Water, Ledges, Grass,
  Doors, Path/Ground, Trees/Scenery, All) per tileset. These are derived
  automatically from this repo's real per-tileset collision/water/ledge/
  door/grass data (`data/tilesets/*.asm`) — not hand-curated per block, so
  treat them as a best-effort filter, not ground truth.
- **Multi-select paint/erase**: switch to Select mode and drag on the map to
  select a block of cells (shift+drag adds to the selection, alt+drag
  removes). Then use "Fill selection" / "Erase selection" in the toolbar to
  paint or clear every selected cell at once.
- **Houses/buildings**: a "Small House" stamp is included by default (the
  classic Red's/Blue's House exterior, verified against `maps/PalletTown.blk`).
  Drag it from the Stamps list onto the map. To capture your own building as
  a reusable stamp, switch to Select mode, drag a rectangle around blocks
  you've already painted, then click "Save selection as stamp". Stamps are
  tied to the tileset they were captured with.
- **Doors/entrances**: switch to Warp mode and click a block to drop a warp
  there, then set its destination map and destination warp id in the
  "Warps / doors / entrances" panel on the right.
- **Map connections**: enable north/south/east/west in the "Map connections"
  panel and pick the neighboring map.
- **Save/load your work**: "Save project" / "Load project" read/write a
  `.mapproject.json` file. The editor also autosaves to browser local storage.
- **Import an existing map**: "Import .blk" loads a raw `maps/*.blk` file
  into the current grid — set W/H to match that map first (see
  `constants/map_constants.asm`).

## Exporting to the disassembly

Three buttons under "Export for the disassembly":

- `<name>.blk` — raw block data, goes in `maps/`.
- `<name>_header.asm` — a `map_header`/`connection`/`end_map_header` block
  for `data/maps/headers/`.
- `<name>_objects.asm` — a `def_warp_events`/`def_bg_events`/
  `def_object_events`/`def_warps_to` skeleton for `data/maps/objects/`.

This only covers block layout, warps, and connections. You still need to,
by hand:

- Add the map to `constants/map_constants.asm`, `data/maps/maps.asm`,
  `data/maps/map_header_pointers.asm`, `data/maps/map_header_banks.asm`,
  and (if it needs music/sprites/wild encounters) the relevant tables.
- Fill in `def_bg_events` (signs) and `def_object_events` (NPCs/items) —
  the exported file leaves these empty.
- Double check the `connection`/`warp_event` target map labels: the
  exporter guesses a PascalCase label from the `MAP_CONSTANT` (e.g.
  `ROUTE_1` → `Route1`), which is wrong for irregular names like
  `SSAnne1F` (guessed as `SsAnne1f`) — compare against the actual filename
  in `data/maps/headers/`.
- Warp x/y are in tile units (each block is 2×2 tiles); clicking a block in
  Warp mode defaults to its bottom-right tile, which matches standard
  Kanto house doors but may need a ±1 nudge for other building art.
