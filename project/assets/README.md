# HOTEL — Programmatic Asset Pack

All assets in this directory were generated algorithmically by `generate_assets.py`
located in the project root. They are **placeholders** for the final pixel art.

## Directory Structure

```
assets/
├── README.md                          ← you are here
├── resources/
│   └── tilesets/
│       ├── floor_01_tileset.tres      ← Godot 4 TileSet per floor
│       ├── ...
│       └── floor_09_tileset.tres
└── sprites/
    ├── tiles/
    │   ├── floor_01/                  ← 10 tiles per floor
    │   │   ├── tile_floor.png         (32×32)
    │   │   ├── tile_wall.png          (32×32)
    │   │   ├── tile_corner_ne.png     (32×32)
    │   │   ├── tile_corner_nw.png     (32×32)
    │   │   ├── tile_corner_se.png     (32×32)
    │   │   ├── tile_corner_sw.png     (32×32)
    │   │   ├── tile_door_closed_h.png (32×32)
    │   │   ├── tile_door_closed_v.png (32×32)
    │   │   ├── tile_door_open_h.png   (32×32)
    │   │   └── tile_door_open_v.png   (32×32)
    │   ├── floor_02/
    │   └── ... (through floor_09)
    ├── characters/
    │   ├── player/
    │   │   └── player_idle.png        (96×36, 4 directions side-by-side)
    │   └── enemies/
    │       ├── enemy_staff.png        (16×24)
    │       ├── enemy_guard.png        (16×24)
    │       └── ... (21 types total)
    └── weapons/
        ├── weapon_machete.png         (12×12)
        └── ... (15 types total)
```

## How to Replace with Real Art

### Tilesets (tiles/)
1. Replace each `tile_*.png` with the final pixel art of the **same dimensions** (32×32).
2. Keep the exact filenames — the `.tres` TileSet resources reference them by path.
3. In Godot, select each texture → Import tab → set **Filter = Nearest**, **Mipmaps = Off**.

### Player sprite sheet
- `player_idle.png` is 96×36 (4 frames of 24×36 side by side).
- Replace with proper sprite sheet keeping the same layout.
- Final art should follow the Art Bible: 24×36 per frame, 3/4 top-down view.

### Enemy sprites
- Each enemy is a single 16×24 (or 16×16 for vault_drone) frame.
- For production, expand to sprite sheets following the naming convention in
  `docs/10_ART_BIBLE.md` section 10.2.
- Color modulate per-floor using the enemy_tint values from palettes.

### Weapon icons
- 12×12 placeholder shapes. Replace with proper pixel art per
  `docs/12_WEAPON_DESIGN.md` section 7.1 specs.

### TileSet resources (.tres)
- Each `floor_XX_tileset.tres` maps the 10 tiles for that floor.
- After replacing art, re-open in Godot editor and verify:
  - Physics polygons on walls and closed doors (layer 7 = environment).
  - Terrain sets for auto-tiling (wall / floor terrains).
- You may want to regenerate or edit these after final tile dimensions are locked.

## Regenerating Placeholders

```bash
python3 generate_assets.py
```

Requires: Python 3 + Pillow (`pip install Pillow`).

## Palettes Source

All colors come from `docs/10_ART_BIBLE.md` section 4.2 (Per-Floor Palettes).
Floor 9 uses Phase 1 palette (sterile white) as default.
