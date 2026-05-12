# ONBOARDING SPEC — HOTEL
## Version 1.0

> Как игрок учится играть. Без текстовых tooltip — визуально и через gameplay.

---

# 1. ПЕРВАЯ КОМНАТА — ENTRY SHAFT (Floor 1, Room A1)

## 1.1 What the Player Sees

```
┌─────────────────────────────────────────┐
│                                         │
│   [Ladder from above]                   │
│        │                                │
│        │  ┌──────┐                      │
│        └──│Player│  (standing start)    │
│           └──────┘                      │
│                                         │
│   [Table]                               │
│    └── Мачете (glowing pickup)          │
│    └── Обрез (second slot, dimmer)      │
│                                         │
│   [STAFF ONLY sign — flickering light]  │
│                                         │
│   ──────→ Exit door (closed, red)       │
│                                         │
└─────────────────────────────────────────┘
Size: 8×6 tiles. Safe room. Zero enemies.
```

**Design intent:** Player spawns in a calm space. Weapons on the table are unmissable. Door is visible but locked until both weapons picked up.

## 1.2 Pickup Sequence

1. Player moves toward table (WASD — natural).
2. Glow on machete → E prompt appears (floating icon, not text).
3. Pick up machete → weapon icon appears top-left HUD.
4. Pick up sawed-off → second slot fills.
5. Door turns from red → green. Opens.

**No text.** The glow + HUD update + door change teaches the pickup mechanic.

---

# 2. THREE TUTORIAL POP-UPS

## Pop-up 1: ATTACK (triggered in Room A2 — Service Corridor)

```
trigger: Player enters A2 and approaches first Staff enemy (within 120px)
format:  Single icon overlay (not a text box):
         [ЛКМ icon] → [sword swing animation, 2 frames]
         Appears at bottom-center of screen.
         Fades after 2 seconds OR after first attack input.

what it teaches: Left click = attack.
why here: First enemy visible. Natural "what do I do?" moment.
duration: 2s max (or dismissed on first attack)

visual mockup:
┌─────────────────────────────────────┐
│                                     │
│     [Staff enemy ahead]             │
│                                     │
│                                     │
│       ┌──────────────┐              │
│       │ 🖱️ЛКМ → ⚔️   │              │
│       └──────────────┘              │
│                                     │
└─────────────────────────────────────┘
```

## Pop-up 2: THROW (triggered in Room A2 after first kill)

```
trigger: First enemy collapses in A2
format:  [ПКМ icon] → [weapon flying arc animation, 3 frames]
         Appears bottom-center.
         Fades after 3 seconds OR after first throw input.

what it teaches: Right click = throw weapon.
why here: Player just killed, has weapon. Natural experiment moment.
duration: 3s max (or dismissed on first throw)

edge case: If player throws before pop-up → pop-up does not appear (already learned).
```

## Pop-up 3: INTERACT (triggered at first locked door — Boiler Room HUB)

```
trigger: Player stands within 40px of key-locked door for the first time
format:  [E key icon] → [door opening animation, 2 frames]
         Appears above the door itself (world-space, not HUD).
         Fades after 3 seconds OR on E press.

what it teaches: E = interact / open / pick up.
why here: First locked door. Natural barrier.
duration: 3s max (or dismissed on interact)

note: This door requires the KEY from B2/D2. The pop-up teaches E.
      The locked state teaches "explore for key" visually (keyhole glows).
```

---

# 3. DISMEMBERMENT INTRODUCTION

## 3.1 Where: Laundry Room (B1)

After the HUB, the first branch room (B1) is the dismemberment tutorial.

## 3.2 Setup

```
Room B1 — Laundry Room:
- 3 Staff enemies.
- First Staff is special: "Training Staff"
  - Spawns 120px from door, facing away from player.
  - Does NOT attack for first 5 seconds (stands still, scrubbing machine).
  - HP: same as normal Staff.
  - Visual cue: slightly different tint (dim, tired).

Why facing away: Player has time to approach and hit without pressure.
Why 5 seconds: Enough to hit 2-3 times, see limb fly off, understand the mechanic.
```

## 3.3 What Happens

