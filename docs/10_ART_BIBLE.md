# ART BIBLE — HOTEL
## Version 1.0

---

# 1. TECHNICAL SPECIFICATIONS

## 1.1 Resolution & Viewport

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Tile size | 32×32 px | Standard pixel art, good detail/production balance |
| Viewport | 640×360 px | 20×11.25 tiles visible, clean 16:9, scales well |
| Scale factor | ×2, ×3, ×4 (display) | Crisp on 1080p/1440p/4K |
| Character size | ~24×36 px | Slim, taller than tile, clear limb separation |
| View angle | 3/4 top-down | Like Hotline Miami — see character face + body |
| Directions | 8 | Standard top-down movement + aim |

## 1.2 Grid & Collision

| Element | Grid Size | Notes |
|---------|-----------|-------|
| Floor tile | 32×32 | Square grid |
| Wall tile | 32×48 (or 32×64) | Taller than floor for 3/4 depth |
| Door | 32×64 | 2 tiles wide |
| Character collision | ~16×20 | Smaller than sprite for forgiving movement |
| Projectile | 4-8 px | Small, fast |
| Weapon pickup | ~16×16 | Compact, readable |

---

# 2. CHARACTER DESIGN

## 2.1 Player Character

**Proportions breakdown (3/4 view, facing down):**
```
     ┌─────┐
     │ HEAD│  ~6px height, round, dark hair
     ├──┬──┤
     │  │  │  Neck: 2px
  ┌──┤  │  ├──┐
  │ARM  BODY  ARM│  Torso: ~12px, arms: ~4px wide each, separated from body
  └──┤  │  ├──┘
     │  │  │
     ├──┴──┤
     │LEGS │  Legs: ~10px, visible separation
     └─────┘

Total: ~24px wide × ~36px tall
```

**Key design rules:**
- **Arms are EXAGGERATED** — wider/longer than anatomically correct → losing one is immediately visible
- **Legs separated** — gap between them → losing one changes silhouette dramatically
- **Head distinct** — different color from body, sits on top → headshots readable
- **Silhouette-first design** — even as a dark shape on dark bg, you can read limb states

**Color identity:**
- Player must CONTRAST with all floor palettes
- Warm skin tone or practical clothing (brown, khaki, denim)
- NOT red, NOT gold, NOT neon — the player is NOT part of the hotel
- Machete visible on character when equipped (belt or hand)
- Sawed-off visible on back when not active weapon

**Visual states:**
- Healthy: full sprite
- Hurt: flash white/red, brief stagger animation
- Captured: specific "grappled" pose

## 2.2 Character Limb Readability

**THE CORE RULE:** Enemy state must be readable at a glance without UI.

| Limb State | Visual Indicator | Silhouette Change |
|-----------|------------------|-------------------|
| Healthy | Full limb visible | Normal silhouette |
| Damaged (not severed) | Red flash, wound marks on limb | Same silhouette, color change |
| Severed | **Limb is GONE** — visible stump (short, bloody) | **Clear silhouette change** — missing arm = asymmetric, missing leg = shorter on one side |
| Both arms gone | No arms, torso only, stumps visible | Narrow silhouette, hunched |
| Both legs gone | Only upper body, on ground/crawling | **Dramatic silhouette change** — half height |
| Fully mutilated | Just torso on ground | Minimal silhouette — almost flat |

**Severed stump rules:**
- Stump is 2-3 px, bright red/dark red
- Bleeds briefly after severing (2-3 blood drips)
- Then dries to dark red/brown
- Stump is ALWAYS visible — even at distance, you see the red dot

## 2.3 Enemy Design Principles

**Base enemy visual structure:**
- Same 24×36 base proportions as player
- Each enemy type has DISTINCT silhouette (not just color swap)
- Silhouette should communicate behavior BEFORE you fight them:
  - Staff: slight, hunched, nervous posture
  - Guard: broad, upright, confident
  - Handler: bulky, hunched forward, hands visible
  - etc.

**Floor-themed enemies:**
- Base silhouette + floor-specific details (hat, uniform, accessory)
- Must read clearly against their floor's background palette
- Color comes from floor palette accent colors

