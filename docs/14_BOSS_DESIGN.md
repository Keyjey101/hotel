# BOSS DESIGN DOCUMENT — HOTEL
## Version 1.0

---

# 1. BOSS DESIGN PHILOSOPHY

## 1.1 Principles

- **Mutilation works on bosses** — но иначе. Bosses имеют БОЛЬШЕ HP per limb, и losing limb меняет phase
- **Phases, not health gates** — bosses don't просто получают больше HP. Каждый phase = новые механики
- **Pattern variation** — каждый run, boss выбирает patterns из pool. Не один scripted sequence
- **No damage sponge** — bosses = puzzle + execution, не "бей 5 минут"
- **Thematic coherence** — boss fight = narrative moment, не просто combat encounter

## 1.2 Boss Damage Model

Bosses используют modifed damage system:
- Limb HP: ×3-5 от normal enemy values
- Torso HP: ×4-8 от normal enemy
- **Losing a limb triggers a phase transition** (не просто debuff)
- Boss CAN be fully dismembered → collapsed state → regenerates (but slowly: 90s)
- During regeneration: player can proceed OR wait for bonus loot

---

# 2. FLOOR 1 — HEAD CHEF

## 2.1 Identity

**Name:** The Head Chef
**Type:** Enhanced enemy ( upscaled Handler)
**Fantasy:** Он обрабатывал тысячи тел. Теперь он — главный ингредиент твоего вечера.

| Stat | Value |
|------|-------|
| Torso HP | 300 |
| Head HP | 60 |
| Arm HP (L) | 80 |
| Arm HP (R) | 80 |
| Leg HP (L) | 70 |
| Leg HP (R) | 70 |
| Speed | 90 px/s |
| Regen | ×0.7 |

## 2.2 Arena

**Kitchen — 16×14 tiles**
- Industrial kitchen equipment (islands, counters, stoves)
- Meat hooks hanging from ceiling (visual + can be shot down for damage)
- Grease on floor (slippery zones)
- Stove flames (environmental hazard: 15 dmg/s)
- 4 entry points (2 locked during fight)

## 2.3 Attack Patterns

### Phase 1 — "Service" (100% - 60% HP)

| Pattern | Telegraph | Effect | Counter |
|---------|-----------|--------|---------|
| Cleaver Sweep | Raises cleaver high (0.5s) | Wide arc, 35 dmg, knockback | Dodge sideways |
| Charge | Stomps foot (0.3s) → runs straight | 25 dmg + knockback + stun 0.8s | Step aside |
| Pot Toss | Reaches behind counter (0.6s) | Throws hot pot, AoE 20 dmg + burn 4/s × 3s | Move away from marked zone |
| Kitchen Call | Whistles (0.3s) | Summons Staff ×1 (from side door, 5s delay) | Kill quickly or ignore |

### Phase 2 — "Main Course" (60% - 30% HP, или 1 limb lost)

*Chef enraged. Cleaver glows red. Speed +20%.*

| Pattern | Telegraph | Effect | Counter |
|---------|-----------|--------|---------|
| Furious Chop | Snarl + cleaver down (0.3s) | Heavy overhead, 50 dmg, GUARANTEED knockdown | Dodge + punish |
| Meat Hook Swing | Grabs hook from ceiling (0.4s) | Sweeping hook, 30 dmg, pulls player closer | Dodge behind counter |
| Double Pot | Two-handed throw (0.8s) | Two AoE zones simultaneously | Position between zones |
| Rage Charge | Screen shake (0.5s) → charge | 40 dmg + wall stun (1.5s if hits wall) | Don't stand near walls |

### Phase 3 — "Dessert" (30% - 0% HP, или 2+ limbs lost)

*Chef desperate. Uses environment more. Summons more help.*

| Pattern | Telegraph | Effect | Counter |
|---------|-----------|--------|---------|
| Stove Push | Runs to stove (1.0s) | Pushes stove toward player, 30 dmg + fire trail | Throw weapon to interrupt |
| Fling Everything | Screams (0.5s) | Throws 3 random kitchen items (pots, knives, pans) | Evade pattern |
| Kitchen Call ×3 | Triple whistle | Summons Staff ×3 + Guard ×1 | Focus boss, ignore adds |
| Desperate Grab | Lunge (0.2s, fast!) | Grab → drag toward stove → 8 dmg/s × 3s | Break free (mash) |

