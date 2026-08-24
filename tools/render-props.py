#!/usr/bin/env python3
"""Render bar-lane prop sprites for Pebble (pixel art, theme-fixed colors)."""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "props"

# Fixed palette — soft-shaded like the 56×34 penguin frames.
PALETTE = {
    ".": (0, 0, 0, 0),
    "K": (26, 32, 44, 255),
    "k": (40, 48, 62, 255),
    # pebble / cannonball
    "p": (74, 78, 84, 255),
    "P": (106, 112, 120, 255),
    "H": (154, 160, 168, 255),
    "h": (186, 192, 200, 255),
    "x": (58, 62, 68, 255),
    # leaf / umbrella
    "g": (45, 120, 58, 255),
    "G": (78, 160, 92, 255),
    "L": (126, 210, 140, 255),
    "l": (168, 232, 176, 255),
    "s": (34, 78, 42, 255),
    "v": (52, 108, 62, 255),
    # star / flag
    "y": (160, 120, 10, 255),
    "Y": (224, 176, 32, 255),
    "W": (255, 244, 160, 255),
    "r": (255, 220, 96, 255),
    "R": (196, 48, 42, 255),
    "A": (255, 236, 210, 255),
    # fire / flash
    "f": (255, 80, 32, 255),
    "F": (255, 140, 42, 255),
    "w": (255, 209, 102, 255),
    "e": (255, 56, 24, 255),
    # line / bobber / puddle / rod
    "i": (190, 194, 200, 255),
    "b": (230, 72, 52, 255),
    "B": (255, 110, 72, 255),
    "t": (255, 236, 220, 255),
    "u": (72, 132, 196, 255),
    "U": (120, 176, 228, 255),
    "n": (52, 92, 140, 255),
    "a": (168, 210, 244, 255),
    # cannon + carriage wood
    "c": (48, 48, 48, 255),
    "C": (92, 92, 92, 255),
    "m": (140, 140, 140, 255),
    "M": (178, 178, 178, 255),
    "j": (32, 32, 32, 255),
    "J": (68, 68, 68, 255),
    "z": (24, 24, 24, 255),
    "1": (88, 58, 34, 255),
    "2": (130, 86, 52, 255),
    "3": (168, 118, 72, 255),
    # bubble / dots / rain
    "d": (220, 228, 236, 255),
    "D": (180, 190, 204, 255),
    "o": (255, 255, 255, 180),
    "q": (140, 152, 168, 255),
    "4": (160, 190, 220, 255),
}