**Boss visual rules:**
- Significantly larger than normal enemies (~48×64 or bigger)
- Unique silhouette — never confused with regular enemies
- Visual tells for attack patterns (wind-up poses, glowing elements)
- Damage state changes more dramatic (phases, visual transformation)

---

# 3. ANIMATION SPECIFICATIONS

## 3.1 Frame Counts

| Animation | Frames | Notes |
|-----------|--------|-------|
| Idle | 4-5 | Subtle breathing/bob |
| Walk | 6-8 | Full walk cycle, directional |
| Run | 6-8 | Faster, more leaned |
| Melee attack | 5-7 | Wind-up → swing → follow-through |
| Ranged attack | 4-5 | Aim → fire → recoil → recover |
| Throw | 5-6 | Wind-up → release → follow-through |
| Hurt | 3-4 | Impact → stagger → recover |
| Stun | 4-5 | Dazed wobble |
| Death/capture | 6-8 | Collapse → dragged |
| Mutilated idle | 4-5 | Adapted for missing limbs |
| Mutilated walk | 6-8 | Limping/crawling |
| Mutilated attack | 5-7 | Modified attack with fewer limbs |
| Regeneration | 8-12 | Flesh growing back (per limb) |

## 3.2 Direction System

8 directions → 5 unique sprite sets (3 mirrored):

```
     ↑ (back)
    ↗  ↖
   →    ← (mirror of →)
    ↘  ↙
     ↓ (front)

Unique sets: ↓ (front), ↘ (front-right), → (right), ↗ (back-right), ↑ (back)
Mirrored: ← (mirror →), ↙ (mirror ↘), ↖ (mirror ↗)
```

## 3.3 Animation Production Estimates

| Category | Per Character | Notes |
|----------|---------------|-------|
| Base animations | ~60-80 frames × 5 dirs = 300-400 frames | Walk, idle, attack, hurt, etc. |
| Mutilated variants | ~30-40 frames × 5 dirs = 150-200 frames | Modified base animations |
| Regeneration | ~10 frames × per limb | Shared across enemies |
| **Total per enemy** | **~450-600 frames** | |
| Player | ~500-700 frames | More unique animations |

**Optimization strategies:**
- Modular sprite system: body parts animated separately → reuse across animations
- Mutilated variants: base body + overlay system (remove limb layer = instant variant)
- Shared animation skeletons between similar enemy types
- Regeneration animation: universal per-limb, not per-enemy

---

# 4. COLOR PALETTE SYSTEM

## 4.1 Global Rules

- **Each floor: strict 3-4 dominant colors**
- **Player uses colors NOT found in any floor** (warm browns, khaki, denim blue)
- **Blood is always visible** — adjusted per floor brightness:
  - Dark floors: brighter blood (crimson → scarlet)
  - Light floors: darker blood (crimson → maroon)
- **Enemies use floor accent colors** — blends in thematically but readable via outline/contrast
- **UI always white/gold on dark** — no floor-themed UI colors
- **Readability > Aesthetics** — if something is hard to read, fix the palette, not the player

## 4.2 Per-Floor Palettes

### Floor 1 — Service Underground
```
Dominant colors:
  ██████ #2A2A2E  Dark concrete (walls, floor)
  ██████ #4A4A3E  Dull green-grey (pipes, machinery)
  ██████ #7A5A2E  Rust orange (accents, warning signs)
  ██████ #8A7A5A  Dim brass (light fixtures, handles)

Enemy tint: #6A5A4A (brown-grey uniforms)
Blood: #CC2222 (bright against dark environment)
Background: #1A1A1E (near-black)
```

### Floor 2 — Lust / Red Light District
```
Dominant colors:
  ██████ #8B0035  Deep crimson (walls, curtains)
  ██████ #FF1A6D  Hot pink neon (lights, signs)
  ██████ #0A0A0F  Near-black (shadows, depth)
  ██████ #FF6EB4  Soft pink (accents, silk)

Enemy tint: #CC3377 (magenta uniforms)
Blood: #990022 (darker blood on red environment)
Background: #150008 (deep dark red)
```

