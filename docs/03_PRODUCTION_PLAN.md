# PRODUCTION PLAN — HOTEL
## Version 0.1 — First Draft

---

# 1. DEVELOPMENT APPROACH

## 1.1 Methodology

- Solo dev с AI-assisted development
- No budget, no deadline
- Iterative: prototype → test → iterate
- Vertical slice first, expand after

## 1.2 Milestone Roadmap

```
M1: COMBAT PROTOTYPE ──────────────────────────────
    Player movement + 1 enemy + melee + regen
    Duration: prototype phase

M2: WEAPON SYSTEM ─────────────────────────────────
    5 weapons + throw mechanics + pickup
    Duration: expand M1

M3: FLOOR 1 ALPHA ─────────────────────────────────
    Full floor layout + 3 enemy types + mini-boss
    Room transitions + camera

M4: RUN SYSTEMS ────────────────────────────────────
    Basement escape + run start/end + randomization
    Seed-based enemy/loot spawning

M5: VERTICAL SLICE ─────────────────────────────────
    Floor 1 polished + all core systems working
    HUD + UI + game feel + juice
    PLAYABLE DEMO

M6: CONTENT EXPANSION (Floor 2-3) ─────────────────
    Prove scalability of systems
    New enemy types + floor-specific mechanics
    Art pipeline validation

M7: FULL GAME (Floor 4-9) ─────────────────────────
    All remaining floors
    All remaining enemies + bosses
    Sister narrative integration
    All weapons + artifacts

M8: POLISH ─────────────────────────────────────────
    Audio implementation
    VFX polish
    Balance pass
    Performance optimization
    Bug fixing
```

---

# 2. MVP DEFINITION (Vertical Slice)

## 2.1 Scope

**Floor 1 — Service Underground**, fully playable:

### Must Have
- [ ] Player: move (WASD) + aim (mouse) + attack + throw + pickup
- [ ] Player HP + damage + capture trigger
- [ ] 3 Enemy types: Staff, Guard, Handler
- [ ] Per-limb damage (5 zones)
- [ ] Real-time regeneration with visual feedback
- [ ] 5 Weapons: Machete, Sawed-off, Knife, Bat, Pistol
- [ ] Throwable weapons (each with unique effect)
- [ ] 1 Mini-boss: Head Chef
- [ ] Floor layout: HUB + 3-4 branch rooms + boss arena
- [ ] Room transitions + camera system
- [ ] Basement escape (1 layout, floor 1 enemies)
- [ ] Run start / run end flow
- [ ] Random enemy placement per run
- [ ] Random loot placement per run
- [ ] 2-3 stat upgrades
- [ ] 1 cult artifact (with trade-off)
- [ ] Basic HUD (HP, weapons, floor indicator)
- [ ] Basic blood/gore effects

### Nice to Have (post-MVP)
- [ ] Route variation (gate system)
- [ ] Boss attack pattern variation
- [ ] Multiple cult artifacts
- [ ] Environmental kills
- [ ] Destructible environment
- [ ] Screen shake / juice
- [ ] Dynamic music

---

# 3. TASK BREAKDOWN

## Epic 1: CORE ENGINE SETUP
### Feature 1.1: Project Structure
- [ ] T1.1.1: Create Godot 4 project
- [ ] T1.1.2: Setup folder structure
- [ ] T1.1.3: Setup autoloads (GameManager, EventBus, SaveManager)
- [ ] T1.1.4: Setup input mappings
- [ ] T1.1.5: Setup collision layers

### Feature 1.2: Core Systems
- [ ] T1.2.1: GameState enum + transitions
- [ ] T1.2.2: EventBus signal definitions
- [ ] T1.2.3: RunState data class
- [ ] T1.2.4: SeedManager (deterministic RNG)

---

## Epic 2: PLAYER
### Feature 2.1: Player Controller
- [ ] T2.1.1: Player scene (CharacterBody2D)
- [ ] T2.1.2: Movement (WASD)
- [ ] T2.1.3: Mouse aiming
- [ ] T2.1.4: Player sprite (placeholder)
- [ ] T2.1.5: Player animations (idle, walk, attack)

### Feature 2.2: Player Combat
- [ ] T2.2.1: Melee attack
- [ ] T2.2.2: Ranged attack
- [ ] T2.2.3: Throw action
- [ ] T2.2.4: Pickup action
- [ ] T2.2.5: Weapon switching (2 slots)

### Feature 2.3: Player Stats
- [ ] T2.3.1: HP system
- [ ] T2.3.2: Damage taken + knockback
- [ ] T2.3.3: Capture trigger (HP = 0)
- [ ] T2.3.4: Stat upgrade application

---

## Epic 3: ENEMY SYSTEM
### Feature 3.1: Base Enemy
- [ ] T3.1.1: Base enemy scene (CharacterBody2D)
- [ ] T3.1.2: Per-limb health (5 zones)
- [ ] T3.1.3: Hurtbox setup (5 zones + torso)
- [ ] T3.1.4: Base sprite (placeholder)
- [ ] T3.1.5: Navigation agent setup