## 2.4 Pattern Variation Pool

Каждый run, Chef выбирает:
- Phase 1: 3 из 4 patterns (Kitchen Call always included)
- Phase 2: 3 из 4 patterns (Rage Charge always included)
- Phase 3: 3 из 4 patterns (Desperate Grab always included)

Random selection per run seed.

## 2.5 Mutilation Impact

| Limb Lost | Effect |
|-----------|--------|
| Right arm | Cannot use Cleaver Sweep → switches to Kitchen Call more often |
| Left arm | Cannot Double Pot → replaces with Stove Push in Phase 2 |
| Both arms | Phase 3 immediately → kicks, headbutts, summons only |
| One leg | Speed −30% → more summoning, less charging |
| Both legs | Immobile → CONSTANT summoning + pot throwing only |

## 2.6 Victory

- Torso HP = 0 → Chef collapses
- Kitchen door unlocks
- Floor reward: random cult artifact
- Exit stairs glow

---

# 3. FLOOR 2 — MADAME

## 3.1 Identity

**Name:** Madame
**Type:** Unique (deception boss)
**Fantasy:** Она — хозяйка желания. Она — зеркало. Она — везде и нигде.

| Stat | Value |
|------|-------|
| Torso HP | 250 |
| Head HP | 50 |
| Arm HP | 40 (×2) |
| Leg HP | 40 (×2) |
| Speed | 150 px/s (very mobile) |
| Regen | ×1.2 |

## 3.2 Arena

**Madame's Chamber — 14×12 tiles**
- Mirrored walls on all sides
- Bed in center (obstacle)
- Vanity mirrors scattered (interactable — break to limit decoys)
- Red lighting, curtains
- 6 breakable mirrors

## 3.3 Mechanic: Mirror Clones

Madame creates **mirror clones** — identical copies that attack but deal 0 damage (visual confusion only). Player must identify the real Madame.

**How to tell:**
- Real Madame: slight shadow under feet (subtle)
- Clone: no shadow, slightly different timing
- Clones shatter when hit (visual feedback — this one was fake)

## 3.4 Phases

### Phase 1 — "Reflection" (100-50%)
- 2 mirror clones active simultaneously
- Madame + clones move identically (mirrored movement)
- Attacks: Kiss (stun 1.5s) + Dagger swipe (15 dmg)
- Breaking a mirror = 1 less clone available (max 4 mirrors to break)

### Phase 2 — "Shattered" (50-25% or 1 limb)
- 3 mirror clones
- Clones can now do damage (5 dmg — real Madame does 25)
- Madame teleports between intact mirrors
- New: Mirror Shard Throw — 20 dmg, piercing, leaves shard hazard on ground

### Phase 3 — "True Face" (25-0% or 2+ limbs)
- All mirrors break — no more clones
- Madame goes berserk — fast, aggressive
- Dash attack: 35 dmg, fast
- Scream: AoE stun 1.0s in radius 80px
- Summons Bodyguard ×1

---

# 4. FLOOR 3 — THE GOURMAND

## 4.1 Identity

**Name:** The Gourmand
**Type:** Unique (growth boss)
**Fantasy:** Он ест. Всё. И растёт. Чем больше ест — тем больше. Тем опаснее.

| Stat | Value |
|------|-------|
| Torso HP | 350 (base) → scales with eating |
| Limb HP | 60 each (base) → scales |
| Speed | 60 px/s (slow) → slower as grows |
| Size | 32×32 (base) → up to 64×64 |
| Regen | ×0.5 (slow — busy digesting) |

## 4.2 Mechanic: Consumption

- Arena содержит corpses (pre-placed) + enemies that can be summoned
- Gourmand ЕСТ corpses → grows → gains HP + damage + size
- Player can destroy corpses before Gourmand reaches them
- Creates tension: kill adds quickly AND destroy their bodies