### Floor 3 — Gluttony / Banquet Hall
```
Dominant colors:
  ██████ #B8860B  Rich gold (cutlery, chandeliers)
  ██████ #6B0020  Deep burgundy (tablecloths, curtains)
  ██████ #556B2F  Rot green (spoiled food, moss)
  ██████ #FFE4B5  Warm candlelight (lighting)

Enemy tint: #8B6914 (chef whites + gold trim)
Blood: #AA0020 (visible on gold/burgundy)
Background: #2A1508 (warm dark brown)
```

### Floor 4 — Greed / Vault
```
Dominant colors:
  ██████ #FFD700  Bright gold (bars, coins, fixtures)
  ██████ #5A6A7A  Steel blue-grey (vault doors, metal)
  ██████ #1A1A3A  Dark navy (shadows, backgrounds)
  ██████ #C0C8D0  Silver (mechanisms, details)

Enemy tint: #5A6A8A (blue-grey suits)
Blood: #CC2222 (bright on gold/navy)
Background: #0E0E1E (dark blue-black)
```

### Floor 5 — Sloth / Spa
```
Dominant colors:
  ██████ #3CBEB0  Turquoise (water, tiles)
  ██████ #E8F0F0  Pale white (steam, marble)
  ██████ #8AABA0  Muted teal (accents, fog)
  ██████ #B8D8D0  Seafoam (mist, ambient)

Enemy tint: #6A9A8A (spa uniform, teal)
Blood: #AA2222 (dark against light palette)
Background: #D0E0E0 (light grey-blue)
```

### Floor 6 — Wrath / Arena
```
Dominant colors:
  ██████ #CC1100  Blood red (arena floor, walls)
  ██████ #B74A0E  Rust orange (chains, weapons)
  ██████ #1A0A0A  Near-black (depth, shadows)
  ██████ #FF5500  Ember orange (fire, heat)

Enemy tint: #8B2500 (dark red armor)
Blood: #EE0000 (brightest red — matches theme)
Background: #0F0505 (dark red-black)
```

### Floor 7 — Envy / Observatory
```
Dominant colors:
  ██████ #1A1A6A  Deep indigo (sky, walls)
  ██████ #C0C0D0  Silver (telescopes, instruments)
  ██████ #4B0082  Purple (nebula effects, runes)
  ██████ #E6E6FA  Starlight white (accents, stars)

Enemy tint: #6A5A8A (dark purple robes)
Blood: #CC2222 (vivid against cool palette)
Background: #0A0A2A (deep space blue)
```

### Floor 8 — Pride / Ballroom
```
Dominant colors:
  ██████ #DAA520  Royal gold (thrones, crowns, frames)
  ██████ #F5F5F0  Pure white (marble, crystal)
  ██████ #8B0000  Blood red (carpet, accents)
  ██████ #2A2A2A  Deep black (shadows, suits)

Enemy tint: #2A2A3A (dark formal wear)
Blood: #DD0000 (bright against gold/white)
Background: #1A1A1A (near-black luxury)
```

### Floor 9 — Satan's Sanctum
```
Shifting palette (NOT fixed):

Phase 1 (Entry):  #F0F0F0 white → #E0E0E0 (sterile, wrong)
Phase 2 (Sister): #F0E0E0 warm white → #D0B0B0 (flesh tones)
Phase 3 (Satan):  #1A0A0A black → #AA0000 (encroaching red)
Phase 4 (Final):  #FF0000 pure red → #000000 black (reality collapse)

Blood: shifts with palette (#CC2222 → #000000 → #FF0000)
Background: shifts with phases
```

---

# 5. ENVIRONMENT ART

## 5.1 Tileset Structure Per Floor

Each floor tileset:
- **Base tiles**: ~15-20 shared tiles (floor, wall variants, corners)
- **Accent tiles**: ~10-15 unique tiles (floor-specific decorations)
- **Functional tiles**: doors, stairs, elevators, traps (~5-10)
- **Destructible tiles**: breakable objects (~5-8)

**Total per floor**: ~35-50 unique tiles

### Tile Categories:

