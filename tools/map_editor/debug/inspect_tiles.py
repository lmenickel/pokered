#!/usr/bin/env python3
"""
Visual debugger for the map editor's tile/block data. Renders the actual
2bpp grayscale tile graphics (no PIL/ImageMagick required, pure stdlib) so
you can eyeball what a block or a slice of a real compiled map looks like,
and cross-check it against tools/map_editor/data/tilesets.json's category
for that block.

Usage:
  # every block in a tileset's blockset, tagged with index + category
  # (W=water L=ledge G=grass D=door P=path S=scenery)
  python3 inspect_tiles.py blocks FOREST out.png
  python3 inspect_tiles.py blocks FOREST out.png scenery   # only one category

  # a rectangular slice of a *compiled* map, using its real block ids -
  # this is the most trustworthy view since it's exactly what's on the
  # actual map, not just "some block that exists in the blockset"
  python3 inspect_tiles.py map FOREST ../../maps/ViridianForest.blk 17 0 0 6 12 out.png
  #                              ^tileset  ^.blk file      ^map w ^x0 ^y0 ^w ^h

Output is a plain PNG - open it with any image viewer.
"""
import json
import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DATA_FILE = Path(__file__).resolve().parent.parent / "data" / "tilesets.json"


# ---------- minimal PNG read/write (stdlib only: zlib + struct) ----------

def read_png_2bpp_gray(path):
    data = Path(path).read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    pos = 8
    idat = b""
    w = h = bitdepth = None
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        ctype = data[pos + 4:pos + 8]
        cdata = data[pos + 8:pos + 8 + length]
        if ctype == b"IHDR":
            w, h, bitdepth, colortype, comp, filt, interlace = struct.unpack(">IIBBBBB", cdata)
        elif ctype == b"IDAT":
            idat += cdata
        elif ctype == b"IEND":
            break
        pos += 8 + length + 4
    raw = zlib.decompress(idat)
    bpp = 1
    row_bytes = (w * bitdepth + 7) // 8
    stride = row_bytes + 1
    prev = bytearray(row_bytes)
    rows = []
    for y in range(h):
        off = y * stride
        ftype = raw[off]
        cur = bytearray(raw[off + 1:off + 1 + row_bytes])
        if ftype == 1:
            for i in range(row_bytes):
                a = cur[i - bpp] if i - bpp >= 0 else 0
                cur[i] = (cur[i] + a) & 0xFF
        elif ftype == 2:
            for i in range(row_bytes):
                cur[i] = (cur[i] + prev[i]) & 0xFF
        elif ftype == 3:
            for i in range(row_bytes):
                a = cur[i - bpp] if i - bpp >= 0 else 0
                cur[i] = (cur[i] + (a + prev[i]) // 2) & 0xFF
        elif ftype == 4:
            for i in range(row_bytes):
                a = cur[i - bpp] if i - bpp >= 0 else 0
                b = prev[i]
                c = prev[i - bpp] if i - bpp >= 0 else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                cur[i] = (cur[i] + pr) & 0xFF
        rows.append(cur)
        prev = cur

    out = [[0] * w for _ in range(h)]
    mask = (1 << bitdepth) - 1
    for y in range(h):
        x = 0
        for byte in rows[y]:
            for shift in range(8 - bitdepth, -1, -bitdepth):
                if x >= w:
                    break
                out[y][x] = (byte >> shift) & mask
                x += 1
    return w, h, bitdepth, out


def write_png_gray8(path, w, h, pixels):
    sig = b"\x89PNG\r\n\x1a\n"

    def chunk(ctype, cdata):
        return struct.pack(">I", len(cdata)) + ctype + cdata + struct.pack(">I", zlib.crc32(ctype + cdata) & 0xFFFFFFFF)

    ihdr = struct.pack(">IIBBBBB", w, h, 8, 0, 0, 0, 0)
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        raw.extend(pixels[y])
    idat = zlib.compress(bytes(raw), 9)
    Path(path).write_bytes(sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b""))


# ---------- tiny bitmap font, just enough for labels ----------

FONT3X5 = {
    "0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"],
    "2": ["111", "001", "111", "100", "111"], "3": ["111", "001", "111", "001", "111"],
    "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
    "6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "001", "001", "001"],
    "8": ["111", "101", "111", "101", "111"], "9": ["111", "101", "111", "001", "111"],
    "W": ["101", "101", "111", "111", "101"], "L": ["100", "100", "100", "100", "111"],
    "G": ["111", "100", "101", "101", "111"], "D": ["110", "101", "101", "101", "110"],
    "P": ["111", "101", "111", "100", "100"], "S": ["111", "100", "111", "001", "111"],
}


