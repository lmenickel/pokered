#!/usr/bin/env python3
"""
Generates tools/map_editor/data/*.json from the repo's real tileset/blockset
graphics and map constants, so the map editor paints with the game's actual
blocks instead of placeholder art.

Run this again any time gfx/blocksets, gfx/tilesets, or constants/*_constants.asm
change (e.g. after adding a new tileset or map).
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent / "data"
OUT.mkdir(exist_ok=True)

# const name (constants/tileset_constants.asm) -> gfx/{blocksets,tilesets} basename
# taken from gfx/tilesets.asm, which pairs each tileset id with its GFX/Block file.
TILESET_FILES = {
    "OVERWORLD": "overworld",
    "REDS_HOUSE_1": "reds_house",
    "MART": "pokecenter",
    "FOREST": "forest",
    "REDS_HOUSE_2": "reds_house",
    "DOJO": "gym",
    "POKECENTER": "pokecenter",
    "GYM": "gym",
    "HOUSE": "house",
    "FOREST_GATE": "gate",
    "MUSEUM": "gate",
    "UNDERGROUND": "underground",
    "GATE": "gate",
    "SHIP": "ship",
    "SHIP_PORT": "ship_port",
    "CEMETERY": "cemetery",
    "INTERIOR": "interior",
    "CAVERN": "cavern",
    "LOBBY": "lobby",
    "MANSION": "mansion",
    "LAB": "lab",
    "CLUB": "club",
    "FACILITY": "facility",
    "PLATEAU": "plateau",
}


def label_for(const):
    words = const.replace("_", " ").title().split()
    return " ".join(words)


def pascal_name(const):
    # REDS_HOUSE_1 -> RedsHouse1, matching the class names used in
    # tileset_headers.asm / collision_tile_ids.asm labels.
    return "".join(w[:1].upper() + w[1:].lower() for w in const.split("_"))


def parse_hex_or_neg1(tok):
    tok = tok.strip()
    if tok == "-1":
        return None
    return int(tok.lstrip("$"), 16)


def parse_grass_ids():
    # tileset Name, counter1, counter2, counter3, grass, TILEANIM_*
    text = (ROOT / "data/tilesets/tileset_headers.asm").read_text()
    out = {}
    for m in re.finditer(
        r"tileset (\w+),\s*(-1|\$[0-9A-Fa-f]+),\s*(-1|\$[0-9A-Fa-f]+),\s*(-1|\$[0-9A-Fa-f]+),\s*(-1|\$[0-9A-Fa-f]+),",
        text,
    ):
        out[m.group(1)] = parse_hex_or_neg1(m.group(5))
    return out


def parse_passable_ids():
    # {Name}_Coll:: (possibly several labels stacked) followed by a
    # coll_tiles line listing that tileset's walkable tile ids.
    text = (ROOT / "data/tilesets/collision_tile_ids.asm").read_text()
    out = {}
    pending = []
    for line in text.splitlines():
        m = re.match(r"(\w+)_Coll::", line.strip())
        if m:
            pending.append(m.group(1))
            continue
        m = re.match(r"coll_tiles(.*)", line.strip())
        if m:
            ids = [parse_hex_or_neg1(t) for t in m.group(1).split(";")[0].split(",") if t.strip()]
            ids = {i for i in ids if i is not None}
            for name in pending:
                out[name] = ids
            pending = []
    return out


def parse_ledge_ids():
    text = (ROOT / "data/tilesets/ledge_tiles.asm").read_text()
    return {
        int(m.group(1), 16)
        for m in re.finditer(r"SPRITE_FACING_\w+,\s*\$[0-9A-Fa-f]+,\s*\$([0-9A-Fa-f]+),", text)
    }


def parse_water_tilesets():
    text = (ROOT / "data/tilesets/water_tilesets.asm").read_text()
    return set(re.findall(r"db (\w+)", text)) - {"-1"}


def parse_door_ids():
    text = (ROOT / "data/tilesets/door_tile_ids.asm").read_text()
    pointers = re.findall(r"dbw (\w+),\s*\.(\w+)", text)
    labels = {}
    for m in re.finditer(r"\.(\w+):\s*\n\s*door_tiles(.*)", text):
        ids = {parse_hex_or_neg1(t) for t in m.group(2).split(";")[0].split(",") if t.strip()}
        labels[m.group(1)] = {i for i in ids if i is not None}
    return {const: labels.get(label, set()) for const, label in pointers}


WATER_TILE_IDS = {0x14, 0x32, 0x48}
# The water/shore tile graphics get reused as plain dark-pixel filler inside
# unrelated art (e.g. tree/stump shading in the Forest tileset), so a block
# with just one or two of these tiles is usually NOT water - require a real
# patch of it before calling a block "water", otherwise fall through to
# whatever the block actually is (grass, scenery, ...).
MIN_WATER_TILE_COUNT = 4

CATEGORY_LABELS = {
    "water": "Water",
    "ledge": "Ledges",
    "grass": "Grass",
    "door": "Doors",
    "path": "Path / Ground",
    "scenery": "Trees / Scenery",
}


# A block that's mostly plain grass/path filler but has a real chunk of
# something else going on (a tree canopy corner, a stump, a rock) should
# read as scenery, not grass - even though the grass tile outnumbers it
# pixel-for-pixel. E.g. Viridian Forest's big round trees are built by
# tiling a small "canopy corner" glyph into a different corner of an
# otherwise-grass block on each of 4 adjacent blocks; by raw tile count
# those blocks are 75% grass, but the tree is the whole point of the block.
MIN_OBSTACLE_TILE_COUNT = 4


def classify_block(tiles, grass_id, passable_ids, ledge_ids, has_water, door_ids):
    # LedgeTiles isn't keyed by tileset in the source data, but ledges are
    # only ever placed on outdoor route/town maps, i.e. the tilesets that
    # also have a grass tile - everywhere else those same raw tile ids mean
    # something unrelated (carpets, counters, ...), which was flooding
    # indoor tilesets with bogus "ledge" blocks.
    has_ledges = grass_id is not None

    tile_set = set(tiles)
    if has_water:
        water_count = sum(1 for t in tiles if t in WATER_TILE_IDS)
        if water_count >= MIN_WATER_TILE_COUNT:
            return "water"
    if has_ledges and tile_set & ledge_ids:
        return "ledge"
    if door_ids and tile_set & door_ids:
        return "door"

    if grass_id is not None and grass_id in tile_set:
        # Usually a plain/edge grass block - but if a real chunk of the
        # block is neither grass nor plain ground, the grass is just
        # background behind a decorative feature (a tree canopy corner, a
        # stump), so that takes priority instead. Scoped to only the grass
        # case, not path in general, so it can't eat plain ground blocks
        # that happen to have one non-listed border/edge tile.
        accounted_for = set(passable_ids) | {grass_id} | ledge_ids
        if has_water:
            accounted_for |= WATER_TILE_IDS
        if door_ids:
            accounted_for |= door_ids
        obstacle_count = sum(1 for t in tiles if t not in accounted_for)
        if obstacle_count >= MIN_OBSTACLE_TILE_COUNT:
            return "scenery"
        return "grass"

    passable_count = sum(1 for t in tiles if t in passable_ids)
    if passable_count >= 8:
        return "path"
    return "scenery"


def load_tileset_constants():
    text = (ROOT / "constants/tileset_constants.asm").read_text()
    return re.findall(r"const (\w+)\s*;", text)


def load_map_constants():
    text = (ROOT / "constants/map_constants.asm").read_text()
    out = []
    for m in re.finditer(r"map_const (\w+),\s*(\d+),\s*(\d+)", text):
        out.append({"const": m.group(1), "width": int(m.group(2)), "height": int(m.group(3))})
    return out


def build_tilesets():
    consts = load_tileset_constants()
    grass_ids = parse_grass_ids()
    passable_ids = parse_passable_ids()
    ledge_ids = parse_ledge_ids()
    water_tilesets = parse_water_tilesets()
    door_ids = parse_door_ids()

    tilesets = []
    for i, const in enumerate(consts):
        base = TILESET_FILES.get(const)
        if base is None:
            continue
        bst_path = ROOT / f"gfx/blocksets/{base}.bst"
        raw = bst_path.read_bytes()
        blocks = [list(raw[i : i + 16]) for i in range(0, len(raw), 16)]

        pname = pascal_name(const)
        grass_id = grass_ids.get(pname)
        passable = passable_ids.get(pname, set())
        has_water = const in water_tilesets
        doors = door_ids.get(const, set())

        categories = [
            classify_block(b, grass_id, passable, ledge_ids, has_water, doors) for b in blocks
        ]

        tilesets.append(
            {
                "id": i,
                "const": const,
                "label": label_for(const),
                "pngFile": f"gfx/tilesets/{base}.png",
                "tileCols": 16,
                "numBlocks": len(blocks),
                "blocks": blocks,
                "categories": categories,
            }
        )
    return tilesets


def main():
    tilesets = build_tilesets()
    maps = load_map_constants()
    (OUT / "tilesets.json").write_text(json.dumps(tilesets))
    (OUT / "map_constants.json").write_text(json.dumps(maps))
    # Also emit as a plain <script> so the app works over file:// with no
    # local server (browsers block fetch()/XHR of local JSON files under
    # file://, but a <script src> tag loads fine).
    payload = {"tilesets": tilesets, "mapConstants": maps, "categoryLabels": CATEGORY_LABELS}
    js = "window.MAP_EDITOR_DATA = " + json.dumps(payload) + ";\n"
    (OUT / "data.js").write_text(js)
    print(f"Wrote {len(tilesets)} tilesets and {len(maps)} map constants to {OUT}")


if __name__ == "__main__":
    main()
