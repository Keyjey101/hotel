# ENDING TRIGGERS SPEC — HOTEL
## Version 1.0

> Точная спека для CODER-3: RunState flags, trigger conditions, edge cases.
> Концовки взаимно эксклюзивны.

---

# 1. RUNSTATE FLAGS

```gdscript
# Added to RunState (run_state.gd)
var flag_sister_damaged: bool = false       # Any damage dealt to Sister
var flag_sister_killed: bool = false        # Sister torso HP reached 0
var flag_sister_spared: bool = false        # Sister HP <10%, player stopped attacking
var flag_sister_never_attacked: bool = true # Remains true ONLY if zero damage dealt
var flag_sister_embraced: bool = false      # Player approached without weapon in Phase 2
var flag_satan_offer_accepted: bool = false # Player chose "Accept" in Satan's final dialog
var flag_satan_killed: bool = false         # Satan torso HP reached 0
var sister_total_damage_dealt: float = 0.0  # Running total of all damage to Sister
var sister_encounter_phase: int = 0         # 0=not started, 1=recognition, 2=confrontation, 3=resolution
```

---

# 2. ENDING DEFINITIONS

## Ending A — LIBERATION (Освобождение)

```
condition:
  flag_sister_killed == true
  flag_satan_killed == true
  flag_satan_offer_accepted == false

trigger_sequence:
  1. Sister fight → torso HP = 0 → flag_sister_killed = true
  2. Sister death quote: "I forgive you."
  3. Path to Satan opens.
  4. Satan fight → torso HP = 0 (Phase 3, after rejecting final offer)
  5. Satan collapses → flag_satan_killed = true
  6. Hotel collapse sequence.
  7. Ending A plays.

narrative:
  "The Hotel is gone. The system is destroyed. But the memory remains.
   Her face, at the end. She forgave you. You're not sure you forgive yourself."

tone: Hollow victory. Necessary evil.
```

## Ending B — SPARE (Спасение)

```
condition:
  flag_sister_spared == true
  flag_sister_killed == false
  flag_satan_killed == true
  flag_satan_offer_accepted == false

trigger_sequence:
  1. Sister fight → Sister HP drops below 10% of max.
  2. Sister pauses, HP bar turns blue (invulnerable).
  3. Sister says: "You came for me. You're still you."
  4. Player must STOP attacking for 3 seconds (no attack input).
  5. After 3s calm → flag_sister_spared = true.
  6. Sister joins player as ally for Satan fight.
  7. Satan fight → Sister assists (unique co-op mechanics).
  8. Satan defeated → flag_satan_killed = true.
  9. Ending B plays.

special_mechanic:
  - If player attacks Sister during the 3s calm window, she dies → switches to Ending A path.
  - Sister as ally: mirrors player's weapon, deals 50% of player damage, draws aggro.
  - Satan Phase 3: Sister intervenes, blocks Final Offer dialog — forces combat resolution.

narrative:
  "The Hotel is gone. She's not the same. Neither are you.
   But you're together. That has to be enough."

tone: Bittersweet hope. True ending.
```

## Ending C — TRUTH (Истина)

```
condition:
  flag_sister_never_attacked == true
  flag_sister_total_damage_dealt == 0.0
  flag_sister_killed == false
  flag_sister_spared == false  # Never entered combat at all
  flag_sister_embraced == false

trigger_sequence:
  1. Sister encounter begins → Phase 1 (Recognition).
  2. Player must NEVER press attack (ЛКМ) or throw_weapon (ПКМ) while Sister is in the room.
  3. Any thrown weapon that hits Sister sets flag_sister_damaged = true and voids this ending.
  4. Sister progresses through her dialog naturally (no combat trigger).
  5. After dialog completes → Sister reveals the truth (player's own contract).
  6. Path to Satan opens. Sister does NOT join (she stays, shocked by revelation).
  7. Satan fight → alone.
  8. Satan defeated → Ending C plays.

verification_check (run continuously during Sister encounter):
  if Input.is_action_just_pressed("attack") and sister_in_room:
      flag_sister_never_attacked = false
  if Input.is_action_just_pressed("throw_weapon") and thrown_weapon_hits_sister:
      flag_sister_never_attacked = false
      flag_sister_damaged = true

important:
  - "Never attacked" means ZERO damage. Not "chose not to finish her."
  - AOE attacks that hit Sister also void this (cleaver sweep, pot explosion if it clips her).
  - Environmental hazards triggered by player that hit Sister also void this.
  - Satan fight still happens. Player still needs to kill Satan.
  - Void Contract (A12) does NOT block this ending.

narrative:
  "You came here to save her. But you were never outside. You were always inside.
   The Hotel doesn't have guests. It has inmates. And you... you were the first."

tone: Cosmic horror. Identity destruction.
```

## Ending D — ASCENSION (Восхождение)

```
condition:
  flag_satan_offer_accepted == true

trigger_sequence:
  1. Satan Phase 3 → HP drops to 10%.
  2. Satan pauses fight. Dialog prompt appears:
     "Join the board. End this."
     [ACCEPT] / [REJECT]
  3. Player selects ACCEPT → flag_satan_offer_accepted = true.
  4. Screen fades to white.
  5. Ending D plays. No more combat.

important:
  - Accept is available regardless of Sister outcome.
  - Sister killed + Accept = Ending D (Sister's death was for nothing).
  - Sister spared + Accept = Ending D (betrayal).
  - Sister never attacked + Accept = Ending D (the truth is irrelevant).

narrative:
  "The Hotel continues. The blood flows. The system perpetuates.
   But now... you're the one signing the contracts.
   Was it worth it? You'll have eternity to decide."

tone: Dark irony. You became the monster.
```

