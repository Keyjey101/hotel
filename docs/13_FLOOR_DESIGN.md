# FLOOR DESIGN DOCUMENT — HOTEL
## Version 1.0

---

# 1. FLOOR STRUCTURE OVERVIEW

## 1.1 Universal Floor Architecture

Каждый этаж состоит из:

```
HUB ROOM (центральная)
├── Branch A (2-3 комнаты) → loot + enemies
├── Branch B (2-3 комнаты) → loot + enemies
├── Branch C (2-3 комнаты) → key/miniboss trigger (critical path)
└── Mini-Boss Arena → defeat → exit stairs

Total per floor: 1 hub + 3 branches (6-9 rooms) + 1 arena = 8-11 rooms
```

## 1.2 Route Variation System

Каждый run, seed определяет:
- Какие branches открыты (2 из 3 обязательны)
- 1 branch закрыт (blocked door)
- Key/trigger всегда в открытом branch
- Optional branch содержит extra loot но больше danger

## 1.3 Room Types

| Type | Purpose | Enemies | Loot |
|------|---------|---------|------|
| Corridor | Transition, ambush zone | 1-3 | None |
| Chamber | Standard encounter | 3-5 | 1-2 items |
| Storage | Loot room, light combat | 1-2 | 2-3 items |
| Gallery | Large combat arena | 5-8 | 1-2 items |
| Service | Environmental storytelling | 0-2 | Lore items |
| Trap Room | Hazardous, puzzle-like | 1-2 | 1 rare item |
| Hub | Central junction | 2-4 | 1 item |
| Boss Arena | Mini-boss fight | Boss + 0-2 | Floor reward |

---

# 2. FLOOR 1 — SERVICE UNDERGROUND

## 2.1 Identity

**Theme:** "Машина под полом"
**Sin:** Нет (вводный этаж)
**Fantasy:** Ты в подвалах. Трубы. Гудение. Здесь начинается мясная промышленность отеля.

**Palette:**
```
████ #2A2A2E Dark concrete
████ #4A4A3E Dull green-grey
████ #7A5A2E Rust orange
████ #8A7A5A Dim brass
Blood: #CC2222 | BG: #1A1A1E
```

**Audio:** Industrial ambient. Pipes humming. Distant machinery. Muffled sounds from above.

## 2.2 Floor Layout (10 rooms)

```
┌─────────────────────────────────────────────┐
│  [A1] Entry Shaft                            │
│   ↓                                          │
│  [A2] Service Corridor                       │
│   ↓                                          │
│  ★ [HUB] Boiler Room                         │
│   ├── [B1] Laundry Room                      │
│   │    └── [B2] Linen Storage                 │
│   ├── [C1] Meat Processing (locked)           │
│   │    └── [C2] Freezer Room                  │
│   └── [D1] Maintenance Tunnels               │
│        └── [D2] Generator Room                │
│                                              │
│  [KEY in B2 or D2] → unlock C1               │
│                                              │
│  [BOSS] Head Chef's Kitchen                   │
│   └── Exit Stairs → Floor 2                   │
└─────────────────────────────────────────────┘
```

## 2.3 Room Details

### A1 — Entry Shaft
- **Size:** Small (8×6 tiles)
- **Purpose:** Entry point, brief safety
- **Enemies:** 0
- **Features:** Ladder from surface, flickering light, "STAFF ONLY" sign
- **Loot:** None
- **Lore:** Graffiti: "They never leave. Neither will you."

### A2 — Service Corridor
- **Size:** Medium corridor (12×4 tiles)
- **Purpose:** First encounter, tutorial feel
- **Enemies:** Staff ×2
- **Features:** Pipes on walls, steam vents (visual), narrow
- **Loot:** Knife (on shelf)
- **Lore:** Work schedule on wall — names crossed off in red

### HUB — Boiler Room
- **Size:** Large (14×12 tiles)
- **Purpose:** Central junction, first real combat
- **Enemies:** Staff ×2, Guard ×1
- **Features:** Massive boilers, steam, three exits (B/C/D)
- **Loot:** Bat (behind boiler)
- **Route gates:** 2 of 3 doors open per run

