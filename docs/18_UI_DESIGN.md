# UI DESIGN DOCUMENT — HOTEL
## Version 1.0

---

# 1. UI PHILOSOPHY

- **Minimal.** HUD не мешает gameplay. Информация — только необходимая.
- **Diegetic where possible.** HP = player visual state, не floating bar.
- **Gothic Art Deco aesthetic.** Ornate frames, gold accents, dark backgrounds.
- **Pixel-perfect.** Все UI элементы — pixel art, snap to grid.

---

# 2. HUD

## 2.1 Layout

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ┌──────────┐                                           │
│  │ [MACHETE]│                                           │
│  │    ●     │                                           │
│  └──────────┘  ┌──────────┐                             │
│               │ [SAWED-OFF]│                             │
│               │  ●●●○     │                             │
│               └──────────┘                              │
│                                                         │
│                                                         │
│                    (GAME VIEW)                           │
│                                                         │
│                                                         │
│                                                         │
│  ████████████░░░░                                       │
│  HP                                                     │
│                              FLOOR 3 · GLUTTONY  [🔥][👁]│
└─────────────────────────────────────────────────────────┘
```

## 2.2 Elements

### HP Bar (Bottom-Left)
- Horizontal bar, 120px wide, 8px tall
- Red fill (#CC2222), dark frame (#1A1A1A), Art Deco border (#8A7A5A)
- Depletes from right to left
- Below 30%: pulsing red glow + blood vignette overlay
- No numbers — visual only

### Weapon Slots (Top-Left)
- 2 slots, stacked vertically
- Active slot: gold border (#DAA520)
- Inactive slot: dark border (#4A4A4A)
- Weapon icon inside (16×16 px)
- Ammo display: bullet dots below (● = available, ○ = spent)
- Empty slot: dark square with faint outline

### Floor Indicator (Bottom-Center)
- Text: "FLOOR 3 · GLUTTONY"
- Small, semi-transparent (alpha 0.5)
- Pixel font, gothic style
- Fades out after 3s when entering new floor

### Active Buffs (Bottom-Right)
- Row of 16×16 icons
- Cult artifacts: larger icon with faint glow
- Max 8 visible, scrollable
- Hover (if implemented): brief tooltip

### Damage Direction (Screen Edge)
- Red flash on screen edge, direction of incoming damage
- 0.15s duration
- Fade out

### Interaction Prompt (Context-Sensitive)
- "[E] Pick up Machete" — appears near interactive objects
- Pixel font, white text, semi-transparent dark background
- Only when player is in range

---

# 3. MENUS

## 3.1 Title Screen

```
┌─────────────────────────────────────────────┐
│                                             │
│                                             │
│              ██  ████  ██                   │
│              ██  █  █  ██                   │
│              ██  ████  ██                   │
│              ██  █  █  ██                   │
│              ██  ████  ██                   │
│                                             │
│           H O T E L                         │
│                                             │
│         ╔═══════════════╗                   │
│         ║   NEW RUN     ║                   │
│         ╠═══════════════╣                   │
│         ║   SETTINGS    ║                   │
│         ╠═══════════════╣                   │
│         ║   LORE JOURNAL║                   │
│         ╠═══════════════╣                   │
│         ║   QUIT        ║                   │
│         ╚═══════════════╝                   │
│                                             │
│           [Best: Floor 7]                   │
│           [Runs: 14]                        │
└─────────────────────────────────────────────┘
```

- Background: dark with hotel silhouette, subtle red/gold lighting
- Title: large ornate gothic pixel font, gold colour
- Menu items: smaller gothic font, gold borders, highlight = red
- Stats: small text bottom, tracking best run

## 3.2 Run Start

- Brief transition: floor name appears → fade to black → game begins
- Duration: 1.5s
- "FLOOR 1 · SERVICE" text, then gameplay

## 3.3 Game Over

```
┌─────────────────────────────────────────────┐
│                                             │
│                                             │
│            C A P T U R E D                  │
│                                             │
│         Floors Reached: 4                   │
│         Enemies Mutilated: 47               │
│         Limbs Severed: 63                   │
│         Time: 14:32                         │
│         Weapons Used: 8                     │
│                                             │
│         ╔═══════════════╗                   │
│         ║   TRY AGAIN   ║                   │
│         ╠═══════════════╣                   │
│         ║   MAIN MENU   ║                   │
│         ╚═══════════════╝                   │
│                                             │
└─────────────────────────────────────────────┘
```

- Background: dark red/black gradient
- "CAPTURED" or "CONSUMED" text in large gothic font
- Run statistics
- Options: Try Again (new run) or Main Menu

## 3.4 Victory

```
┌─────────────────────────────────────────────┐
│                                             │
│         E S C A P E D                       │
│                                             │
│         [Ending-specific text]              │
│                                             │
│         Floors Cleared: 9/9                 │
│         ...stats...                         │
│                                             │
│         ╔═══════════════╗                   │
│         ║   PLAY AGAIN  ║                   │
│         ╠═══════════════╣                   │
│         ║   MAIN MENU   ║                   │
│         ╚═══════════════╝                   │
│                                             │
└─────────────────────────────────────────────┘
```

## 3.5 Pause Menu

```
┌─────────────────────────────────────────────┐
│                                             │
│         ╔═══════════════╗                   │
│         ║   RESUME      ║                   │
│         ╠═══════════════╣                   │
│         ║   SETTINGS    ║                   │
│         ╠═══════════════╣                   │
│         ║   LORE JOURNAL║                   │
│         ╠═══════════════╣                   │
│         ║   ABANDON RUN ║                   │
│         ╚═══════════════╝                   │
│                                             │
│         Floor 3 · Gluttony                  │
│         HP: ████████░░                      │
└─────────────────────────────────────────────┘
```

## 3.6 Settings

| Setting | Type | Range |
|---------|------|-------|
| Master Volume | Slider | 0-100% |
| Music Volume | Slider | 0-100% |
| SFX Volume | Slider | 0-100% |
| Screen Shake | Toggle | On/Off |
| Screen Flash | Toggle | On/Off |
| Blood Intensity | Slider | 50-100% (min 50% — gameplay info) |
| Fullscreen | Toggle | On/Off |

## 3.7 Lore Journal

- Accessible from pause menu and main menu
- Shows all discovered notes organized by floor
- Unread notes highlighted
- Completion percentage per floor
- Unlock tracking (hidden notes not shown until found)

---

# 4. IN-GAME OVERLAYS

## 4.1 Artifact Pickup Popup

```
┌─────────────────────────────────┐
│                                 │
│   ◆ DEMON EYE ◆                │
│                                 │
│   ★ Ranged damage +30%          │
│   ★ Detection range +50%        │
│                                 │
│   ✗ Melee damage -20%           │
│   ✗ Reduced peripheral vision   │
│                                 │
│   ⚠ Cannot be removed this run  │
│                                 │
│   [E] Accept    [ESC] Reject    │
│                                 │
└─────────────────────────────────┘
```

- Game pauses during artifact choice
- Gold border, dark background
- Bonus in gold text, cost in red text
- Warning at bottom

## 4.2 Floor Transition

- Black screen with floor name
- 1.5s duration
- "FLOOR [N] · [SIN NAME]"
- Fade in to gameplay

## 4.3 Boss Intro

- Boss name appears (large text)
- Brief boss description (1 line)
- 2s duration
- Screen shake
- Then boss music starts

## 4.4 Enemy Health/Limb State

- NO health bars on enemies (clutters screen)
- Visual readability only (see Art Bible §2.2)
- Exception: bosses get small HP bar at top of screen

## 4.5 Boss HP Bar

```
┌──────────────────────────────────────────┐
│  THE HEAD CHEF                           │
│  ██████████████████████████░░░░░░░░░░░░  │
└──────────────────────────────────────────┘
```

- Top of screen, centered
- Boss name in gothic font
- HP bar below, same style as player HP but wider
- Phases indicated by markers on bar

---

# 5. FONTS

## 5.1 Font Selection

| Usage | Style | Size | Notes |
|-------|-------|------|-------|
| Title / Boss names | Gothic pixel serif | 32px | Ornate, cathedral-like |
| Menu items | Gothic pixel serif | 16px | Same family, smaller |
| HUD text | Clean pixel sans-serif | 8px | Readable, minimal |
| Lore notes | Typewriter pixel font | 8px | Imperfect, worn |
| Floor names | Gothic pixel serif | 12px | Medium ornate |

## 5.2 Font Files Needed

- 1 gothic pixel serif font (2 sizes: 16px + 32px headers)
- 1 clean pixel sans-serif font (8px)
- 1 typewriter pixel font (8px)