## 4.3 Phases

### Phase 1 — "Appetizer" (normal size)
- Slow walk toward nearest corpse
- Belly Bump: close range, 25 dmg, knockback
- Vomit Spray: cone attack, 15 dmg + slow 30% × 3s
- Summons Staff ×1 every 15s

### Phase 2 — "Main Course" (after eating 2+ corpses)
- Size ×1.5, Torso HP +100, damage ×1.5
- Belly Flop: jumps + lands → AoE shockwave, 30 dmg + knockdown
- Grab + Devour: grabs player → 10 dmg/s. Player must break free. If other enemy nearby → eats THEM instead
- Summons Taster ×1 every 20s

### Phase 3 — "Digestif" (after eating 4+ corpses or HP <30%)
- Size ×2, Torso HP +200, damage ×2
- Rolling Charge: rolls across arena, 50 dmg, devastates
- Acid Pool: vomits persistent acid zone (10 dmg/s, 6s)
- Can eat his OWN severed limbs for emergency heal (30 HP per limb)

**Key counter:** Destroy corpses. Don't let him eat. Maim him before he grows.

---

# 5. FLOOR 4 — THE ACCOUNTANT

## 5.1 Identity

**Name:** The Accountant
**Type:** Enhanced (trap specialist)
**Fantasy:** Он не сражается. Он ведёт книгу. И книга говорит, что ты должен умереть.

| Stat | Value |
|------|-------|
| Torso HP | 200 (but very evasive) |
| Limb HP | 40 each |
| Speed | 160 px/s (fast, dodges constantly) |
| Regen | ×1.0 |

## 5.2 Mechanic: Trap Network

Accountant doesn't fight directly. He activates traps:
- Spike walls (30 dmg, telegraphed by grinding sound)
- Crusher ceiling (50 dmg, telegraphed by shadow growing)
- Laser grid (15 dmg/s while active)
- Lockdown doors (seals exits for 4s)

Player must fight traps WHILE chasing Accountant.

## 5.3 Phases

### Phase 1 — "Audit" (100-50%)
- Accountant evades, activates traps on timers
- Occasional pistol shot (10 dmg)
- Summons Vault Drone ×1 every 20s

### Phase 2 — "Foreclosure" (50-25%)
- All traps activate faster (half cooldowns)
- Accountant throws gold bars (25 dmg, slow but heavy)
- Escape routes: breakable walls (revealed by cracks)
- Summons Vault Drone ×2

### Phase 3 — "Bankruptcy" (25-0%)
- Desperate: ALL traps active simultaneously
- Accountant stops running → grabs gold → throws everything
- Gold bar barrage (15 dmg × 5 rapid throws)
- Traps slowly deactivate as his HP drops

---

# 6. FLOOR 5 — ATTENDANT PRIME

## 6.1 Identity

**Name:** The Attendant Prime
**Type:** Unique (stealth + fog)
**Fantasy:** Первый служитель. Тот, кто научил всех остальных. Он — пар. Он — туман. Он — everywhere.

| Stat | Value |
|------|-------|
| Torso HP | 280 |
| Limb HP | 50 each |
| Speed | 100 px/s (in fog: 150 px/s, teleports) |
| Regen | ×1.5 (in fog), ×0.5 (outside fog) |

## 6.2 Mechanic: Fog Control

Arena filled with fog patches. Attendant Prime:
- Invisible in fog
- Teleports between fog patches
- Creates new fog (channel 2s)
- Player can disperse fog by destroying steam valves (environmental interaction)

## 6.3 Phases

### Phase 1 — "Welcome" (100-60%)
- Arena 50% fog
- Phase attacks: Sedative Touch → slows player
- Fog breath: expands fog zones
- Healing aura: heals self 5 HP/s while in fog

### Phase 2 — "Deep Tissue" (60-25%)
- Arena 75% fog
- Now attacks from fog: grab → drag into fog → player disoriented
- Steam blast: 30 dmg + stun from fog patch
- Disperse strategy: find and destroy 4 steam valves (reduces fog to 30%)