| Category | Description | Animated? |
|----------|-------------|-----------|
| Floor base | 2-3 variants per floor | No |
| Floor accent | Carpet patterns, tile patterns, blood stains | No |
| Wall base | 2-3 variants per floor | No |
| Wall accent | Decorations, signs, paintings, pipes | No |
| Wall top (3/4) | Upper wall portion visible above character | No |
| Furniture | Tables, chairs, shelves, counters | No |
| Destructible | Breakable objects (bottles, crates, glass) | Yes (break animation) |
| Doors | Standard, locked, elevator | Yes (open/close) |
| Hazards | Floor-specific traps | Yes (activation) |
| Lighting | Light sources, neon signs, candles | Yes (flicker) |

## 5.2 Room Composition Rules

- **Walls**: 1 tile thick, darker than floor, clear boundary
- **Furniture**: breaks up space, provides cover, some destructible
- **Sightlines**: player should see threats coming, no unfair ambushes
- **Negative space**: enough empty floor for combat readability
- **Environmental storytelling**: objects placed to tell stories (cult items, evidence of rituals)
- **Blood stains**: pre-placed in some rooms (hints of prior violence)

## 5.3 Destructible Environment

**Categories:**
- **Glass**: windows, mirrors, bottles → shatter into shards (projectile hazard)
- **Wood**: furniture, crates, doors → break into planks (pickup weapons)
- **Metal**: pipes, fixtures → dent, not fully destroy
- **Fabric**: curtains, tablecloths → tear, reveal things behind

**Visual rules:**
- Break animation: 3-4 frames
- Debris: 2-3 pixel pieces, physics-driven, fade after 5 seconds
- Dropped items (from inside furniture): weapon/upgrade pickup appears

---

# 6. GORE & EFFECTS

## 6.1 Blood Visual Style

**Approach: Stylized splatter with realistic detail**
- Blood is PAINT-LIKE: thick, expressive, splatter-shaped
- Not photorealistic pixel art — more comic-book exaggeration
- Each splash should feel IMPACTFUL and SATISFYING
- Blood color adjusts per floor for contrast (see palettes)

## 6.2 Blood Effects

| Effect | Visual | Lifetime | Notes |
|--------|--------|----------|-------|
| Impact splash | Directional spray, 6-8 particles | 0.3s | On hit |
| Blood pool | Flat circle, 3-4 size variants | Permanent (room) | Grows with damage |
| Blood trail | Dots/drips on floor | Permanent (room) | From moving wounded enemies |
| Arterial spray | Large directional burst | 0.5s | On limb sever |
| Blood drip from limb | Dripping from severed limb entity | 3s | Severed limb physics object |
| Wall splatter | Wall decoration | Permanent (room) | Hits near walls |

## 6.3 Severed Limbs

**Visual approach:**
- Severed limb is a PHYSICS OBJECT (RigidBody2D)
- Bounces/rolls on ground
- Sprite matches the limb type (arm with hand, leg with foot)
- Brief blood trail as it slides
- Fades after 30 seconds (performance)
- **Can be picked up as improvised weapon**

**Enemy stump (where limb was):**
- 2-3 px red stump visible on enemy body
- Brief blood drip animation (2-3 drips)
- Then static dark red dot

## 6.4 Regeneration Visual

**Flesh growing back animation:**
- Starts as raw red/pink mass at stump
- Gradually extends outward (8-12 frames)
- Final frame: limb fully restored, brief flash
- Visual tells for player: see flesh growing = RE-MUTILATE NOW
- Audio cue: wet organic sound, increasing in pitch as regeneration completes

## 6.5 Screen Effects

| Effect | Trigger | Visual |
|--------|---------|--------|
| Screen shake | Heavy hit, explosion | 2-4 px offset, 0.1-0.2s |
| Hit stop (freeze frame) | Limb sever, critical hit | 2-3 frames pause |
| Flash (white) | Player hurt | Full screen white flash, 0.05s |
| Flash (red) | Enemy killed/mutilated | Small radial flash at impact |
| Blood vignette | Player low HP | Red edges, pulsing |
| Chromatic aberration | Basement entry | Brief RGB split |