### B1 — Laundry Room
- **Size:** Medium (10×8 tiles)
- **Purpose:** Standard combat encounter
- **Enemies:** Staff ×3
- **Features:** Washing machines (hiding spots?), wet floor (visual), uniform racks
- **Loot:** Pistol (in locker)
- **Lore:** Uniforms with name tags — some have blood stains

### B2 — Linen Storage
- **Size:** Small (6×6 tiles)
- **Purpose:** Loot room, light danger
- **Enemies:** Staff ×1
- **Features:** Shelves of linens, one blood-soaked pile
- **Loot:** Ammo pickup + random stat upgrade + **KEY** (50% chance key is here)
- **Lore:** Hidden behind shelves: crude drawing of ritual

### C1 — Meat Processing
- **Size:** Large (12×10 tiles)
- **Purpose:** Combat + thematic horror
- **Enemies:** Handler ×1, Staff ×2
- **Features:** Meat hooks (visual, some with... shapes), conveyor, blood drains in floor
- **Loot:** Axe (on cutting block)
- **Lore:** Processing charts: "Floor 3 requisition: 12 units"

### C2 — Freezer Room
- **Size:** Medium (8×8 tiles)
- **Purpose:** Key location OR trap
- **Enemies:** Guard ×1
- **Features:** Frozen shelves, fog on floor, cold blue light
- **Loot:** **KEY** (50% chance) + ammo
- **Lore:** Frozen bodies wrapped in plastic — labelled with floor numbers

### D1 — Maintenance Tunnels
- **Size:** Long corridor (16×4 tiles)
- **Purpose:** Optional branch, environmental storytelling
- **Enemies:** Staff ×2, Guard ×1
- **Features:** Exposed pipes, tight space, dripping
- **Loot:** Wire (on tool rack)
- **Lore:** Maintenance log: "Floor 5 steam system drawing from... unusual source"

### D2 — Generator Room
- **Size:** Medium (10×8 tiles)
- **Purpose:** Optional loot room
- **Enemies:** Guard ×1, Staff ×1
- **Features:** Generator humming, electrical panels, sparks
- **Loot:** **KEY** (if not in B2) + random weapon
- **Lore:** Power distribution chart — each floor labeled with occult symbols

### BOSS — Head Chef's Kitchen
- **Size:** Large arena (16×14 tiles)
- **Purpose:** Mini-boss fight
- **Enemies:** Head Chef (mini-boss)
- **Features:** Industrial kitchen, stoves, cutting blocks, meat hooks
- **Loot:** Floor reward (random cult artifact)
- **Exit:** Stairs to Floor 2

## 2.4 Enemy Composition

| Room | Enemies | Total Threat |
|------|---------|-------------|
| A2 | Staff ×2 | Low |
| HUB | Staff ×2, Guard ×1 | Medium |
| B1 | Staff ×3 | Low-Med |
| B2 | Staff ×1 | Low |
| C1 | Handler ×1, Staff ×2 | High |
| C2 | Guard ×1 | Medium |
| D1 | Staff ×2, Guard ×1 | Medium |
| D2 | Guard ×1, Staff ×1 | Medium |
| BOSS | Head Chef | Boss |

---

# 3. FLOOR 2 — LUST / RED LIGHT DISTRICT

## 3.1 Identity

**Theme:** "Желание как клетка"
**Sin:** Похоть
**Fantasy:** Неоновый рай. Бархат. Зеркала. Всё — обман. Желание держит тебя.

**Palette:**
```
████ #8B0035 Deep crimson
████ #FF1A6D Hot pink neon
████ #0A0A0F Near-black
████ #FF6EB4 Soft pink
Blood: #990022 | BG: #150008
```

**Audio:** Synthwave — seductive, slow pulse. Distant moans (not sexual — pain). Mirror reflections sound "off" (slight echo delay).

## 3.2 Floor Layout (10 rooms)

```
[A1] Velvet Entryway
  ↓
[A2] Neon Corridor
  ↓
★ [HUB] The Lounge
  ├── [B1] Hall of Mirrors
  │    └── [B2] Peep Room
  ├── [C1] Silk Chamber (locked)
  │    └── [C2] The Boudoir
  └── [D1] Red Light Gallery
       └── [D2] Dressing Room
[BOSS] Madame's Chamber
 └── Exit → Floor 3
```

