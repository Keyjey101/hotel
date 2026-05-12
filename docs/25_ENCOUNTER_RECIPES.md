# ENCOUNTER RECIPES — HOTEL
## Version 1.0

> Reusable spawn-pattern library. Every recipe is floor-agnostic; enemies
> listed under "Cast" are suggested types — swap with floor-appropriate
> equivalents from `11_ENEMY_DESIGN.md`.
>
> Cross-referenced by `26_FLOOR_MANIFESTS.md` / `docs/floors/floor_XX_manifest.md`.

---

## Recipe Index

| # | Name | Core Idea | Primary Floors |
|---|------|-----------|---------------|
| 01 | Ambush | 1 visible, N from dark on entry | 1, 2, 5, 7 |
| 02 | Chokepoint | Corridor + ranged behind cover | 1, 4, 6 |
| 03 | Crossfire | 2 ranged corners + 1 melee center | 2, 4, 8 |
| 04 | Shield Wall | Defenders block, support buffs behind | 2, 8 |
| 05 | Decoy Trap | Weak bait, flankers in shadow | 2, 7 |
| 06 | Swarm | 4-5 weak rush from one direction | 1, 3 |
| 07 | Pincer | Two groups attack from opposite sides | 3, 6, 8 |
| 08 | Hunter's Den | Grab specialist waits; melee push toward it | 1, 3, 5 |
| 09 | Grenade Alley | Ranged on elevation, area hazards | 4, 6 |
| 10 | Kill Box | Surround 4 sides, 1 elite at exit | 6, 8 |
| 11 | Turtle | Defender + ranged behind, slow push | 2, 4, 8 |
| 12 | Bait and Switch | 1 flees into room with 3 more | 1, 2, 5 |
| 13 | Phalanx | 3 formation fighters line + 1 support | 6, 8 |
| 14 | Lurking Horror | Ambusher hidden, 2 visible distract | 5, 7 |
| 15 | Rage Gauntlet | Berserker charges, hazards channel movement | 3, 6 |
| 16 | Trap Combo | Env trap + enemies exploit trap zones | 4 |
| 17 | Elite Escort | Elite + guards; kill guards to expose | 7, 8 |
| 18 | Poison Garden | Zone creators overlap coverage | 3, 5 |
| 19 | Darkness Falls | Lights off on entry, spawns in dark | 7 |
| 20 | Wave Gate | Doors lock, 2-3 waves, unlock on clear | 6 |

---

## Recipe Details

### 01 — Ambush

**Concept:** Player sees one enemy patrolling openly. When player enters the
room (crosses threshold tile), N additional enemies spawn from shadow corners /
behind furniture.

| Element | Detail |
|---------|--------|
| Trigger | Player enters tile row 2 from any door |
| Visible enemy | 1× weak type (Staff), patrol path centre |
| Ambush spawns | 2-3× floor-appropriate, positions: far corners |
| Delay | 0.6s after trigger, simultaneous spawn |
| Audio cue | Subtle "whoosh" per spawn |
| Cast (suggested) | Staff, Guard, Spy, Drowned One |
| Floors | 1, 2, 5, 7 |

**CODER notes:**
- Spawn-point list stored in room config; `_on_player_entered` signal triggers.
- Ambush enemies start in `HIDDEN` state → 0.3s fade-in animation → `CHASE`.

---

### 02 — Chokepoint

**Concept:** Narrow corridor (4-6 tiles wide). One ranged enemy behind
destructible cover at the far end. Melee enemies push from behind the player
after a short delay.

| Element | Detail |
|---------|--------|
| Layout | Corridor, 12-16×4 tiles |
| Cover | Destructible crate/counter, HP 40, at far end |
| Ranged | 1× Cultist / Banker / Guard (pistol), behind cover |
| Melee push | 2× melee, spawn 2s after player is 50%+ through corridor |
| Environmental | Optional steam/fire hazard on one wall |
| Cast | Guard, Cultist, Banker, Vault Drone |
| Floors | 1, 4, 6 |

**CODER notes:**
- Cover is a `StaticBody2D` with HP meta; destroyed → ranged repositions.
- Melee push spawns behind player's entry door.

---

### 03 — Crossfire

**Concept:** Two ranged enemies in opposite corners, one melee enemy patrolling
centre. Player must advance while dodging projectiles from two angles.