### Feature 3.2: Enemy AI
- [ ] T3.2.1: State machine framework
- [ ] T3.2.2: Patrol state
- [ ] T3.2.3: Alert state
- [ ] T3.2.4: Chase state
- [ ] T3.2.5: Engage/attack state
- [ ] T3.2.6: Mutilated behavior (per limb loss)
- [ ] T3.2.7: Stunned state
- [ ] T3.2.8: Grabbing state (handler-specific)

### Feature 3.3: Regeneration
- [ ] T3.3.1: RegenSystem class
- [ ] T3.3.2: Per-limb regen timers
- [ ] T3.3.3: Visual regen feedback
- [ ] T3.3.4: Pause on hit mechanic

### Feature 3.4: Enemy Types
- [ ] T3.4.1: Staff enemy (weak, numerous)
- [ ] T3.4.2: Guard enemy (organized, grab)
- [ ] T3.4.3: Handler enemy (slow, deadly grab)

---

## Epic 4: COMBAT SYSTEMS
### Feature 4.1: Damage System
- [ ] T4.1.1: DamageZone enum
- [ ] T4.1.2: Damage application
- [ ] T4.1.3: Limb severing
- [ ] T4.1.4: Hit effects (stagger, knockback, stun)

### Feature 4.2: Weapon System
- [ ] T4.2.1: WeaponData resource
- [ ] T4.2.2: WeaponManager (equip, switch, pickup)
- [ ] T4.2.3: Melee weapons (5 types)
- [ ] T4.2.4: Ranged weapons (with ammo)
- [ ] T4.2.5: Throw mechanics (per weapon)
- [ ] T4.2.6: Weapon pickups on ground

### Feature 4.3: Gore System
- [ ] T4.3.1: Blood splash particles
- [ ] T4.3.2: Severed limb entities
- [ ] T4.3.3: Blood pools (persistent)
- [ ] T4.3.4: Dismemberment visuals

---

## Epic 5: WORLD SYSTEMS
### Feature 5.1: Room System
- [ ] T5.1.1: RoomInstance base scene
- [ ] T5.1.2: Camera bounds per room
- [ ] T5.1.3: Room transitions (doors)
- [ ] T5.1.4: Room activation/deactivation

### Feature 5.2: Floor System
- [ ] T5.2.1: FloorManager
- [ ] T5.2.2: Floor loading + setup
- [ ] T5.2.3: Floor 1 layout design
- [ ] T5.2.4: HUB room
- [ ] T5.2.5: Branch rooms (3-4)
- [ ] T5.2.6: Mini-boss arena

### Feature 5.3: Randomization
- [ ] T5.3.1: Enemy spawn config per room per seed
- [ ] T5.3.2: Loot placement per room per seed
- [ ] T5.3.3: Loot tables (weapons, upgrades)
- [ ] T5.3.4: Spawn point pools

---

## Epic 6: PROGRESSION
### Feature 6.1: Upgrades
- [ ] T6.1.1: StatUpgradeData resource
- [ ] T6.1.2: CultArtifactData resource (with trade-offs)
- [ ] T6.1.3: Upgrade pickup scenes
- [ ] T6.1.4: Upgrade application to RunState

### Feature 6.2: Mini-Boss
- [ ] T6.2.1: Mini-boss scene (Head Chef)
- [ ] T6.2.2: Boss arena layout
- [ ] T6.2.3: Boss attack patterns
- [ ] T6.2.4: Boss defeat -> floor exit unlock

### Feature 6.3: Basement Escape
- [ ] T6.3.1: Basement layout
- [ ] T6.3.2: Basement enemy spawning (floor-themed)
- [ ] T6.3.3: Escape objective (reach exit)
- [ ] T6.3.4: Success -> return to current floor
- [ ] T6.3.5: Failure -> run over -> restart

---

## Epic 7: UI
### Feature 7.1: HUD
- [ ] T7.1.1: HP bar
- [ ] T7.1.2: Weapon slots display
- [ ] T7.1.3: Ammo counter
- [ ] T7.1.4: Floor indicator
- [ ] T7.1.5: Active upgrade icons

### Feature 7.2: Menus
- [ ] T7.2.1: Title screen
- [ ] T7.2.2: Run start screen
- [ ] T7.2.3: Game over screen
- [ ] T7.2.4: Victory screen
- [ ] T7.2.5: Settings (audio, controls)

---

## Epic 8: POLISH (Post-MVP)
### Feature 8.1: Game Feel
- [ ] T8.1.1: Screen shake
- [ ] T8.1.2: Hit stop (freeze frames)
- [ ] T8.1.3: Camera zoom on impact
- [ ] T8.1.4: Visual flash on damage

### Feature 8.2: Audio
- [ ] T8.2.1: Player SFX (footsteps, attacks, hurt)
- [ ] T8.2.2: Enemy SFX (alerts, attacks, damage, regen)
- [ ] T8.2.3: Weapon SFX (per weapon)
- [ ] T8.2.4: Gore SFX
- [ ] T8.2.5: Ambient per floor
- [ ] T8.2.6: Music per floor (dynamic)