## 3.3 Key Mechanics

**Hall of Mirrors (B1):**
- Зеркала на стенах — враги создают визуальные копии
- Seductress's decoy ability amplified: +1 extra decoy в этой комнате
- Некоторые зеркала — настоящие проходы в секретные зоны
- Breaking mirrors = removes decoy capability для Seductresses в room

**Neon Lighting:**
- Pink/red neon создаёт pools of light
- Тени в этой комнате — longer, distorted
- Враги вне neon pools = harder to see (reduced visibility)

## 3.4 Room Highlights

### HUB — The Lounge
- Velvet couches, champagne glasses, pink lighting
- Enemies: Seductress ×1, Bodyguard ×1, Staff ×2
- Lore: Guest book — names of "visitors" with checkmarks and crosses

### B1 — Hall of Mirrors
- **Size:** Large (14×12 tiles)
- Mirrored walls (visual trick — reflections of enemies)
- Seductress ×2, Bodyguard ×1
- Break mirrors to reduce decoy ability
- Lore: "Mirror, mirror. Who's the fairest? Who's the last?"

### C1 — Silk Chamber
- Silk curtains (semi-transparent — can see shadows behind them)
- Enemies: Seductress ×2
- Curtains can be torn (reveal hidden enemies)
- Lore: Photos on wall — missing persons in elegant frames

---

# 4. FLOOR 3 — GLUTTONY / BANQUET HALL

## 4.1 Identity

**Theme:** "Пир, который никогда не заканчивается"
**Sin:** Обжорство
**Fantasy:** Банкетный зал. Золото. Мрамор. Еда. Гниющая еда. Они едят, но не наедаются. Никогда.

**Palette:**
```
████ #B8860B Rich gold
████ #6B0020 Deep burgundy
████ #556B2F Rot green
████ #FFE4B5 Warm candlelight
Blood: #AA0020 | BG: #2A1508
```

**Audio:** Distorted waltz. Silverware clinking. Chewing sounds. Waltz speeds up during combat.

## 4.2 Key Mechanics

**Food Hazards:**
- Скользкий пол (spilled oil, grease) — player и enemies скользят
- Boiling pots: Chef может опрокинуть → damage zone (20 dmg/s, 4s)
- Spoiled food zones: poison (3 dmg/s, green tint)

**The Banquet Table:**
- Central massive table в hub room
- Can be used as cover
- Can be flipped (creates barrier)

## 4.3 Floor Layout (11 rooms)

```
[A1] Grand Foyer
  ↓
[A2] Wine Cellar Stairs
  ↓
★ [HUB] The Banquet Hall (massive)
  ├── [B1] Kitchen
  │    └── [B2] Pantry
  ├── [C1] Dessert Chamber (locked)
  │    └── [C2] The Grotto
  └── [D1] Dining Gallery
       └── [D2] Smoke Room
[BOSS] The Gourmand's Table
 └── Exit → Floor 4
```

## 4.4 Room Highlights

### HUB — The Banquet Hall
- **Size:** Very Large (20×16 tiles)
- Massive table down center, chandeliers, golden plates
- Food on table: some fresh, some rotting, some... human
- Enemies: Chef ×1, Taster ×1, Staff ×3, Guard ×1
- Lore: Place cards with names — some with "MAIN COURSE" written

---

# 5. FLOOR 4 — GREED / VAULT

## 5.1 Identity

**Theme:** "Всё имеет цену. Ты тоже."
**Sin:** Жадность
**Fantasy:** Хранилище. Сейфы. Механизмы. Золото везде — но каждое сокровище охраняется ловушкой.

**Palette:**
```
████ #FFD700 Bright gold
████ #5A6A7A Steel blue-grey
████ #1A1A3A Dark navy
████ #C0C8D0 Silver
Blood: #CC2222 | BG: #0E0E1E
```

**Audio:** Ticking. Mechanical clicks. Coin counting machines. Metallic echoes.

## 5.2 Key Mechanics

