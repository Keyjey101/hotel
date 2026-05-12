#!/usr/bin/env python3
"""
Programmatic Asset Generator for HOTEL — Godot 4 roguelike.
Generates placeholder PNG sprites + Godot .tres TileSets.
"""
from PIL import Image, ImageDraw
from pathlib import Path
import os

BASE = Path("/home/kj/hotel/project/assets/sprites")
RES  = Path("/home/kj/hotel/project/assets/resources/tilesets")

# ── Floor palettes from ART_BIBLE.md ──────────────────────────────────

FLOORS = [
    {  # Floor 1 — Service Underground
        "name": "floor_01", "theme": "Service Underground",
        "colors": ["#2A2A2E", "#4A4A3E", "#7A5A2E", "#8A7A5A"],
        "bg": "#1A1A1E", "blood": "#CC2222", "enemy_tint": "#6A5A4A",
    },
    {  # Floor 2 — Lust / Red Light
        "name": "floor_02", "theme": "Lust / Red Light",
        "colors": ["#8B0035", "#FF1A6D", "#0A0A0F", "#FF6EB4"],
        "bg": "#150008", "blood": "#990022", "enemy_tint": "#CC3377",
    },
    {  # Floor 3 — Gluttony / Banquet
        "name": "floor_03", "theme": "Gluttony / Banquet",
        "colors": ["#B8860B", "#6B0020", "#556B2F", "#FFE4B5"],
        "bg": "#2A1508", "blood": "#AA0020", "enemy_tint": "#8B6914",
    },
    {  # Floor 4 — Greed / Vault
        "name": "floor_04", "theme": "Greed / Vault",
        "colors": ["#FFD700", "#5A6A7A", "#1A1A3A", "#C0C8D0"],
        "bg": "#0E0E1E", "blood": "#CC2222", "enemy_tint": "#5A6A8A",
    },
    {  # Floor 5 — Sloth / Spa
        "name": "floor_05", "theme": "Sloth / Spa",
        "colors": ["#3CBEB0", "#E8F0F0", "#8AABA0", "#B8D8D0"],
        "bg": "#D0E0E0", "blood": "#AA2222", "enemy_tint": "#6A9A8A",
    },
    {  # Floor 6 — Wrath / Arena
        "name": "floor_06", "theme": "Wrath / Arena",
        "colors": ["#CC1100", "#B74A0E", "#1A0A0A", "#FF5500"],
        "bg": "#0F0505", "blood": "#EE0000", "enemy_tint": "#8B2500",
    },
    {  # Floor 7 — Envy / Observatory
        "name": "floor_07", "theme": "Envy / Observatory",
        "colors": ["#1A1A6A", "#C0C0D0", "#4B0082", "#E6E6FA"],
        "bg": "#0A0A2A", "blood": "#CC2222", "enemy_tint": "#6A5A8A",
    },
    {  # Floor 8 — Pride / Ballroom
        "name": "floor_08", "theme": "Pride / Ballroom",
        "colors": ["#DAA520", "#F5F5F0", "#8B0000", "#2A2A2A"],
        "bg": "#1A1A1A", "blood": "#DD0000", "enemy_tint": "#2A2A3A",
    },
    {  # Floor 9 — Satan's Sanctum (Phase 1)
        "name": "floor_09", "theme": "Satan's Sanctum",
        "colors": ["#F0F0F0", "#E0E0E0", "#1A0A0A", "#AA0000"],
        "bg": "#0A0A0A", "blood": "#CC2222", "enemy_tint": "#880000",
    },
]

def hex2rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def darker(hex_color, factor=0.6):
    r, g, b = hex2rgb(hex_color)
    return (int(r*factor), int(g*factor), int(b*factor))

def lighter(hex_color, factor=1.3):
    r, g, b = hex2rgb(hex_color)
    return (min(255, int(r*factor)), min(255, int(g*factor)), min(255, int(b*factor)))

# ── Tile generation helpers ────────────────────────────────────────────