### Feature 8.3: Art
- [ ] T8.3.1: Final pixel art sprites (player)
- [ ] T8.3.2: Final enemy sprites (per type)
- [ ] T8.3.3: Floor 1 tileset
- [ ] T8.3.4: Weapon sprites
- [ ] T8.3.5: UI elements
- [ ] T8.3.6: Effect sprites (blood, etc.)

---

# 4. DEVELOPMENT ORDER (Priority)

## Phase 1: COMBAT PROTOTYPE
```
T1.1.1 → T1.1.2 → T1.1.3 → T1.1.4 → T1.1.5  (Project setup)
T1.2.1 → T1.2.2                                (Core systems)
T2.1.1 → T2.1.2 → T2.1.3 → T2.1.4            (Player basics)
T3.1.1 → T3.1.2 → T3.1.3 → T3.1.5            (Base enemy)
T4.1.1 → T4.1.2 → T4.1.3                       (Damage system)
T3.3.1 → T3.3.2                                 (Regen system)
T2.2.1 → T2.2.2                                 (Player attacks)
```
→ RESULT: Player can move, attack enemy, damage limbs, enemy regenerates

## Phase 2: WEAPONS
```
T4.2.1 → T4.2.2 → T4.2.3 → T4.2.4 → T4.2.5 → T4.2.6
```
→ RESULT: Full weapon system, all 5 MVP weapons, throwable

## Phase 3: AI
```
T3.2.1 → T3.2.2 → T3.2.3 → T3.2.4 → T3.2.5 → T3.2.6 → T3.2.7 → T3.2.8
T3.4.1 → T3.4.2 → T3.4.3
```
→ RESULT: 3 enemy types with full AI + mutilation behaviors

## Phase 4: WORLD
```
T5.1.1 → T5.1.2 → T5.1.3 → T5.1.4
T5.2.1 → T5.2.2 → T5.2.3 → T5.2.4 → T5.2.5 → T5.2.6
```
→ RESULT: Floor 1 layout, room transitions, playable floor

## Phase 5: RUN SYSTEMS
```
T5.3.1 → T5.3.2 → T5.3.3 → T5.3.4
T6.3.1 → T6.3.2 → T6.3.3 → T6.3.4 → T6.3.5
T1.2.4 (SeedManager)
```
→ RESULT: Roguelike loop functional

## Phase 6: PROGRESSION
```
T6.1.1 → T6.1.2 → T6.1.3 → T6.1.4
T6.2.1 → T6.2.2 → T6.2.3 → T6.2.4
```
→ RESULT: Upgrades, mini-boss, full floor loop

## Phase 7: UI + GORE
```
T7.1.1 → T7.1.2 → T7.1.3 → T7.1.4 → T7.1.5
T7.2.1 → T7.2.2 → T7.2.3 → T7.2.4
T4.3.1 → T4.3.2 → T4.3.3 → T4.3.4
```
→ RESULT: VERTICAL SLICE COMPLETE

---

# 5. ASSET SCOPE ESTIMATE

## 5.1 MVP (Vertical Slice) Assets

| Category | Count | Estimate |
|----------|-------|----------|
| Player sprites (idle, walk, attack, hurt) | ~20 frames | Medium |
| Enemy sprites (3 types × states) | ~60 frames | High |
| Weapon sprites (5 weapons) | ~10 sprites | Low |
| Weapon throw sprites | ~5 sprites | Low |
| Floor 1 tileset | ~30-40 tiles | High |
| UI elements | ~15 elements | Medium |
| Blood/gore sprites | ~10 sprites | Medium |
| Mini-boss sprites | ~20 frames | Medium |

## 5.2 Full Game Assets (Post-MVP)

| Category | Count | Priority |
|----------|-------|----------|
| Enemy sprites (12-17 additional types) | ~250-340 frames | Highest load |
| Floor tilesets (8 additional) | ~240-320 tiles | High |
| Mini-boss sprites (8 additional) | ~160 frames | Medium |
| Weapon sprites (10 additional) | ~20 sprites | Low |
| Cult artifact sprites | ~12 sprites | Low |
| Effect sprites | ~20 sprites | Medium |

## 5.3 Asset Strategy

- Start with placeholder rectangles → replace with pixel art
- Reuse animations across enemy types where possible (skeleton rigging)
- Floor tilesets: base tiles (walls, floor) reusable, accent tiles unique
- Weapon sprites: top-down view, minimal animation frames

---

# 6. RISK REGISTER

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Regen system unbalanced | High | High | Extensive playtesting, tunable constants |
| Scope creep (9 unique floors) | High | High | Strict MVP, expand only after vertical slice |
| Combat not "fun enough" | Medium | Critical | Prototype early, iterate on feel |
| Performance (gore + enemies) | Medium | High | Object pooling, room deactivation, budget limits |
| Pixel art production bottleneck | High | Medium | Start simple, upgrade art later |
| Enemy AI too complex | Medium | Medium | Start simple, add coordination gradually |
| Roguelike feels repetitive | Medium | High | Strong run variation systems |
| Basement escape not fun | Medium | Medium | Keep it short, focus on tension not difficulty |