**Vault Traps:**
- Spike walls: activate by Banker, 30 dmg, 0.5s warning
- Crusher ceilings: 50 dmg, 1.0s warning (shadow grows)
- Lockdown doors: close exits, 4s, Banker must channel
- Laser grids: Floor-specific, contact = 15 dmg + stun

**Safe Deposit Boxes:**
- Interactable: spend 2s to open
- Contain: weapons, ammo, upgrades
- Some are trapped (25%): trigger spike when opened

## 5.3 Floor Layout (10 rooms)

```
[A1] Security Checkpoint
  ↓
[A2] Steel Corridor
  ↓
★ [HUB] The Counting Room
  ├── [B1] Safety Deposit Wing
  │    └── [B2] The Archive
  ├── [C1] Laser Grid Hall (locked)
  │    └── [C2] The Inner Vault
  └── [D1] Gold Storage
       └── [D2] Coin Minting
[BOSS] The Accountant's Office
 └── Exit → Floor 5
```

---

# 6. FLOOR 5 — SLOTH / SPA

## 6.1 Identity

**Theme:** "Расслабься. Навсегда."
**Sin:** Лень
**Fantasy:** Спа. Мрамор. Пар. Вода. Всё говорит: остановись. Отдохни. Сдайся.

**Palette:**
```
████ #3CBEB0 Turquoise
████ #E8F0F0 Pale white
████ #8AABA0 Muted teal
████ #B8D8D0 Seafoam
Blood: #AA2222 | BG: #D0E0E0
```

**Audio:** Droning bass. Water sounds. Heartbeat. Everything slow, soporific. Combat music barely activates.

## 6.2 Key Mechanics

**Steam/Fog:**
- Fog zones: visibility reduced (60% opacity overlay)
- Player speed −30% in fog
- Enemies: Attendants navigate fog normally, Drowned Ones invisible in water

**Water Pools:**
- Large pools on floor — decorative but DANGEROUS
- Drowned One ambush zones
- Player speed −60% in water
- Knocking enemies into water = they regenerate faster

**Sedative Mechanic:**
- Attendant's fog breath + sedative touch = stacking slow
- Max slow = 70% reduction — must break line of sight to recover

## 6.3 Floor Layout (10 rooms)

```
[A1] Reception Lounge
  ↓
[A2] Steam Corridor
  ↓
★ [HUB] The Pool (massive, water)
  ├── [B1] Sauna Wing
  │    └── [B2] Mud Baths
  ├── [C1] Treatment Rooms (locked)
  │    └── [C2] The Surgery
  └── [D1] Relaxation Garden
       └── [D2] Steam Engine Room
[BOSS] Attendant Prime's Sanctuary
 └── Exit → Floor 6
```

---

# 7. FLOOR 6 — WRATH / ARENA

## 7.1 Identity

**Theme:** "Кровь — это развлечение."
**Sin:** Гнев
**Fantasy:** Арена. Клетки. Цепи. Кровь. Зрители (мёртвые, но всё ещё аплодируют). Ты — главное событие.

**Palette:**
```
████ #CC1100 Blood red
████ #B74A0E Rust orange
████ #1A0A0A Near-black
████ #FF5500 Ember orange
Blood: #EE0000 | BG: #0F0505
```

**Audio:** Metal riffs. Rap beats. Crowd chanting (distorted, wrong). Music is MOST aggressive here. Guitar solos during mini-boss.

## 7.2 Key Mechanics

**Arena Waves:**
- Some rooms lock doors → wave-based combat
- 3 waves per arena room, increasing difficulty
- Doors open only after all waves cleared