---

# 7. WEAPON VISUAL DESIGN

## 7.1 Weapon Sprite Specs

| Weapon | Size (px) | Visual Notes |
|--------|-----------|--------------|
| Machete | 16×6 | Wide blade, wooden handle |
| Knife | 10×4 | Small, thin, glinting |
| Axe | 14×12 | Heavy head, short handle |
| Bat | 20×4 | Wooden, maybe nails |
| Sword (cult) | 20×6 | Ornate, glowing runes |
| Sawed-off | 16×8 | Short barrel, wooden stock |
| Pistol | 12×6 | Compact, dark metal |
| SMG | 16×6 | Boxier, magazine visible |
| Shotgun | 20×6 | Long barrel, pump |
| Cult pistol | 14×7 | Ornate, faintly glowing |
| Bottle | 6×10 | Glass, amber liquid |
| Chair | 14×14 | Wooden, legs visible |
| Severed limb | 6×14 (arm), 8×14 (leg) | Bloody stump end |
| Wire | Variable | Thin, barely visible (threat!) |
| Cult artifact-weapon | Variable | Unique per artifact |

## 7.2 Weapon Animation Requirements

| Weapon | Melee Frames | Throw Frames | Special |
|--------|-------------|-------------|---------|
| Machete | 5 (slash arc) | 4 (spin) | — |
| Knife | 4 (stab) | 3 (fast straight) | — |
| Axe | 6 (heavy chop) | 5 (arc + rotation) | Embedded in target |
| Bat | 5 (swing) | 4 (tumble) | Break on impact (improvised) |
| Sawed-off | 3 (pump/fire) | 3 (tumble) | Discharge on throw impact |
| Pistol | 3 (aim/fire) | 3 (tumble) | Discharge on throw |
| Bottle | 3 (swing) | 3 (arc) | Shatters on any impact |
| Severed limb | 4 (flail) | 3 (tumble) | Gore trail |

---

# 8. UI STYLE

## 8.1 General Principles

- **Pixel font for ALL text** — maintains visual consistency
- **Gothic/Art Deco influenced UI frames** — ornate borders, geometric patterns
- **Minimal, diegetic where possible** — health bar = player's body state, not floating bar
- **Dark backgrounds with gold/red accents** — matches hotel aesthetic
- **NO generic rounded rectangles** — everything has character

## 8.2 Font

**Primary font:** Pixel font with gothic character
- Serif-like pixel font for headers (ornate, cathedral-like)
- Clean pixel font for body text/readable info
- Size: 8px base (fits pixel grid)

## 8.3 HUD Layout

```
┌──────────────────────────────────────────────────┐
│  [WEAPON 1 icon]  [WEAPON 2 icon]                │
│  [ammo: ●●●○]                                    │
│                                                   │
│                                                   │
│                    (GAME AREA)                     │
│                                                   │
│                                                   │
│                         FLOOR 3 · GLUTTONY        │
│  [HP: ████████░░]                [ACTIVE BUFFS]   │
└──────────────────────────────────────────────────┘
```

- **Top-left**: Weapon slots (2 boxes, active highlighted, icon + ammo)
- **Bottom-left**: HP bar (horizontal, fills with color, depletes from right)
- **Bottom-center**: Floor name (subtle, small text)
- **Bottom-right**: Active buff icons (cult artifacts, small icons)

## 8.4 HUD Visual Style

- **HP bar**: Red fill, dark frame, Art Deco border pattern
- **Weapon slots**: Small ornate frames, weapon icon inside, gold border
- **Ammo counter**: Bullet dots (filled = available, empty = spent)
- **Floor name**: Subtle, semi-transparent, gothic font
- **Buff icons**: Small 16×16 symbols with brief description on hover

## 8.5 Menu Screens

**Title screen:**
- Dark background, hotel silhouette
- Title "HOTEL" in large ornate gothic pixel font
- Gold/red lighting
- Minimal options: START, SETTINGS, QUIT

**Run start:**
- Brief text: floor name, run number
- Fade into Floor 1