| Element | Detail |
|---------|--------|
| Layout | Chamber or gallery, 10-12×8-10 tiles |
| Ranged positions | (2, 2) and (W-3, H-3) — diagonal corners |
| Melee | 1× patrol centre, engages on sight |
| Cover | 2-3 destructible obstacles mid-room |
| Cast | Cultist, Guard (pistol), Bodyguard, Royal Guard (crossbow) |
| Floors | 2, 4, 8 |

---

### 04 — Shield Wall

**Concept:** Two defenders form a wall (shoulder-to-shoulder), blocking access
to a priority support target behind them. Must break formation by killing /
maiming one.

| Element | Detail |
|---------|--------|
| Layout | Medium room, single approach lane |
| Defenders | 2× Bodyguard / Royal Guard, side by side |
| Support | 1× Seductress / Cultist / Attendant, 4 tiles behind wall |
| Reinforcement | If support alive > 20s, summons +1 Staff |
| Counter | Kill one defender → gap → flank support |
| Cast | Bodyguard, Royal Guard, Seductress, Cultist, Attendant |
| Floors | 2, 8 |

---

### 05 — Decoy Trap

**Concept:** One weak enemy stands in plain sight, acting "lost" (slow patrol,
no alert). When player approaches within 5 tiles, 2 flankers decloak from
opposite walls.

| Element | Detail |
|---------|--------|
| Bait | 1× Staff / Spy (visible, low aggression) |
| Flankers | 2× Spy / Shadow Stalker, start invisible |
| Trigger radius | 5 tiles (160 px) from bait |
| Delay | 0.4s decloak, then immediate CHASE |
| Audio | Glass-breaking sound on decloak |
| Cast | Staff, Spy, Shadow Stalker |
| Floors | 2, 7 |

---

### 06 — Swarm

**Concept:** 4-5 weak enemies rush the player from a single direction (doorway,
stairwell, etc.). Pure numbers, low individual threat. Teaches AoE / crowd
control.

| Element | Detail |
|---------|--------|
| Spawn | 4-5× Staff, single doorway, staggered 0.3s apart |
| Behaviour | Rush straight to player, no coordination |
| Group bonus | If 4+ alive simultaneously: +4 Aggression (courage) |
| Counter | Throw weapon into group, AoE, choke-point door |
| Cast | Staff |
| Floors | 1, 3 |

---

### 07 — Pincer

**Concept:** Two groups attack from opposite sides. One group is melee-heavy
(the "hammer"), the other is ranged (the "anvil"). Player must break one side
quickly.

| Element | Detail |
|---------|--------|
| Layout | Gallery or hub, two entry points |
| Group A (hammer) | 2× melee (Butcher / Berserker / Gladiator) |
| Group B (anvil) | 1-2× ranged (Cultist / Guard pistol) |
| Timing | Both groups alert simultaneously |
| Cast | Butcher, Berserker, Gladiator, Cultist, Guard |
| Floors | 3, 6, 8 |

---

### 08 — Hunter's Den

**Concept:** One grab specialist (Handler / Drowned One) waits in a corner.
Two melee enemies push the player toward the grabber. If grabbed, player is
dragged toward a hazard.

| Element | Detail |
|---------|--------|
| Grabber | 1× Handler / Drowned One, far corner, stationary until player < 80px |
| Pushers | 2× Guard / Staff, approach from entry side |
| Hazard | Environmental (fire / water / spikes) near grabber |
| Counter | Kill pushers first → space → deal with grabber |
| Cast | Handler, Drowned One, Guard, Staff |
| Floors | 1, 3, 5 |

---

### 09 — Grenade Alley

**Concept:** Ranged enemies on elevated positions (platforms / balconies).
Area-denial hazards (fire, acid, oil) force player to take cover. Destructible
cover degrades over time.

| Element | Detail |
|---------|--------|
| Layout | Tall room with 1-2 raised platforms |
| Ranged | 2× Chef / Banker / Guard, elevated |
| Hazards | Chef's oil slick / Banker's trap trigger / fire brazier |
| Cover | 2× destructible crate, HP 30 each |
| Cast | Chef, Banker, Guard, Vault Drone |
| Floors | 4, 6 |

---

### 10 — Kill Box

**Concept:** Enemies positioned on all four walls. One elite guards the exit.
Player enters from one side; all doors lock for duration.