**Fire Hazards:**
- Pyres and braziers
- Can be knocked over → fire spreads (damage zone, 8 dmg/s)
- Berserker charges through fire (takes damage but doesn't stop)

**No Retreat:**
- Several rooms: one-way doors
- Enter = committed. Must clear to proceed.
- Creates tension spikes

## 7.3 Floor Layout (9 rooms)

```
[A1] Holding Cells
  ↓
[A2] Blood Corridor (one-way)
  ↓
★ [HUB] The Arena Floor
  ├── [B1] Gladiator Pit (one-way, waves)
  │    └── [B2] Armory
  ├── [C1] The Gauntlet (locked, one-way)
  │    └── [C2] Champion's Hall
  └── [D1] Spectator Stands
       └── [D2] Beast Cages
[BOSS] The Arena
 └── Exit → Floor 7
```

---

# 8. FLOOR 7 — ENVY / OBSERVATORY

## 8.1 Identity

**Theme:** "Они смотрят. Они хотят. Они забирают."
**Sin:** Зависть
**Fantasy:** Обсерватория. Звёзды. Телескопы. Библиотеки запрещённых знаний. Тени живые. Невидимые глаза.

**Palette:**
```
████ #1A1A6A Deep indigo
████ #C0C0D0 Silver
████ #4B0082 Purple
████ #E6E6FA Starlight white
Blood: #CC2222 | BG: #0A0A2A
```

**Audio:** Ambient cosmic horror. Ethereal whispers. No beat. Sparse. Sounds arrive late (delayed audio = unsettling).

## 8.2 Key Mechanics

**Stealth Zones:**
- Dark rooms with limited visibility cones (flashlight mechanic?)
- Spy enemies invisible until they attack
- Shadow Stalkers phase through walls
- Player can hide in shadows (reduced detection)

**Surveillance System:**
- Cameras (decorative but functional): if player in camera view → alert enemies
- Can be destroyed (1 hit)
- Destroying camera = alert to nearby enemies

**Darkness:**
- Some rooms very dark
- Player visibility = limited cone in front
- Enemies adapted to darkness — they see YOU
- Light sources reveal Spy/Shadow Stalker

## 8.3 Floor Layout (10 rooms)

```
[A1] Telescope Gallery
  ↓
[A2] Star Map Corridor
  ↓
★ [HUB] The Library
  ├── [B1] Restricted Archives
  │    └── [B2] The Cipher Room
  ├── [C1] Observatory Dome (locked)
  │    └── [C2] Star Chamber
  └── [D1] Shadow Gallery
       └── [D2] The Void Room
[BOSS] The Curator's Study
 └── Exit → Floor 8
```

---

# 9. FLOOR 8 — PRIDE / BALLROOM

## 9.1 Identity

**Theme:** "Совершенство — это клетка из золота."
**Sin:** Гордыня
**Fantasy:** Бальный зал. Хрусталь. Золото. Портреты бессмертных. Идеальные существа в идеальном аду. Элита элиты.

**Palette:**
```
████ #DAA520 Royal gold
████ #F5F5F0 Pure white
████ #8B0000 Blood red
████ #2A2A2A Deep black
Blood: #DD0000 | BG: #1A1A1A
```

**Audio:** Orchestral synth. Waltz + electronic. Elegant but oppressive. Music is "beautiful" — most unsettling because it doesn't match the violence.

## 9.2 Key Mechanics

**Formation Combat:**
- Royal Guards fight in coordinated formations
- 2-4 Guards = shield wall, surround, wedge
- Must break formation (kill/maim one) to create openings

**Elite AI:**
- Enemies here learn from player behavior within the run
- More parries if player uses melee
- Faster flanking if player stands still
- Most intelligent enemies in the game

**Environmental Grandeur:**
- Chandeliers: can be shot down → AoE damage
- Gold fixtures: destructible, drop coins (visual only)
- Portraits: interactive, reveal lore when examined

## 9.3 Floor Layout (10 rooms)

```
[A1] Grand Staircase
  ↓
[A2] Portrait Gallery
  ↓
★ [HUB] The Ballroom (massive)
  ├── [B1] Champagne Hall
  │    └── [B2] Trophy Room
  ├── [C1] Throne Antechamber (locked)
  │    └── [C2] The Golden Chamber
  └── [D1] Crystal Gallery
       └── [D2] The Vault of Faces
[BOSS] The Consort's Ballroom
 └── Exit → Floor 9
```

---

# 10. FLOOR 9 — SATAN'S SANCTUM

## 10.1 Identity

**Theme:** "Реальность — это рекомендация."
**Sin:** Нет (финальный этаж — все грехи одновременно)
**Fantasy:** Санктум. Не место — состояние. Реальность ломается. Белое становится красным. Красное становится чёрным. Ты нашёл её. Она нашла тебя.

**Palette:**
```
Phase 1: ██████ #F0F0F0 Sterile white
Phase 2: ██████ #F0E0E0 Warm flesh
Phase 3: ██████ #1A0A0A Encroaching black
Phase 4: ██████ #FF0000 Pure red → #000000 Void
Blood: shifts with palette
BG: shifts with phases
```

**Audio:** All previous floor styles layered. Industrial + synthwave + waltz + metal + ambient + orchestral — simultaneously. Increasingly discordant. In the Sister encounter: music stops. Silence. Then a heartbeat.

## 10.2 Key Mechanics

**Reality Shift:**
- The floor changes as you progress
- Rooms restructure between visits (subtle layout changes)
- Enemies may appear/disappear
- Colour palette shifts mid-room

**Sister Encounter:**
- Unique narrative-combat sequence
- Not a standard fight — choice-based
- Details in Boss Design Document

**Satan Fight:**
- Reality warping boss
- Floor becomes abstract geometry
- All rules can break
- Details in Boss Design Document

## 10.3 Floor Layout (8 rooms — intentionally smaller)

```
[A1] White Corridor (sterile, wrong)
  ↓
[A2] The Memory Hall (echoes of previous floors)
  ↓
★ [HUB] The Waiting Room (Sister encounter — Phase 1)
  ├── [B1] The Mirror Room (Sister encounter — Phase 2)
  └── [C1] The Throne Approach (locked)
[BOSS 1] The Sister's Chamber (choice encounter)
[BOSS 2] Satan's Sanctum (final boss)
 └── ENDING
```

## 10.4 The Memory Hall (A2)

- Corridor with fragments of ALL previous 8 floors
- Floor 1 pipes on left wall, Floor 2 neon on right
- Floor 3 gold chandelier, Floor 4 steel door
- Floor 5 fog, Floor 6 blood stain
- Floor 7 starlight, Floor 8 gold frame
- Each fragment plays 2 seconds of that floor's audio
- Narrative: the building is remembering itself through you

---

# 11. FLOOR PROGRESSION SUMMARY

| Floor | Rooms | Key Mechanic | Enemy Types | Difficulty |
|-------|-------|-------------|-------------|-----------|
| 1 | 10 | Tutorial, basic combat | Staff, Guard, Handler | ★☆☆☆☆ |
| 2 | 10 | Mirrors, decoys, deception | Seductress, Bodyguard, Cultist | ★★☆☆☆ |
| 3 | 11 | Food hazards, slippery floor, poison | Chef, Taster, Butcher | ★★☆☆☆ |
| 4 | 10 | Traps, vaults, mechanical enemies | Banker, Vault Drone | ★★★☆☆ |
| 5 | 10 | Fog, water, slowing mechanics | Attendant, Drowned One | ★★★☆☆ |
| 6 | 9 | Arena waves, fire, no retreat | Gladiator, Berserker | ★★★★☆ |
| 7 | 10 | Stealth, darkness, surveillance | Spy, Shadow Stalker, Cultist | ★★★★☆ |
| 8 | 10 | Formation combat, elite AI | Royal Guard, Champion | ★★★★★ |
| 9 | 8 | Reality shift, narrative encounters | Demon, The Sister | ★★★★★+ |

**Total rooms: ~88 rooms across 9 floors**

---

# 12. ENVIRONMENTAL STORYTELLING PER FLOOR

| Floor | Story It Tells |
|-------|---------------|
| 1 | Where the bodies go. The logistics of death. Processing. |
| 2 | How desire is weaponised. Seduction as control. |
| 3 | Consumption without satisfaction. Gluttony as metaphor for exploitation. |
| 4 | Everything has a price. Even life. Especially life. |
| 5 | The illusion of comfort. Relaxation as surrender. |
| 6 | Violence as entertainment. The elite watch from above. |
| 7 | Envy of the living. The dead want what you have. |
| 8 | Perfection is tyrannical. Beauty as prison. |
| 9 | The truth. The centre. The price of immortality. |
