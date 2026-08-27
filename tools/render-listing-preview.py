#!/usr/bin/env python3
"""Compose marketplace preview.png from Pebble's shipped animation frames.

No desktop capture. Nearest-neighbor scale so the 56x34 pixel art stays sharp.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PENGUIN = ROOT / "assets" / "species" / "penguin"
PREVIEW = ROOT / "preview.png"
HERO = ROOT / "docs" / "media" / "pebble-on-bar.png"
FONT = "/usr/share/fonts/noto/NotoSans-Medium.ttf"
FONT_REG = "/usr/share/fonts/noto/NotoSans-Regular.ttf"

CANVAS_W, CANVAS_H = 1920, 1080
BG = "#16161e"
BAR = "#1a1b26"
TEXT = "#c0caf5"
MUTED = "#7a83a8"
SCALE = 6  # 56x34 → 336x204

# Runtime frames, labeled as the action they represent.
POSES: list[tuple[str, Path]] = [
    ("sleeps", PENGUIN / "sleep-loop" / "1.png"),
    ("waddles", PENGUIN / "walk" / "2.png"),
    ("looks", PENGUIN / "idle-actions" / "2.png"),
    ("preens", PENGUIN / "idle-actions" / "6.png"),
    ("slides", PENGUIN / "slide" / "4.png"),
    ("slips", PENGUIN / "slip" / "4.png"),
    ("wakes", PENGUIN / "wake" / "3.png"),
    ("sets off", PENGUIN / "start" / "2.png"),
]


def magick(*args: str) -> None:
    subprocess.run(["magick", *args], check=True)


def scaled(src: Path, dest: Path, factor: int) -> None:
    magick(str(src), "-filter", "point", "-resize", f"{factor * 100}%", str(dest))


def render(out: Path) -> None:
    if not Path(FONT).is_file():
        raise SystemExit(f"FAIL: missing font {FONT}")
    for _label, path in POSES:
        if not path.is_file():
            raise SystemExit(f"FAIL: missing frame {path}")

    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="pebble-preview-") as raw:
        tmp = Path(raw)
        cells: list[Path] = []
        for index, (label, path) in enumerate(POSES):
            big = tmp / f"pose-{index}.png"
            cell = tmp / f"cell-{index}.png"
            scaled(path, big, SCALE)
            magick(
                "-size",
                "420x280",
                f"xc:{BAR}",
                big,
                "-gravity",
                "center",
                "-geometry",
                "+0-12",
                "-composite",
                "-font",
                FONT_REG,
                "-pointsize",
                "22",
                "-fill",
                MUTED,
                "-gravity",
                "south",
                "-annotate",
                "+0+16",
                label,
                str(cell),
            )
            cells.append(cell)

        grid = tmp / "grid.png"
        magick(
            "montage",
            *[str(cell) for cell in cells],
            "-tile",
            "4x2",
            "-geometry",
            "420x280+16+16",
            "-background",
            BG,
            str(grid),
        )

        blank = tmp / "strip-blank.png"
        magick("-size", "1920x50", f"xc:{BAR}", str(blank))
        magick(
            str(blank),
            "-font",
            FONT_REG,
            "-pointsize",
            "16",
            "-fill",
            MUTED,
            "-gravity",
            "west",
            "-annotate",
            "+24+0",
            "actual size",
            str(tmp / "strip-label.png"),
        )
        strip = tmp / "strip-label.png"
        x = 140
        for index, (_label, path) in enumerate(POSES):
            tiny = tmp / f"tiny-{index}.png"
            scaled(path, tiny, 1)
            placed = tmp / f"strip-{index}.png"
            magick(str(strip), str(tiny), "-geometry", f"+{x}+8", "-composite", str(placed))
            strip = placed
            x += 56 + 12

        header = tmp / "header.png"
        magick(
            "-size",
            f"{CANVAS_W}x200",
            f"xc:{BG}",
            "-font",
            FONT,
            "-pointsize",
            "56",
            "-fill",
            TEXT,
            "-gravity",
            "west",
            "-annotate",
            "+64+18",
            "Pebble",
            "-font",
            FONT_REG,
            "-pointsize",
            "26",
            "-fill",
            MUTED,
            "-annotate",
            "+64+78",
            "a penguin who lives in your Omarchy bar",
            str(header),
        )

        footer = tmp / "footer.png"
        magick(
            "-size",
            f"{CANVAS_W}x72",
            f"xc:{BG}",
            "-font",
            FONT_REG,
            "-pointsize",
            "20",
            "-fill",
            MUTED,
            "-gravity",
            "west",
            "-annotate",
            "+64+0",
            "entirely local  ·  no network  ·  quiet unless you poke him",
            str(footer),
        )

        magick(
            str(header),
            str(strip),
            str(grid),
            str(footer),
            "-background",
            BG,
            "-gravity",
            "west",
            "-append",
            "-gravity",
            "north",
            "-background",
            BG,
            "-extent",
            f"{CANVAS_W}x{CANVAS_H}",
            "+repage",
            "-depth",
            "8",
            str(out),
        )


def main() -> None:
    render(PREVIEW)
    HERO.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(PREVIEW, HERO)
    info = subprocess.check_output(["identify", str(PREVIEW)], text=True).strip()
    print(info)
    print(f"Wrote {PREVIEW} and {HERO}")


if __name__ == "__main__":
    main()
