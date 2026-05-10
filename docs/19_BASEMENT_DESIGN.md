# BASEMENT ESCAPE DESIGN DOCUMENT — HOTEL
## Version 1.0

---

# 1. OVERVIEW

## 1.1 Concept

Basement = punishment zone. One layout reused across all floors. Different enemies per floor. Short, tense, high stakes.

**Purpose:**
- Thematic: тебя тянут ВНИЗ пока ты идёшь вверх
- Gameplay: punishment за потерю HP, не instant game over
- Tension: high-stakes mini-challenge

## 1.2 Flow

```
Player HP = 0
  → "CAPTURED" screen (1s)
  → Basement loads (stripped of weapons except 1 random melee)
  → Player spawns at START
  → Navigate to EXIT
  → Success: return to current floor (start of floor, not room of death)
  → Failure: RUN OVER → restart Floor 1
```

---

# 2. LAYOUT

## 2.1 Single Layout (8×6 tiles, ~256×192 px viewport)

```
┌─────────────────────────────────────┐
│  START                              │
│  ┌──┐                               │
│  │P │──corridor──┬──room A──┐       │
│  └──┘           │  [E×2-3] │       │
│                 │           │       │
│          corridor──┤       ├──corridor──┐
│                 │  room B  │           │
│                 │  [E×2-3] │           │
│                 └────┬─────┘           │
│                      │                 │
│                 corridor──EXIT         │
│                           [E×1-2]      │
└─────────────────────────────────────┘
```

**Rooms:**
- **Start room**: 3×3 tiles. Safe. One weapon on ground (random melee)
- **Corridor A**: 6×2 tiles. Narrow. 1-2 enemies
- **Room A**: 5×4 tiles. 2-3 enemies
- **Corridor B**: 4×2 tiles. Pipes, steam. 1 enemy
- **Room B**: 5×4 tiles. 2-3 enemies
- **Corridor C**: 4×2 tiles. Final stretch. 1-2 enemies
- **Exit room**: 2×3 tiles. Exit stairs. Guarded by 1 enemy

**Total:** ~30 seconds to 2 minutes depending on skill

## 2.2 Visual

- **Palette:** Universal basement palette (dark grey, rust, dim red)
  ```
  ██████ #1A1A1A Near-black walls
  ██████ #3A3A3A Dark grey floor
  ██████ #7A3A1A Rust pipes
  ██████ #AA2222 Dim red light
  ```
- **Atmosphere:** Industrial. Pipes. Steam. Dripping. Wrong.
- **Lighting:** Sparse red lights. Most areas dim.
- **Slight variations per floor:** enemy corpses in floor-specific uniforms (visual storytelling)

---

# 3. MECHANICS

## 3.1 Weapon Stripping

Upon entering basement:
- All weapons removed EXCEPT 1 random melee from player's inventory
- If player had no melee: given a Knife (worst case backup)
- Ammo reset to 0
- Upgrades KEPT (artifacts and stats persist)
- Cult artifacts still active (including penalties)

**Design rationale:** Upgrades are the player's investment. Taking them away would be too punishing. But weapons = fresh start forces improvisation.

## 3.2 Enemy Scaling Per Floor

| Floor | Enemies | Types | HP Mult | Speed Mult |
|-------|---------|-------|---------|-----------|
| 1-2 | 5-6 | Staff + Guard | ×0.8 | ×0.9 |
| 3-4 | 6-7 | Staff + Guard + Handler | ×1.0 | ×1.0 |
| 5-6 | 7-8 | Guard + Handler + floor type | ×1.1 | ×1.1 |
| 7-8 | 8-9 | Guard + Handler + floor type + elite | ×1.2 | ×1.15 |
| 9 | 9-10 | Demon + elite | ×1.5 | ×1.3 |

**Enemy types:** Drawn from the CURRENT floor's enemy pool. Floor 3 basement = Chef enemies. Floor 7 basement = Spy enemies. Reinforces floor identity.

## 3.3 Time Pressure

- **Subtle clock:** 60 seconds before "reinforcements" arrive (2 extra enemies)
- **No visible timer** — audio cue: distant footsteps getting louder
- **At 90 seconds:** 4 extra enemies (basement becomes very hard)
- **Design intent:** Quick, clean escape = reward. Linger = punished.

## 3.4 Loot

- **No upgrades** in basement (you're being punished, not rewarded)
- **Exception:** If you find a hidden alcove (1 per layout, random position) → 1 random weapon pickup
- **Basement escape reward:** If you succeed AND cleared the basement in under 30 seconds → 1 random cult artifact

---

# 4. FAILURE STATE

## 4.1 If Player HP = 0 in Basement

- Screen fades to black
- "CONSUMED" text
- NO second chance — run is over
- Return to main menu
- Run stats displayed

## 4.2 Why No Second Basement

- Design intent: basement = your ONE second chance per "death"
- Failing the second chance = ultimate consequence
- This makes basement escape HIGH STAKES
- Maintains roguelike tension

---

# 5. AUDIO

## 5.1 Basement Music

- **Style:** Minimal industrial drone
- **Elements:** Low heartbeat, pipe dripping, metal creaking, distant screaming
- **No combat music change** — the tension IS the ambient
- **Success:** Brief relief chord → floor music returns
- **Failure:** Silence → game over

## 5.2 Audio Cues

- Player footsteps echo louder (basement is enclosed)
- Enemy sounds more menacing (closer, more immediate)
- Time pressure cue: footsteps getting louder + faster
- Exit proximity: faint light hum when near exit

---

# 6. DESIGN RATIONALE

## 6.1 Why One Layout

- Scope control — 1 layout vs 9 unique = massive production saving
- Mastery element — player learns the basement over multiple runs
- The variation comes from enemies, not geometry
- Familiarity creates comfort — but enemy escalation prevents complacency

## 6.2 Why Keep Upgrades

- Player's build is their identity for the run
- Stripping everything = too punishing
- Keeping artifacts = your choices still matter
- But losing weapons = fresh challenge

## 6.3 Why Short

- 30s-2min = tension spike, not slog
- Longer = frustrating
- It's a punishment, not a level
- Quick success feels GOOD — "I escaped!"