def make_tile(size, fill, border_color, border_w=1):
    """Solid fill rectangle with border."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, size-1, size-1], fill=border_color)
    d.rectangle([border_w, border_w, size-1-border_w, size-1-border_w], fill=fill)
    return img

def make_floor_tile(palette):
    """32x32 floor tile: color1 fill + color2 border 1px."""
    c1 = hex2rgb(palette["colors"][0])
    c2 = hex2rgb(palette["colors"][1])
    # Add subtle noise pattern
    img = make_tile(32, c1, c2, border_w=1)
    d = ImageDraw.Draw(img)
    # Add 4 subtle dots for texture
    for x in range(4, 28, 8):
        for y in range(4, 28, 8):
            d.point((x + (y % 4), y + (x % 4)), fill=darker(palette["colors"][0], 0.85))
    return img

def make_wall_tile(palette):
    """32x32 wall tile: color2 fill + darker border."""
    c2 = hex2rgb(palette["colors"][1])
    border = darker(palette["colors"][1], 0.5)
    img = make_tile(32, c2, border, border_w=1)
    d = ImageDraw.Draw(img)
    # Horizontal line accent at 1/3
    y = 10
    d.line([(2, y), (29, y)], fill=darker(palette["colors"][1], 0.7), width=1)
    d.line([(2, y+1), (29, y+1)], fill=lighter(palette["colors"][1], 1.1), width=1)
    return img

def make_corner_tile(palette, ne=False, nw=False, se=False, sw=False):
    """32x32 corner tile with L-shaped border."""
    c1 = hex2rgb(palette["colors"][0])
    c2 = hex2rgb(palette["colors"][1])
    border = darker(palette["colors"][1], 0.5)
    img = Image.new("RGBA", (32, 32), c1)
    d = ImageDraw.Draw(img)
    # Draw L-shape border
    if nw:
        d.rectangle([0, 0, 1, 31], fill=border)
        d.rectangle([0, 0, 31, 1], fill=border)
    if ne:
        d.rectangle([30, 0, 31, 31], fill=border)
        d.rectangle([0, 0, 31, 1], fill=border)
    if sw:
        d.rectangle([0, 0, 1, 31], fill=border)
        d.rectangle([0, 30, 31, 31], fill=border)
    if se:
        d.rectangle([30, 0, 31, 31], fill=border)
        d.rectangle([0, 30, 31, 31], fill=border)
    # Fill inner corner with wall color
    fill_size = 10
    if nw:
        d.rectangle([0, 0, fill_size, fill_size], fill=c2)
    if ne:
        d.rectangle([31-fill_size, 0, 31, fill_size], fill=c2)
    if sw:
        d.rectangle([0, 31-fill_size, fill_size, 31], fill=c2)
    if se:
        d.rectangle([31-fill_size, 31-fill_size, 31, 31], fill=c2)
    return img

def make_door_tile(palette, closed=True, horizontal=False):
    """32x32 door tile."""
    c_wall = hex2rgb(palette["colors"][1])
    c_accent = hex2rgb(palette["colors"][3]) if len(palette["colors"]) > 3 else lighter(palette["colors"][0])
    c_door = darker(palette["colors"][2], 0.8) if len(palette["colors"]) > 2 else hex2rgb(palette["colors"][0])
    img = Image.new("RGBA", (32, 32), c_wall)
    d = ImageDraw.Draw(img)

    if horizontal:
        if closed:
            d.rectangle([2, 12, 29, 19], fill=c_door)
            d.rectangle([2, 12, 29, 19], outline=c_accent, width=1)
            d.ellipse([24, 14, 27, 17], fill=c_accent)  # knob
        else:
            d.rectangle([2, 12, 14, 19], fill=c_door)
            d.rectangle([2, 12, 14, 19], outline=c_accent, width=1)
            # Opening
            d.rectangle([15, 12, 29, 19], fill=hex2rgb(palette["bg"]))
    else:
        if closed:
            d.rectangle([12, 2, 19, 29], fill=c_door)
            d.rectangle([12, 2, 19, 29], outline=c_accent, width=1)
            d.ellipse([14, 24, 17, 27], fill=c_accent)  # knob
        else:
            d.rectangle([12, 2, 19, 14], fill=c_door)
            d.rectangle([12, 2, 19, 14], outline=c_accent, width=1)
            d.rectangle([12, 15, 19, 29], fill=hex2rgb(palette["bg"]))
    return img

# ── Character generation ───────────────────────────────────────────────

def make_player_frame(direction):
    """24x36 player silhouette for given direction. Returns single frame."""
    img = Image.new("RGBA", (24, 36), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    black = (20, 20, 25, 255)
    red = (200, 40, 40, 255)

    if direction == "down":
        # Head
        d.ellipse([8, 1, 15, 7], fill=black, outline=red)
        # Neck
        d.rectangle([10, 7, 13, 9], fill=black)
        # Body
        d.rectangle([7, 9, 16, 22], fill=black, outline=red)
        # Arms
        d.rectangle([3, 10, 7, 19], fill=black, outline=red)
        d.rectangle([16, 10, 20, 19], fill=black, outline=red)
        # Legs
        d.rectangle([8, 22, 11, 33], fill=black, outline=red)
        d.rectangle([12, 22, 15, 33], fill=black, outline=red)
    elif direction == "up":
        # Head (back view)
        d.ellipse([8, 1, 15, 7], fill=black, outline=red)
        d.rectangle([10, 7, 13, 9], fill=black)
        d.rectangle([7, 9, 16, 22], fill=black, outline=red)
        d.rectangle([3, 10, 7, 19], fill=black, outline=red)
        d.rectangle([16, 10, 20, 19], fill=black, outline=red)
        d.rectangle([8, 22, 11, 33], fill=black, outline=red)
        d.rectangle([12, 22, 15, 33], fill=black, outline=red)
    elif direction == "left":
        # Side view — narrower
        d.ellipse([7, 1, 14, 7], fill=black, outline=red)
        d.rectangle([9, 7, 12, 9], fill=black)
        d.rectangle([8, 9, 14, 22], fill=black, outline=red)
        # One arm visible
        d.rectangle([5, 10, 8, 19], fill=black, outline=red)
        d.rectangle([8, 22, 11, 33], fill=black, outline=red)
        d.rectangle([11, 22, 14, 33], fill=black, outline=red)
    elif direction == "right":
        d.ellipse([9, 1, 16, 7], fill=black, outline=red)
        d.rectangle([11, 7, 14, 9], fill=black)
        d.rectangle([9, 9, 15, 22], fill=black, outline=red)
        d.rectangle([15, 10, 18, 19], fill=black, outline=red)
        d.rectangle([9, 22, 12, 33], fill=black, outline=red)
        d.rectangle([12, 22, 15, 33], fill=black, outline=red)

    return img

def make_player_sheet():
    """4 directions × 1 frame = sprite sheet 96×36."""
    dirs = ["down", "up", "left", "right"]
    frames = [make_player_frame(d) for d in dirs]
    sheet = Image.new("RGBA", (24 * 4, 36), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        sheet.paste(f, (i * 24, 0))
    return sheet

# ── Enemy generation ───────────────────────────────────────────────────

ENEMY_TYPES = [
    {"name": "staff",       "size": (16, 24), "base": "#880000", "outline": "#FFFFFF", "desc": "compact hunched"},
    {"name": "guard",       "size": (16, 24), "base": "#AA2200", "outline": "#FFFFFF", "desc": "broad upright"},
    {"name": "handler",     "size": (16, 24), "base": "#660000", "outline": "#FFFFFF", "desc": "bulky long arms"},
    {"name": "butcher",     "size": (16, 24), "base": "#CC3300", "outline": "#FFFFFF", "desc": "wide muscular"},
    {"name": "cultist",     "size": (16, 24), "base": "#5500AA", "outline": "#FFFFFF", "desc": "thin tall robed"},
    {"name": "seductress",  "size": (16, 24), "base": "#CC3377", "outline": "#FFFFFF", "desc": "elegant thin"},
    {"name": "bodyguard",   "size": (16, 24), "base": "#333355", "outline": "#FFFFFF", "desc": "large imposing"},
    {"name": "chef",        "size": (16, 24), "base": "#DDAA00", "outline": "#FFFFFF", "desc": "round massive"},
    {"name": "taster",      "size": (16, 24), "base": "#44AA44", "outline": "#FFFFFF", "desc": "thin bloated"},
    {"name": "banker",      "size": (16, 24), "base": "#445566", "outline": "#FFFFFF", "desc": "thin sharp"},
    {"name": "vault_drone", "size": (16, 16), "base": "#889999", "outline": "#00FFFF", "desc": "round metallic"},
    {"name": "attendant",   "size": (16, 24), "base": "#6A9A8A", "outline": "#FFFFFF", "desc": "soft relaxed"},
    {"name": "drowned_one", "size": (16, 24), "base": "#5588AA", "outline": "#FFFFFF", "desc": "bloated pale"},
    {"name": "gladiator",   "size": (16, 24), "base": "#BB4400", "outline": "#FFFFFF", "desc": "muscular armored"},
    {"name": "berserker",   "size": (16, 24), "base": "#DD0000", "outline": "#FFFF00", "desc": "wild scarred"},
    {"name": "spy",         "size": (16, 24), "base": "#333344", "outline": "#FF0000", "desc": "thin minimal"},
    {"name": "shadow_stalker", "size": (16, 24), "base": "#2A0044", "outline": "#AA44FF", "desc": "amorphous dark"},
    {"name": "royal_guard", "size": (16, 24), "base": "#DAA520", "outline": "#FFFFFF", "desc": "tall ornate"},
    {"name": "champion",    "size": (16, 24), "base": "#CC0000", "outline": "#FFD700", "desc": "largest plated"},
    {"name": "demon",       "size": (16, 24), "base": "#220000", "outline": "#FF0000", "desc": "inhuman tall"},
    {"name": "the_sister",  "size": (16, 24), "base": "#EEEEFF", "outline": "#FF4488", "desc": "ethereal pale"},
]

def make_enemy_sprite(et):
    """Generate a single enemy sprite."""
    w, h = et["size"]
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    base = hex2rgb(et["base"])
    outline = hex2rgb(et["outline"])

    # Body rectangle
    bw = w - 4  # body width
    bh = h - 8  # body height
    bx = 2
    by = 4
    d.rectangle([bx, by, bx+bw-1, by+bh-1], fill=base, outline=outline)

    # Head (small square on top)
    hw = max(4, w // 2)
    hh = 4
    hx = (w - hw) // 2
    d.rectangle([hx, 0, hx+hw-1, hh], fill=base, outline=outline)

    # Eyes (2 pixels)
    if hw >= 6:
        eye_y = 1
        d.point((hx+1, eye_y), fill=outline)
        d.point((hx+hw-2, eye_y), fill=outline)

    return img

# ── Weapon generation ──────────────────────────────────────────────────

WEAPONS = [
    {"name": "machete",    "shape": "line",     "color": "#AAAAAA"},
    {"name": "knife",      "shape": "line_thin","color": "#CCCCCC"},
    {"name": "axe",        "shape": "axe",      "color": "#886644"},
    {"name": "bat",        "shape": "line_thick","color": "#886633"},
    {"name": "cult_blade", "shape": "line",     "color": "#AA00FF"},
    {"name": "sawed_off",  "shape": "rect",     "color": "#666666"},
    {"name": "pistol",     "shape": "rect_sm",  "color": "#555555"},
    {"name": "smg",        "shape": "rect",     "color": "#444444"},
    {"name": "shotgun",    "shape": "rect_long","color": "#664422"},
    {"name": "cult_pistol","shape": "rect_sm",  "color": "#AA0088"},
    {"name": "bottle",     "shape": "bottle",   "color": "#AA8833"},
    {"name": "chair",      "shape": "chair",    "color": "#886633"},
    {"name": "severed_limb","shape": "limb",    "color": "#CC2222"},
    {"name": "wire",       "shape": "line_thin","color": "#888888"},
    {"name": "cult_relic", "shape": "diamond",  "color": "#FF4400"},
]

def make_weapon_icon(wdef):
    """Generate 12x12 weapon icon."""
    img = Image.new("RGBA", (12, 12), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = hex2rgb(wdef["color"])
    shape = wdef["shape"]

    if shape == "line":
        d.line([(2, 6), (9, 6)], fill=c, width=2)
        d.line([(2, 6), (2, 8)], fill=darker(wdef["color"], 0.7), width=2)  # handle
    elif shape == "line_thin":
        d.line([(1, 6), (10, 6)], fill=c, width=1)
        d.point((1, 6), fill=lighter(wdef["color"]))  # glint
    elif shape == "line_thick":
        d.line([(1, 6), (10, 6)], fill=c, width=3)
    elif shape == "axe":
        d.line([(2, 6), (8, 6)], fill=darker(wdef["color"], 0.6), width=2)
        d.rectangle([7, 3, 10, 8], fill=c)
    elif shape == "rect":
        d.rectangle([2, 4, 9, 7], fill=c)
        d.rectangle([1, 5, 2, 6], fill=darker(wdef["color"], 0.6))
    elif shape == "rect_sm":
        d.rectangle([3, 4, 8, 7], fill=c)
        d.rectangle([2, 5, 3, 6], fill=darker(wdef["color"], 0.6))
    elif shape == "rect_long":
        d.rectangle([1, 4, 10, 7], fill=c)
        d.rectangle([5, 3, 7, 8], fill=darker(wdef["color"], 0.8))
    elif shape == "bottle":
        d.rectangle([4, 2, 7, 4], fill=c)
        d.rectangle([3, 4, 8, 9], fill=c)
    elif shape == "chair":
        d.rectangle([3, 1, 4, 10], fill=c)  # back
        d.rectangle([2, 5, 9, 6], fill=c)    # seat
        d.line([(3, 6), (3, 10)], fill=c, width=1)  # legs
        d.line([(8, 6), (8, 10)], fill=c, width=1)
    elif shape == "limb":
        d.rectangle([4, 1, 7, 3], fill=c)   # hand
        d.rectangle([5, 3, 6, 10], fill=c)   # arm
        d.rectangle([4, 9, 7, 11], fill=(180, 0, 0))  # stump
    elif shape == "diamond":
        d.polygon([(6, 1), (10, 6), (6, 11), (2, 6)], fill=c)
        d.polygon([(6, 3), (8, 6), (6, 9), (4, 6)], fill=lighter(wdef["color"]))

    return img

# ── TileSet .tres generation ───────────────────────────────────────────

def make_tileset_tres(floor_data):
    """Generate a Godot 4 .tres TileSet resource."""
    name = floor_data["name"]

    # Collect PNG paths (relative to project root)
    tiles_dir = f"assets/sprites/tiles/{name}"
    pngs = {
        "floor": f"{tiles_dir}/tile_floor.png",
        "wall":  f"{tiles_dir}/tile_wall.png",
        "corner_ne": f"{tiles_dir}/tile_corner_ne.png",
        "corner_nw": f"{tiles_dir}/tile_corner_nw.png",
        "corner_se": f"{tiles_dir}/tile_corner_se.png",
        "corner_sw": f"{tiles_dir}/tile_corner_sw.png",
        "door_closed_h": f"{tiles_dir}/tile_door_closed_h.png",
        "door_closed_v": f"{tiles_dir}/tile_door_closed_v.png",
        "door_open_h": f"{tiles_dir}/tile_door_open_h.png",
        "door_open_v": f"{tiles_dir}/tile_door_open_v.png",
    }

    # Build .tres content — Godot 4 TileSet format
    tres = '[gd_resource type="TileSet" format=3]\n\n'
    tres += '[resource]\n'
    tres += f'tile_size = Vector2i(32, 32)\n'
    tres += 'rendering_uv_flip_texture = false\n'

    # Physics layer for collisions (layer 7 = environment)
    tres += 'physics_layer_0/collision_layer = 128\n'  # 2^7 = 128

    # Terrain set for walls
    tres += 'terrain_set_0/mode = 0\n'  # Tile match mode
    tres += 'terrain_set_0/terrain_0/name = "wall"\n'
    tres += 'terrain_set_0/terrain_0/color = Color(0.5, 0.5, 0.5, 1)\n'
    tres += 'terrain_set_0/terrain_1/name = "floor"\n'
    tres += 'terrain_set_0/terrain_1/color = Color(0.3, 0.6, 0.3, 1)\n'

    # Source atlas — we use individual scenes as separate sources
    for i, (key, path) in enumerate(pngs.items()):
        source_id = i
        tres += f'\n[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_{source_id}"]\n'
        tres += f'texture = ExtResource("res://{path}")\n'
        tres += f'texture_region_size = Vector2i(32, 32)\n'
        tres += f'0:0/0 = 0\n'
        # Physics for walls and closed doors
        if "wall" in key or ("door_closed" in key):
            tres += f'0:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-16, -16, 16, -16, 16, 16, -16, 16)\n'
        tres += f'\n'

    # Add all sources
    for i in range(len(pngs)):
        tres += f'sources/{i} = SubResource("TileSetAtlasSource_{i}")\n'

    return tres


# ── MAIN: generate everything ──────────────────────────────────────────

def main():
    print("=== HOTEL Asset Generator ===\n")

    # ── 1. Tiles for each floor ──
    for floor in FLOORS:
        d = BASE / "tiles" / floor["name"]
        d.mkdir(parents=True, exist_ok=True)
        print(f"  Generating tiles for {floor['name']} ({floor['theme']})...")

        make_floor_tile(floor).save(d / "tile_floor.png")
        make_wall_tile(floor).save(d / "tile_wall.png")

        for corner, args in [("ne", dict(ne=True)), ("nw", dict(nw=True)),
                             ("se", dict(se=True)), ("sw", dict(sw=True))]:
            make_corner_tile(floor, **args).save(d / f"tile_corner_{corner}.png")

        # Doors: horizontal & vertical, open & closed
        make_door_tile(floor, closed=True,  horizontal=False).save(d / "tile_door_closed_v.png")
        make_door_tile(floor, closed=False, horizontal=False).save(d / "tile_door_open_v.png")
        make_door_tile(floor, closed=True,  horizontal=True).save(d / "tile_door_closed_h.png")
        make_door_tile(floor, closed=False, horizontal=True).save(d / "tile_door_open_h.png")

    print(f"  -> 9 floors × 10 tiles = 90 PNG files\n")

    # ── 2. Player sprite sheet ──
    print("  Generating player sprite sheet...")
    player_dir = BASE / "characters" / "player"
    player_dir.mkdir(parents=True, exist_ok=True)
    make_player_sheet().save(player_dir / "player_idle.png")
    print("  -> player_idle.png (96×36, 4 directions)\n")

    # ── 3. Enemy sprites ──
    print("  Generating enemy sprites...")
    enemy_dir = BASE / "characters" / "enemies"
    enemy_dir.mkdir(parents=True, exist_ok=True)

    for et in ENEMY_TYPES:
        sprite = make_enemy_sprite(et)
        sprite.save(enemy_dir / f"enemy_{et['name']}.png")
    print(f"  -> {len(ENEMY_TYPES)} enemy sprites\n")

    # ── 4. Weapon icons ──
    print("  Generating weapon icons...")
    wpn_dir = BASE / "weapons"
    wpn_dir.mkdir(parents=True, exist_ok=True)

    for wdef in WEAPONS:
        icon = make_weapon_icon(wdef)
        icon.save(wpn_dir / f"weapon_{wdef['name']}.png")
    print(f"  -> {len(WEAPONS)} weapon icons\n")

    # ── 5. TileSet .tres resources ──
    print("  Generating Godot TileSet resources...")
    RES.mkdir(parents=True, exist_ok=True)

    for floor in FLOORS:
        tres_path = RES / f"{floor['name']}_tileset.tres"
        tres_content = make_tileset_tres(floor)
        tres_path.write_text(tres_content)
    print(f"  -> 9 .tres TileSet files\n")

    # ── Summary ──
    total = 90 + 1 + len(ENEMY_TYPES) + len(WEAPONS) + 9
    print(f"=== Done: {total} files generated ===")


if __name__ == "__main__":
    main()