PROPS: dict[str, list[str]] = {
    "pebble": [
        "..............",
        "..kkkkkkkk....",
        ".kPPPPPPPPk...",
        "kPHhPPPPPHPk..",
        "kPPpxxxPPPPk..",
        "kPPpxxxPPPPk..",
        "kPHHPPPPPHPk..",
        ".kPPPPPPPPk...",
        "..kkkkkkkk....",
        "..............",
    ],
    "leaf": [
        "....gggg....",
        "...gGGGg....",
        "..gGLLLGg...",
        "..gGLvLGg...",
        "..gGLsLGg...",
        "...gGGGg....",
        "....ggg.....",
        ".....s......",
        ".....k......",
    ],
    "leaf-hat": [
        "....gggGGgg....",
        "...gGLLLLGg...",
        "..gGLLlllLGg..",
        "..gGLLlllLGg..",
        "...gGsGGsGg...",
        "....ss.ss.....",
        ".....k..k.....",
    ],
    "umbrella": [
        "...gggGGGggg...",
        "..gGLLLLLLLGg..",
        ".gGLLllllllLGg.",
        ".gGLLllllllLGg.",
        "..gGLLLLLLLGg..",
        "...ggg...ggg...",
        "......iii......",
        "......iii......",
        "......k........",
    ],
    "rain-drop": [
        "..k4k..",
        ".k4444k",
        "k444444k",
        "k444444k",
        ".k4444k",
        "..k4k..",
    ],
    "parade-flag": [
        "...kRk...",
        "..kRYRk..",
        ".kRYYYRk.",
        "kRYYYYRk.",
        "kRYYYYRk.",
        ".kRYYYRk.",
        "..kRYRk..",
        "...kRk...",
        "....i....",
        "....i....",
        "....i....",
        "....k....",
    ],
    "star": [
        "......W......",
        ".....YwY.....",
        "......Y......",
        "....YryyY....",
        "W..YryyyY..W",
        ".YryyyyyyY.",
        "..YryyyyY..",
        "....YryY....",
        ".....Y.Y.....",
    ],
    "firefly": [
        "....kk....",
        "...kwwk...",
        "..kwwwwk..",
        "..kwFeFk..",
        "..kwwwwk..",
        "...kwwk...",
        "....kk....",
    ],
    "bobber": [
        "..k..",
        "..t..",
        "..i..",
        "..i..",
        "..i..",
        "..i..",
        ".kBk.",
        "kBBBk",
        "kBbBk",
        ".kkk.",
    ],
    "fishing-rod": [
        ".......k.",
        "......ki.",
        ".....ki..",
        "....ki...",
        "...ki....",
        "..ki.....",
        ".ki......",
        "ki.......",
        ".k222k...",
        ".k2332k..",
        "..k222k..",
    ],
    "bang": [
        "..k....k....",
        ".kfwk.kfwk..",
        "..kwfwfwk...",
        "kfwfffffwk..",
        "..kwfwfwk...",
        ".kfwk.kfwk..",
        "..k....k....",
    ],
    "dots": [
        "k.k.k.k.k.k.",
        ".dqdqdqdqdqd",
        "k.k.k.k.k.k.",
    ],
    "bubble": [
        "..kkkkkk..",
        ".kDooooDk.",
        "kDo....ok",
        "kDo..q.ok",
        "kDo....ok",
        ".kDooooDk.",
        "..kkkkkk..",
    ],
    "puddle": [
        "....nnnnnnnnnnnnnn....",
        "..nnuuuuuuuuuuuuun..",
        ".nuUUUUUUUUUUUUUUn.",
        ".nuUUaUUUUUUaUUUUn.",
        "..nnuuuuuuuuuuuuun..",
        "....nnnnnnnnnnnnnn....",
    ],
    # Side-view cannon — tall barrel (left=breech, right=muzzle hole), round wheels.
    "cannon": [
        "........kkkkkkkkkkkkkk......",
        "......kCmmmmmmmmmmCkk.......",
        ".....kCmmmmMmmmmMmmCk.......",
        ".....kCmmmmmmmmmmmmCk.......",
        ".....kCmmmmmmmmmmmmCk.......",
        ".....kCmmmmmmmmmmmmCk.......",
        "......kCmmmmmmmmmmCk........",
        ".......kCjjjjjjjjCk.........",
        "......k22222222222k........",
        "....kJkkkkkkkkkkkkJk.......",
        "...kJmMmMJk......kJmMmMJk....",
        "...kJmMmMJk......kJmMmMJk....",
        "...kJmMmMJk......kJmMmMJk....",
        "...kJzMzMJk......kJzMzMJk....",
        "...kzzJzJk......kJzJzzk....",
        "....kJJk........kJJk.......",
    ],
    "cannonball": [
        "...kkkk...",
        "..kPHHPk..",
        ".kPHhhHPk.",
        "kPHhxxhHPk",
        "kPHhxxhHPk",
        ".kPHhhHPk.",
        "..kPHHPk..",
        "...kkkk...",
    ],
    "flash": [
        "..k....k..",
        ".kewk.kewk",
        "..kwewewk.",
        "kewffffewk",
        "..kwewewk.",
        ".kewk.kewk",
        "..k....k..",
    ],
    "gate-post": [
        "..kk",
        ".kKk",
        ".kKk",
        ".kKk",
        ".kKk",
        ".kKk",
        ".kKk",
        "..kk",
    ],
    "gate-flame": [
        "..kkkkkk..",
        ".kFwwwwFk.",
        "kFwefefwFk",
        "kFwefefwFk",
        ".kFwwwwFk.",
        "..kkkkkk..",
    ],
}


def grid_to_rgba(rows: list[str]) -> tuple[int, int, list[tuple[int, int, int, int]]]:
    height = len(rows)
    width = max(len(r) for r in rows)
    pixels: list[tuple[int, int, int, int]] = []
    for row in rows:
        padded = row.ljust(width, ".")
        for ch in padded:
            if ch not in PALETTE:
                raise ValueError(f"Unknown palette key {ch!r} in row {row!r}")
            pixels.append(PALETTE[ch])
    return width, height, pixels


def write_png(path: Path, width: int, height: int, pixels: list[tuple[int, int, int, int]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            r, g, b, a = pixels[y * width + x]
            raw.extend((r, g, b, a))

    def chunk(tag: bytes, data: bytes) -> bytes:
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")
    path.write_bytes(png)


def main() -> None:
    manifest: list[str] = []
    for name, rows in PROPS.items():
        width, height, pixels = grid_to_rgba(rows)
        out = OUT / f"{name}.png"
        write_png(out, width, height, pixels)
        manifest.append(f"{name}.png {width}x{height}")
        print(f"wrote {out.relative_to(ROOT)} ({width}x{height})")
    (OUT / "README.txt").write_text(
        "Bar-lane prop sprites for Pebble.\n"
        "Regenerate: tools/render-props.py\n\n" + "\n".join(manifest) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