### Phase 3 — "Checkout" (25-0%)
- Desperate: fog MAXIMUM (90%)
- But: fog is now TOXIC — 3 dmg/s to player in fog
- Must find remaining valves AND fight boss
- Attendant Prime visible briefly when attacking (0.5s window)
- Lure him out of fog → attack during window

---

# 7. FLOOR 6 — THE CHAMPION

## 7.1 Identity

**Name:** The Champion
**Type:** Unique (wave + 1v1)
**Fantasy:** Чемпион арены. Бессмертный гладиатор. Ты — его 10,000-й бой.

| Stat | Value |
|------|-------|
| Torso HP | 300 (Phase 3 only — immune in Phase 1-2) |
| Limb HP | 70 each |
| Speed | 140 px/s |
| Regen | ×0.8 |

## 7.2 Mechanic: Wave + Boss Hybrid

Fight is structured as 3 waves + boss:
- **Wave 1:** Gladiator ×1 + Berserker ×1
- **Wave 2:** Gladiator ×2 + Berserker ×2
- **Wave 3:** The Champion descends — boss fight begins

Champion watches from throne during waves. Buffs enemies (+15% damage per wave).

## 7.3 Boss Phase (Champion)

### Phase 1 — "Honour" (100-50%)
- Greatsword combo: 20-25-30 dmg (3-hit, telegraphed)
- Shield block: blocks frontal damage (shield HP: 80)
- Arena taunt: screen shake + crowd roar (visual only)