**Game over:**
- Red/black screen
- "CAPTURED" or "CONSUMED" text
- Stats: floors reached, enemies mutilated, time
- "TRY AGAIN" / "MAIN MENU"

**Victory:**
- White → red shift
- "ESCAPED" or ending-specific text
- Full run stats

---

# 9. LIGHTING & ATMOSPHERE

## 9.1 Lighting Approach

- **No dynamic lighting** (pixel art, 2D)
- **Faked lighting via tile overlays**: semi-transparent colored tiles over environment
- **Light sources** are visual elements, not real lights:
  - Neon signs (floor 2): bright pixel glow around sign
  - Candles (floor 3): warm circle on floor below
  - Industrial lamps (floor 1): harsh white cone
- **Shadow tiles**: darker tiles placed in corners, under objects
- **Fog/steam** (floor 5): semi-transparent overlay tiles, animated

## 9.2 Atmosphere Per Floor

| Floor | Atmosphere Technique |
|-------|---------------------|
| 1 | Flickering industrial light, shadow corners, pipe steam |
| 2 | Neon glow (pink/red), mirror reflections, deep shadows |
| 3 | Warm candlelight, food steam, dim gold |
| 4 | Cold steel light, gold reflections, vault darkness |
| 5 | Bright diffuse light, steam/fog overlay, soft white |
| 6 | Harsh arena spotlights, fire glow, deep red shadows |
| 7 | Starlight, cosmic purple glow, deep blue darkness |
| 8 | Crystal chandelier light, gold reflections, dramatic shadows |
| 9 | Shifting — sterile white → oppressive red → void black |

---

# 10. SPRITE SHEET FORMAT

## 10.1 Layout

```
sprite_name.png
┌──────────────────────────────────────────────┐
│  Row 0: ↓  (front)                           │
│  [idle frames] [walk frames] [attack frames]  │
│  Row 1: ↘  (front-right)                     │
│  [idle frames] [walk frames] [attack frames]  │
│  Row 2: →  (right)                           │
│  ...                                          │
│  Row 3: ↗  (back-right)                      │
│  ...                                          │
│  Row 4: ↑  (back)                            │
│  ...                                          │
│  Row 5: ← (mirror of →, flipped in code)     │
│  Row 6: ↙ (mirror of ↘)                      │
│  Row 7: ↖ (mirror of ↗)                      │
└──────────────────────────────────────────────┘
```

## 10.2 File Naming

```
player_idle_front_5f.png       (5 frames)
player_walk_front_8f.png
enemy_staff_idle_front_5f.png
enemy_guard_attack_right_6f.png
weapon_machete.png
weapon_machete_throw_4f.png
effect_blood_splash.png
floor_01_tileset.png
floor_01_furniture.png
```

## 10.3 Texture Import Settings (Godot 4)

- **Filter**: Nearest (pixel-perfect)
- **Repeat**: Disabled
- **Mipmaps**: Disabled
- **Texture type: 2D**
- **Max texture size**: 2048×2048 per sheet

---

# 11. PRODUCTION NOTES

## 11.1 Art Pipeline

```
1. Sketch (rough silhouette) → Validate readability
2. Pixel (base sprite, front-facing) → Validate proportions
3. Animate (front direction first) → Validate motion
4. Mirror (5 directions) → Validate all angles
5. Variants (mutilation states) → Validate readability
6. Integrate (import to Godot) → Validate in-game
```

## 11.2 Placeholder Strategy

- **Phase 1 (Prototype)**: Colored rectangles with limb indicators
- **Phase 2 (Alpha)**: Rough pixel art, basic animations
- **Phase 3 (Beta)**: Final pixel art, all animations
- **Phase 4 (Polish)**: Effects, atmosphere, polish

## 11.3 Asset Priority Order

1. Player sprite (idle + walk + attack, front only)
2. Base enemy sprite (idle + walk + attack, front only)
3. Floor 1 tileset
4. Weapons (5 MVP)
5. Player full animation set (8 dirs)
6. Enemy full animation set (8 dirs + mutilation)
7. Blood/gore effects
8. UI elements
9. Floor 2-9 tilesets
10. Additional enemies + bosses