def stamp_text(out, x0, y0, text, color=255, bg=0):
    cx = x0
    for ch in text:
        pat = FONT3X5.get(ch, ["000"] * 5)
        for ry, row in enumerate(pat):
            for rx, c in enumerate(row):
                yy, xx = y0 + ry, cx + rx
                if 0 <= yy < len(out) and 0 <= xx < len(out[0]):
                    out[yy][xx] = color if c == "1" else bg
        cx += 4


# ---------- block composition ----------

def compose_block(tile_px, cols_in_sheet, block_tiles, scale):
    size = 4 * 8 * scale
    out = [[0] * size for _ in range(size)]
    for i, tid in enumerate(block_tiles):
        ty, tx = divmod(i, 4)
        sx, sy = (tid % cols_in_sheet) * 8, (tid // cols_in_sheet) * 8
        for py in range(8):
            for px in range(8):
                g = int(tile_px[sy + py][sx + px] * 255 / 3)
                for dy in range(scale):
                    for dx in range(scale):
                        out[ty * 8 * scale + py * scale + dy][tx * 8 * scale + px * scale + dx] = g
    return out


def load_tileset(const):
    data = json.loads(DATA_FILE.read_text())
    return next(t for t in data if t["const"] == const)


CAT_LETTERS = {"water": "W", "ledge": "L", "grass": "G", "door": "D", "path": "P", "scenery": "S"}


def cmd_blocks(tileset_const, out_path, category=None, scale=6, per_row=12):
    ts = load_tileset(tileset_const)
    w, h, bd, px = read_png_2bpp_gray(ROOT / ts["pngFile"])
    cols_in_sheet = w // 8
    indices = [i for i in range(len(ts["blocks"])) if not category or ts["categories"][i] == category]

    cell = 4 * 8 * scale
    pad, label_h = 2, 7
    rows = (len(indices) + per_row - 1) // per_row
    W = per_row * (cell + pad) + pad
    H = rows * (cell + pad + label_h) + pad
    canvas = [[40] * W for _ in range(H)]
    for k, idx in enumerate(indices):
        r, c = divmod(k, per_row)
        x0, y0 = pad + c * (cell + pad), pad + r * (cell + pad + label_h)
        block_img = compose_block(px, cols_in_sheet, ts["blocks"][idx], scale)
        for yy in range(cell):
            for xx in range(cell):
                canvas[y0 + label_h + yy][x0 + xx] = block_img[yy][xx]
        stamp_text(canvas, x0, y0, str(idx) + CAT_LETTERS[ts["categories"][idx]], 255, 40)
    write_png_gray8(out_path, W, H, canvas)
    print(f"wrote {out_path} ({W}x{H}), {len(indices)} blocks" + (f" in category {category!r}" if category else ""))


def cmd_map(tileset_const, blk_path, map_w, x0, y0, rw, rh, out_path, scale=6):
    ts = load_tileset(tileset_const)
    w, h, bd, px = read_png_2bpp_gray(ROOT / ts["pngFile"])
    cols_in_sheet = w // 8
    raw = Path(blk_path).read_bytes()
    map_w = int(map_w)
    grid = [list(raw[y * map_w:(y + 1) * map_w]) for y in range(len(raw) // map_w)]

    cell = 4 * 8 * scale
    W, H = rw * cell, rh * cell
    canvas = [[0] * W for _ in range(H)]
    for ry in range(rh):
        for rx in range(rw):
            bid = grid[y0 + ry][x0 + rx]
            block_img = compose_block(px, cols_in_sheet, ts["blocks"][bid], scale)
            for yy in range(cell):
                for xx in range(cell):
                    canvas[ry * cell + yy][rx * cell + xx] = block_img[yy][xx]
    write_png_gray8(out_path, W, H, canvas)
    print(f"wrote {out_path} ({W}x{H}) from {blk_path} region x{x0}-{x0+rw} y{y0}-{y0+rh}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "blocks":
        _, _, tileset_const, out_path, *rest = sys.argv
        cmd_blocks(tileset_const, out_path, category=rest[0] if rest else None)
    elif cmd == "map":
        _, _, tileset_const, blk_path, map_w, x0, y0, rw, rh, out_path = sys.argv
        cmd_map(tileset_const, blk_path, int(map_w), int(x0), int(y0), int(rw), int(rh), out_path)
    else:
        print(__doc__)
        sys.exit(1)