### Phase 2 — "Glory" (50-25% or shield broken)
- Drops shield → dual wields (2 greatswords, impossible but he's immortal)
- Whirlwind: spin attack, hits 360°, 35 dmg, 1.5s duration
- Charge: rush attack, 40 dmg + knockback into wall
- Crowd throws weapons into arena (environmental pickups for player!)

### Phase 3 — "Infamy" (25-0%)
- Desperate: throws swords → fights bare-handed
- Enraged fists: 30 dmg, very fast, ×2.0 limb damage (HE can dismember YOU)
- Grab: throws player across arena
- Berserk: damage increases as HP drops (×1.0 → ×2.0 at 0%)

---

# 8. FLOOR 7 — THE CURATOR

## 8.1 Identity

**Name:** The Curator
**Type:** Unique (theft + stealth)
**Fantasy:** Хранитель запретного. Он коллекционирует. Сейчас он хочет твоё оружие.

| Stat | Value |
|------|-------|
| Torso HP | 250 |
| Limb HP | 45 each |
| Speed | 130 px/s (phasing) |
| Regen | ×1.1 |

## 8.2 Mechanic: Weapon Theft

The Curator STEALS player's weapons:
- Phase through player → steal equipped weapon (0.8s grab)
- Uses stolen weapon AGAINST player (same stats)
- Can hold 1 stolen weapon at a time
- Player can reclaim by damaging Curator enough while he holds it

This creates a unique dynamic: you're fighting your own best weapon.

## 8.3 Phases

### Phase 1 — "Acquisition" (100-50%)
- Phases invisible → attempts weapon steal
- If successful: uses your weapon against you
- Shadow bolt: ranged, 20 dmg
- Summons Spy ×1 every 25s

### Phase 2 — "Collection" (50-25%)
- Now attempts steal more aggressively
- If stole weapon: becomes significantly more dangerous
- Display Case: 4 stolen weapons on walls → Curator can grab ANY of them (player's previously stolen weapons become arena hazards)
- Phase wall: walks through walls, attacks from unexpected angles

### Phase 3 — "Exhibition" (25-0%)
- Desperate: tries to steal BOTH weapons simultaneously
- If succeeds: player fights bare-handed (must use improvised / severed limbs)
- Shadow realm: creates dark zone around self (visibility −70% within 100px)
- Shadow clone: 1 permanent clone (25% damage, but confusing)

---

# 9. FLOOR 8 — THE CONSORT

## 9.1 Identity

**Name:** The Consort
**Type:** Unique (coordinated squad)
**Fantasy:** Она не сражается одна. Она — командир. Её гвардия — её тело. Её воля — их закон.

| Stat | Value |
|------|-------|
| Torso HP | 200 |
| Limb HP | 35 each |
| Speed | 110 px/s (stays behind guards) |
| Regen | ×1.0 |
| Guards | 4 Royal Guards (always present) |

## 9.2 Mechanic: Squad Command

The Consort doesn't attack directly. She commands 4 Royal Guards:
- **Shield Wall:** Guards form line in front of her
- **Surround:** Guards encircle player
- **Pinch:** Two guards attack from sides simultaneously
- **Royal Guard:** One guard grabs player → Consort approaches → ritual stab (40 dmg)

Kill/disable guards to create openings to Consort.
Consort summons 1 replacement guard every 30s (if any dead).

## 9.3 Phases

### Phase 1 — "Retinue" (4 guards alive)
- Consort safe behind shield wall
- Commands guards in coordinated patterns
- Player must break formation (kill/maim 1-2 guards)

### Phase 2 — "Court" (2-3 guards alive)
- Consort panics → commands more aggressively
- Guards attack faster but less coordinated
- Consort begins throwing ornamental daggers (15 dmg)

### Phase 3 — "Alone" (0-1 guards alive)
- Consort fights directly
- Rapier thrust: 25 dmg, fast, long range
- Fan swipe: cone, 20 dmg, knockback
- Summon: channels 3s → 1 new guard (interruptible)
- Desperate scream: AoE stun 0.5s → runs to summon point

---

# 10. FLOOR 9 — THE SISTER + SATAN

## 10.1 THE SISTER

### Identity

**Name:** The Sister
**Type:** Unique narrative encounter
**Fantasy:** Ты пришёл за ней. Она здесь. Но она... изменилась.

### Encounter Structure

**НЕ традиционный boss fight. Это choice encounter.**

**Phase 1 — Recognition**
- Sister stands in center of white room
- She speaks (text only, no VO): "You came."
- Player approaches → room shifts colour (white → warm)
- Sister: "I was like you once. Scared. Angry. Then I understood."
- She reveals: she volunteered. She WANTED immortality.
- She is now something... between human and demon.

**Phase 2 — Confrontation**
- Player must choose:
  - **Fight her** → combat encounter begins
  - **Listen to her** → she explains the truth about the hotel
  - **Embrace her** → she stabs you (damage but opens hidden path)

**Combat stats (if fight):**

| Stat | Value |
|------|-------|
| Torso HP | 350 |
| Limb HP | 60 each |
| Speed | 160 px/s |
| Regen | ×1.3 |

- Uses player's weapons (copies your current loadout — fights like mirror match)
- Hesitation mechanic: every 20% HP lost, she pauses (1.5s, doesn't attack)
- During pause: text appears: "Why are you doing this?" / "I'm still your sister" / "Please"
- Player CAN keep attacking during pauses (no mechanical penalty)

**Phase 3 — Resolution**

| Choice | Outcome |
|--------|---------|
| Kill Sister | She collapses. "I forgive you." Path to Satan opens. Ending A. |
| Spare Sister (stop attacking at <10% HP) | She smiles. "You're still you." She joins you against Satan. Ending B. |
| Listen (never attack) | She tells you the truth about YOURSELF. You're also immortal. You just don't remember. Ending C. |
| Embrace (take the stab, survive) | Hidden path opens. Bypass Satan. But you become part of the hotel. Ending D. |

---

## 10.2 SATAN

### Identity

**Name:** Satan
**Type:** Unique final boss
**Fantasy:** Не рога. Не огонь. Человек в идеальном костюме. Улыбка. Рукопожатие. "Добро пожаловать в совет директоров."

### Visual

- Appears as a tall, elegant figure in a perfect suit
- Gold tie, cufflinks, polished shoes
- No monstrous form — the horror is the NORMALCY
- When damaged: skin cracks → reveals void beneath
- Arena: abstract geometry, no walls, shifting colours

### Stats

| Stat | Phase 1 | Phase 2 | Phase 3 |
|------|---------|---------|---------|
| Torso HP | 400 | 500 | 600 |
| Speed | 120 | 150 | 180 |
| Regen | ×1.0 | ×1.5 | ×2.0 |

### Phase 1 — "The Interview"

Satan is calm, casual. Fights like a gentleman.
- **Handshake**: extends hand → if player approaches → grab + drain (30 dmg)
- **Contract Throw**: throws papers → tracking projectile, 20 dmg, applies "fine print" (speed −15% × 5s)
- **Dismiss**: waves hand → knockback 200px, 15 dmg
- **Board Member Summon**: summons Demon ×1

**Dialogue between attacks:** "Your sister made the right choice." / "Immortality isn't free. Someone has to pay." / "You're doing exactly what I expected."

### Phase 2 — "The Audit"

Satan loses composure. Cracks in skin. Void shows through.
- **Reality Warp**: arena geometry shifts — platforms move, gaps appear
- **Fiscal Year**: time slows for player (0.5× speed for 3s), Satan normal speed
- **Hostile Takeover**: steals player's weapon (like Curator) — uses it
- **Liquidation**: floor becomes damage zone in sections (20 dmg/s, telegraphed 1s)
- **Board Member Summon**: Demon ×2

**Dialogue:** "You think this is about GOOD and EVIL?" / "It's about PROFIT." / "EVERYTHING has a cost."

### Phase 3 — "Bankruptcy"

Satan's form breaks down. Void entity wearing a suit.
- **Void Touch**: melee, 50 dmg, desecrates area (no regen for player for 5s)
- **Economic Collapse**: ALL arena becomes hostile — shrinking safe zone
- **Market Crash**: projectiles from all directions (pattern-based dodge sequence)
- **Final Offer**: at 10% HP → offers deal: "Join the board. End this." → CHOICE

### Final Choice

| Choice | Result |
|--------|--------|
| Reject deal + kill Satan | Hotel collapses. You escape. (Ending depends on Sister outcome) |
| Accept deal | You become the new CEO. Credits roll. Dark ending. |
| Reject + Sister alive (Ending B) | Sister helps. Together you destroy Satan. Escape together. True ending. |

---

# 11. BOSS DIFFICULTY SUMMARY

| Boss | Floor | Est. Duration | Difficulty | Key Challenge |
|------|-------|---------------|-----------|---------------|
| Head Chef | 1 | 2-3 min | ★★☆☆☆ | Basic combat mastery |
| Madame | 2 | 2-3 min | ★★★☆☆ | Identify real among clones |
| The Gourmand | 3 | 3-4 min | ★★★☆☆ | Resource denial (destroy corpses) |
| The Accountant | 4 | 3-4 min | ★★★★☆ | Navigate traps while chasing |
| Attendant Prime | 5 | 3-4 min | ★★★★☆ | Manage fog + find boss |
| The Champion | 6 | 4-5 min | ★★★★☆ | Wave survival + boss execution |
| The Curator | 7 | 3-4 min | ★★★★★ | Fight without your own weapons |
| The Consort | 8 | 4-5 min | ★★★★★ | Break elite formation |
| The Sister | 9 | Variable | Special | Emotional + moral choice |
| Satan | 9 | 5-7 min | ★★★★★+ | All skills tested |

---

# 12. BOSS SPRITE PRODUCTION

| Boss | Size (px) | Estimated Frames | Priority |
|------|-----------|-----------------|----------|
| Head Chef | 40×48 | ~200 | MVP |
| Madame | 28×40 | ~250 (clones share base) | Medium |
| The Gourmand | 32→64 × 32→64 | ~300 (3 sizes) | Medium |
| The Accountant | 24×38 | ~150 | Medium |
| Attendant Prime | 26×38 | ~200 (fog effects) | Medium |
| The Champion | 32×44 | ~250 | Low |
| The Curator | 26×38 | ~200 | Low |
| The Consort | 24×36 | ~150 (+ guard animations) | Low |
| The Sister | 24×36 | ~200 + narrative poses | Low |
| Satan | 28×44 | ~350 (3 phases + breakdown) | Low |

**Total boss sprites: ~2,250 frames**
**MVP (1 boss): ~200 frames**