| Element | Detail |
|---------|--------|
| Layout | Square, 12×12 or larger |
| N/S/E/W enemies | 1× each wall (mix of ranged + melee) |
| Elite at exit | 1× Gladiator / Champion / Royal Guard |
| Lock duration | Until all enemies collapsed or elite killed |
| Cast | Gladiator, Champion, Royal Guard, Guard, Cultist |
| Floors | 6, 8 |

---

### 11 — Turtle

**Concept:** A single heavy defender slowly advances toward the player. Behind
it, 1-2 ranged enemies fire over its head. Must either flank or throw weapons
over/around the defender.

| Element | Detail |
|---------|--------|
| Defender | 1× Bodyguard (shield up) / Royal Guard (halberd sweep) |
| Ranged | 1-2× Cultist / Guard (pistol), 6 tiles behind defender |
| Advance speed | 40 px/s — slow but inexorable |
| Counter | Throw weapon over shield, flank, or destroy shield (HP 60) |
| Cast | Bodyguard, Royal Guard, Cultist, Guard |
| Floors | 2, 4, 8 |

---

### 12 — Bait and Switch

**Concept:** One enemy stands near the entry door, sees player, and FLEES
through a door into the next room. If player follows, they enter a room with
3 enemies already in position.

| Element | Detail |
|---------|--------|
| Bait | 1× Staff, flees on sight (high speed) |
| Trap room | 3× mixed enemies, pre-positioned |
| Player choice | Chase (enter trap) or find alternate route |
| Loot | Trap room has guaranteed rare loot |
| Cast | Staff, Seductress, Attendant, Guard |
| Floors | 1, 2, 5 |

---

### 13 — Phalanx

**Concept:** Three formation-fighting enemies (Royal Guards / Gladiators) in a
line. One support enemy (Cultist) buffs them from behind. Formation must be
broken before the support can be reached.

| Element | Detail |
|---------|--------|
| Formation | Line: 3× Royal Guard / Gladiator, shoulder to shoulder |
| Support | 1× Cultist, 6 tiles behind centre |
| Buff | Cultist chant: +20% speed + damage to all 3 |
| Counter | Throw weapon / shoot past formation to hit Cultist, or flank |
| Cast | Royal Guard, Gladiator, Cultist |
| Floors | 6, 8 |

---

### 14 — Lurking Horror

**Concept:** Two visible enemies distract the player. One ambusher is hidden
(in water, shadow, behind mirror) and attacks when player is committed to
fighting the visible pair.

| Element | Detail |
|---------|--------|
| Visible | 2× any type, normal patrol/engage |
| Hidden | 1× Drowned One (in water) / Spy (invisible) / Shadow Stalker (phased) |
| Trigger | Player damages one visible enemy OR player HP < 70% |
| Attack | Grab from behind / backstab / shadow claw |
| Cast | Drowned One, Spy, Shadow Stalker |
| Floors | 5, 7 |

---

### 15 — Rage Gauntlet

**Concept:** A Berserker (or any rage-scaling enemy) in a room with narrow
corridors and hazards that funnel movement. The more you maim it, the faster
and deadlier it becomes — but the corridors make dodging harder.

| Element | Detail |
|---------|--------|
| Layout | Zig-zag corridor or pillar room |
| Enemy | 1× Berserker (gains +30% speed/damage per lost limb) |
| Hazards | Fire braziers (knock into path), narrow gaps |
| Counter | Reduce torso HP to 0 (collapse) — DON'T maim limbs |
| Environmental | Knock brazier → fire → blocks Berserker charge |
| Cast | Berserker |
| Floors | 3, 6 |

---

### 16 — Trap Combo

**Concept:** Environmental trap (spike wall, crusher, laser grid) is activated
by a Banker / mechanism. Enemies are positioned to exploit the trap zone —
they wait on the safe side and attack as the player dodges.

| Element | Detail |
|---------|--------|
| Trap | 1× spike wall / crusher / laser grid (floor-specific) |
| Trap activator | Banker clicks pocket watch OR pressure plate |
| Enemies | 2× Vault Drone / Guard, positioned OUTSIDE trap zone |
| Sequence | Trap activates → player dodges into enemy cluster |
| Counter | Kill Banker first (stops trap), or throw weapon at trap trigger |
| Cast | Banker, Vault Drone, Guard |
| Floors | 4 |

---

### 17 — Elite Escort

**Concept:** An elite enemy (Champion / Handler) is flanked by 2 guards.
The guards intercept attacks (Bodyguard protect behaviour). Must kill guards
first to expose the elite.