1. Player enters B1. Training Staff is scrubbing machine, back turned.
2. Player attacks (already learned from pop-up 1).
3. First hit: arm HP depletes. Blood splash. Staff drops weapon.
4. Second hit: arm severs. **Limb flies off** (physics object). Staff screams.
5. GoreSystem spawns: blood pool on floor, severed arm as physical object.
6. Staff turns around, screams → runs toward player but missing arm.
7. Player sees: missing arm = can't hold weapon = less dangerous.
8. Other 2 Staff hear scream → alert → enter room.

**The lesson:** Calceling = tactical. Arms disable weapons. Legs disable movement.

## 3.4 Visual Teaching (No Text)

The game teaches dismemberment through:

| Visual Cue | What It Teaches |
|------------|----------------|
| Arm flies off + enemy drops weapon | Arms = weapon capability |
| Enemy limping after leg hit | Legs = movement |
| Blood pool on floor | Damage is permanent (visual feedback) |
| Regeneration animation (flesh growing back, ~30s) | They recover — time pressure |
| Training Staff not attacking for 5s | Safe space to experiment |
| Enemy running away with 1 leg | Mutilated enemies change behavior |

---

# 4. VISUAL TEACHING (No Tooltip Required)

These mechanics are learned through observation:

## 4.1 Weapon Economy

- Weapons on ground glow when nearby → "pick me up" (E key already learned).
- Dropped weapon from enemy → auto-highlight → pickup available.
- Thrown weapon sticks in wall/floor → can be retrieved (same glow).
- 2 weapon slots shown on HUD → when both full, pickup swaps current.

## 4.2 Regeneration

- First wounded enemy in B1: flesh visibly growing back (animated).
- Sound: wet organic sound during regen.
- Visual: limb gradually reforming over 30 seconds.
- **No text needed.** Player sees it happen and understands the threat.

## 4.3 Grab / Capture

- First Guard in HUB (Boiler Room) attempts grab.
- Visual: Guard reaches → if connects → player slowed 70%.
- Player sees "mash to break free" prompt: 3 rapid flashing [E] icons around player.
- No text. Just the button flashing.

## 4.4 Route Gates

- HUB has 3 doors. 1 is red/blocked, 2 are green/open.
- Visual: blocked door has chain + lock. Open door has light.
- **No text.** Color + visual state communicates everything.

## 4.5 Health / Damage

- HP bar top-left. Goes down on hit. Red flash on screen edge.
- When HP = 0: screen goes red → "CAPTURED" text → basement loads.
- No tutorial needed. Dying = learning.

---

# 5. FLOOR 1 COMPLETE ONBOARDING SEQUENCE

| Room | What's Taught | Method |
|------|---------------|--------|
| A1 (Entry Shaft) | Movement, weapon pickup | Weapons on table, door opens on pickup |
| A2 (Service Corridor) | Attack, basic combat | Pop-up 1 (ЛКМ), first Staff kill |
| A2 (after kill) | Throw weapon | Pop-up 2 (ПКМ), post-kill experiment |
| B1 (Laundry Room) | Dismemberment | Training Staff (5s passive), limb sever |
| B1 (regen) | Regeneration | Wounded enemy regenerates visibly |
| B2/D2 (loot rooms) | Exploration = reward | Key pickup, stat upgrade on ground |
| C1 (Meat Processing) | Handler threat | First grab attempt, break-free |
| HUB (Boiler Room) | Route gates, branching | 2 of 3 doors open, key lock |
| BOSS (Kitchen) | Boss pattern, phases | Head Chef — first multi-phase encounter |

**Total "tutorial" time: ~2-3 minutes** (A1 through B1). After that, player has all core mechanics.

---

# 6. WHAT WE DO NOT TEACH (Discovery)

These are left for player to discover:

| Mechanic | Why No Tutorial |
|----------|----------------|
| Improvised weapons (bottles, chairs, limbs) | Discovery is reward |
| Blood pool interactions | Environmental, learned naturally |
| Cult artifact trade-offs | Explicit UI popup on pickup (not tutorial) |
| Basement escape | Occurs on first death — experiential |
| Weapon-specific throw effects | Each weapon is different — experimentation |
| Enemy coordination patterns | Learned through failure and observation |
| Secret rooms/alcoves | Hidden by design |

---

# 7. ACCESSIBILITY NOTES

- All pop-ups use icons, not text. Language-independent.
- Pop-ups are brief (2-3s) and dismissable via action.
- Pop-ups never repeat (flagged in RunState once shown).
- No unskippable tutorial sequence. Player can rush past pop-ups.
- Training Staff's 5s grace period is forgiving but not forced.