---

# 3. EDGE CASE MATRIX

| Sister state | Satan final offer | Ending | Notes |
|-------------|-------------------|--------|-------|
| Killed | Reject + Kill | **A** | Canonical Liberation |
| Killed | Accept | **D** | Sister died for nothing |
| Killed | Reject + Die | Game Over | No ending, run failed |
| Spared | Reject + Kill (with Sister help) | **B** | True ending |
| Spared | Accept | **D** | Betrayal of Sister's trust |
| Spared | Reject + Die | Game Over | Sister watches you fail |
| Never attacked (0 dmg) | Reject + Kill | **C** | Truth revealed |
| Never attacked (0 dmg) | Accept | **D** | Truth is irrelevant |
| Never attacked (0 dmg) | Reject + Die | Game Over | |
| Embraced (stabbed, survived) | — (bypass Satan) | **D** | Accept via embrace. Becomes part of Hotel. |
| Embraced (stabbed, died) | — | Game Over | HP was ≤50% at embrace, stab killed you |
| Damaged but not killed (player stopped above 10%) | Reject + Kill | **A** | Treated as "killed" — you fought her |
| Damaged but not killed (player stopped above 10%) | Accept | **D** | |
| Killed Sister + Have Void Contract | Reject + Kill | **A** | Void Contract doesn't change ending, only gameplay |

---

# 4. PRIORITY RULE (Mutual Exclusivity)

```
func resolve_ending(run_state: RunState) -> String:
    # D takes absolute priority — if you accepted the offer, that's it.
    if run_state.flag_satan_offer_accepted:
        return "D"

    # Must have killed Satan for A/B/C.
    if not run_state.flag_satan_killed:
        return "GAME_OVER"  # Died at Satan, no ending

    # C requires zero damage to Sister.
    if run_state.flag_sister_never_attacked and run_state.sister_total_damage_dealt == 0.0:
        return "C"

    # B requires Sister spared.
    if run_state.flag_sister_spared and not run_state.flag_sister_killed:
        return "B"

    # A requires Sister killed.
    if run_state.flag_sister_killed:
        return "A"

    # Fallback (should not reach in normal play)
    return "GAME_OVER"
```

**Key rule:** Ending D overrides all others. If you accept Satan's offer, nothing else matters.

---

# 5. WHEN FLAGS ARE SET

| Flag | Set When | Set By | Irreversible? |
|------|----------|--------|---------------|
| `sister_damaged` | Any damage dealt to Sister | DamageSystem.apply_damage | Yes |
| `sister_never_attacked` | Set to `false` on first damage | DamageSystem or throw check | Yes (one-way) |
| `sister_killed` | Sister torso HP = 0 | Sister's death handler | Yes |
| `sister_spared` | Sister HP <10% AND 3s no-attack timer completes | Sister encounter script | Yes |
| `sister_embraced` | Player approaches Sister in Phase 2 without weapon equipped | Sister encounter proximity check | Yes |
| `satan_offer_accepted` | Player selects ACCEPT in final dialog | Dialog UI callback | Yes |
| `satan_killed` | Satan torso HP = 0 | Satan's death handler | Yes |

---

# 6. SISTER ENCOUNTER PHASES (Flag Triggers)

## Phase 1 — Recognition (0-30s after entering room)

- Sister stands in center. Dialog begins.
- No combat possible — Sister has `invulnerable = true`.
- Sister says: "You came."
- Flags: `sister_encounter_phase = 1`.
- After dialog → Phase 2.

## Phase 2 — Confrontation (player choice moment)

- Sister: "I was like you once. Then I understood."
- Three visual prompts appear:
  - [ЛКМ] Fight (draws weapon, combat begins)
  - [E] Listen (continues dialog, no combat)
  - [Walk to her without weapon] Embrace (approach empty-handed)
- Flags: `sister_encounter_phase = 2`.
- **Fight:** → Sister becomes vulnerable → combat. First hit sets `sister_damaged = true`, `sister_never_attacked = false`.
- **Listen:** → Phase continues to truth reveal → no combat → `sister_encounter_phase = 3` → path to Satan opens.
- **Embrace:** → Sister stabs player (flat 50% max HP damage) → if player survives → `sister_embraced = true` → Ending D path.

## Phase 3 — Resolution (combat or dialog outcome)

- If fighting: HP <10% → Sister pauses → spare window.
- If listening: Truth revealed → path to Satan.
- If embracing: Stab resolved → Ending D or Game Over.

---

# 7. DIALOG CHOICES AND UI

| Moment | Prompt | Choices | Effect |
|--------|--------|---------|--------|
| Sister Phase 2 | "What will you do?" | Fight / Listen / Embrace | Sets encounter path |
| Sister <10% HP | "Please..." | Stop attacking (3s) / Keep attacking | Spare vs Kill |
| Satan <10% HP | "Join the board." | Accept / Reject | Ending D vs combat |
| Post-Satan (if B) | None (automatic) | — | Sister helps, Ending B |

All dialogs are modal (game paused). Player must choose. No timeout.