| Element | Detail |
|---------|--------|
| Elite | 1× Champion / Handler, centre-back |
| Escorts | 2× Guard / Royal Guard, flanking sides |
| Escort behaviour | Intercept attacks aimed at elite, shield / block |
| When escorts die | Elite enrages (+3 Aggression, faster attacks) |
| Cast | Champion, Handler, Guard, Royal Guard |
| Floors | 7, 8 |

---

### 18 — Poison Garden

**Concept:** Enemies that create persistent damage zones (Taster, Chef, Attendant)
are positioned so their zones overlap, creating lethal "no-go" areas.

| Element | Detail |
|---------|--------|
| Layout | Open chamber, 10-12×8 tiles |
| Zone creators | 2× Taster / Chef, positioned at ⅓ and ⅔ width |
| Overlap | Central area = double-stacked poison/fire/slow |
| Melee | 1× pushes player toward overlap zone |
| Counter | Kill zone creators from range, avoid centre |
| Cast | Taster, Chef, Attendant |
| Floors | 3, 5 |

---

### 19 — Darkness Falls

**Concept:** Room starts lit. When player enters, lights cut out (1s fade to
near-black). Enemy spawns are revealed only when they attack. Limited light
sources (2-3 candles) can be lit by interacting.

| Element | Detail |
|---------|--------|
| Trigger | Player crosses room threshold |
| Darkness | ColorRect overlay, alpha 0.8, 1s fade |
| Enemies | 2× Spy + 1× Shadow Stalker, invisible in dark |
| Light sources | 2-3 interactable candles / lanterns, 2s channel to light |
| Light radius | 80 px per source, reveals enemies |
| Audio | Dripping water, distant whisper loop |
| Cast | Spy, Shadow Stalker |
| Floors | 7 |

---

### 20 — Wave Gate

**Concept:** Doors lock on entry. Three waves of enemies spawn from side
alcoves. Each wave is harder. Doors unlock after final wave cleared.

| Element | Detail |
|---------|--------|
| Trigger | Player enters room centre |
| Wave 1 | 2× weak (Staff / Guard), spawn from left alcove |
| Wave 2 | 2× medium (Butcher / Attendant) + 1× weak, spawn from right alcove |
| Wave 3 | 1× elite (Gladiator / Berserker) + 2× medium, spawn from both alcoves |
| Inter-wave | 3s pause, health pickup spawns |
| Lock | Until wave 3 cleared |
| Cast | Any — floor-appropriate scaling |
| Floors | 6 (primary), can be used on any floor with adapted enemy types |

---

## Recipe → Floor Assignment Matrix

| Recipe | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9 |
|--------|----|----|----|----|----|----|----|----|-----|
| 01 Ambush | x | x | | | x | | x | | |
| 02 Chokepoint | x | | | x | | x | | | |
| 03 Crossfire | | x | | x | | | | x | |
| 04 Shield Wall | | x | | | | | | x | |
| 05 Decoy Trap | | x | | | | | x | | |
| 06 Swarm | x | | x | | | | | | |
| 07 Pincer | | | x | | | x | | x | |
| 08 Hunter's Den | x | | x | | x | | | | |
| 09 Grenade Alley | | | | x | | x | | | |
| 10 Kill Box | | | | | | x | | x | |
| 11 Turtle | | x | | x | | | | x | |
| 12 Bait and Switch | x | x | | | x | | | | |
| 13 Phalanx | | | | | | x | | x | |
| 14 Lurking Horror | | | | | x | | x | | |
| 15 Rage Gauntlet | | | x | | | x | | | |
| 16 Trap Combo | | | | x | | | | | |
| 17 Elite Escort | | | | | | | x | x | |
| 18 Poison Garden | | | x | | x | | | | |
| 19 Darkness Falls | | | | | | | x | | |
| 20 Wave Gate | | | | | | x | | | x |

---

## CODER Integration Notes

Each room manifest references recipes by number:
```
recipe: 01  # Ambush
```

**Implementation approach:**
1. Each recipe maps to a function in `encounter_recipes.gd` (to be created).
2. Function receives `room_config` + variant params (enemy types, positions).
3. Called by `RoomInstance._setup_encounter()` after room geometry is placed.
4. Recipe handles: spawn timing, trigger zones, wave logic, door locks.
5. All recipes are deterministic given the same seed (no hidden randomness).
