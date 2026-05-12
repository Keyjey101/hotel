# Floor 6 — The Arena (Wrath)

## Atmosphere
- Colour palette: #0F0505 (floor — dried blood black, packed sand and ash), #1A0A0A (walls — scorched iron and basalt), #CC1100 (accent — blood red, battle banners, weapon edges), #FF5500 (ember — brazier fire, molten iron fixtures, weapon glow).
- Musical theme: Driving war drums with dissonant brass stabs. A crowd roar loop builds density as combat escalates. Distorted strings scratch underneath during the boss fight. Rhythm is aggressive and unrelenting, dropping to silence only on the final kill of each wave.
- Sensory hook: The roar of an unseen crowd that swells when you take damage and boos when you heal, as though the Arena itself is watching and judging.

## Encounter Manifest

### Room a1 — Holding Cells
- Size: 8x6 tiles.
- Type: corridor.
- Spawn:
  - 0 enemies.
- Loot: none.
- Hazards: none. Cell doors are interactable but locked — one contains a corpse with a health pickup (1x per run, at tile (6,4)).
- Recipe: Standard.
- Lore element: Scratched into the cell wall: "THEY CHEER FOR YOUR DEATH. THEY WILL CHEER FOR MINE. WE ARE THE SAME."
- Exits: east -> a2 (one-way door — player cannot return to a1).

### Room a2 — Blood Corridor
- Size: 8x4 tiles.
- Type: corridor.
- Spawn:
  - 1x Gladiator at (5,2) (blocking the corridor, charges on sight).
- Loot: none.
- Hazards: one-way door at tile (0,1)-(0,2) — player enters from a1 but cannot go back. Blood slick on tiles (3,1)-(4,3) — speed -30%, visual effect only.
- Recipe: 15-RageGauntlet.
- Lore element: The corridor walls are lined with notches — one for each fighter who walked this path.
- Exits: west -> a1 (one-way, entry only), east -> hub.

### Room hub — The Arena Floor
- Size: 14x12 tiles.
- Type: hub.
- Spawn:
  - 2x Gladiator at (3,3), (10,3) (flanking positions, patrol the arena floor).
  - 1x Berserker at (7,8) (center-south, charges immediately on player entry).
- Loot: SMG at (12,1) (on a weapon rack along the north wall).
- Hazards: four braziers at (2,2), (11,2), (2,9), (11,9) — knockable (8dmg/s fire spread, 2-tile radius). Sand pit at (5,5)-(8,7) — no mechanical effect, visual only.
- Recipe: 06-Swarm.
- Lore element: The sand is stained dark in patches. The crowd above is invisible but their murmuring never stops.
- Exits: west -> a2, north -> b1, east -> c1, south -> d1, boss door (sealed until side paths cleared) -> boss.

### Room b1 — Gladiator Pit
- Size: 12x10 tiles.
- Type: chamber.
- Spawn:
  - 1x Gladiator at (3,3) (Wave 1, enters from north gate).
  - 1x Berserker at (9,7) (Wave 2, enters from south gate after Wave 1 clear).
  - 1x Gladiator at (6,5) (Wave 3, enters from east gate after Wave 2 clear).
- Loot: Bat at (11,9) (on a weapon rack in the southeast corner).
- Hazards: arena wave room — doors lock on entry, unlock after all 3 waves cleared. Two braziers at (1,5), (10,5) — knockable (8dmg/s fire spread).
- Recipe: 20-WaveGate.
- Lore element: A bronze plaque reads: "THREE WAVES. SURVIVE AND EARN THE RIGHT TO ARM YOURSELF."
- Exits: south -> hub, north -> b2 (sealed until waves complete).

### Room b2 — Armory
- Size: 6x6 tiles.
- Type: storage.
- Spawn:
  - 1x Staff at (4,3) (organizing weapons, hostile on proximity).
- Loot: random_weapon at (1,1) (on a weapon stand), ammo at (3,4) (in an open crate).
- Hazards: weapon rack at (0,0)-(1,1) is collapsible — if shot, scatters blades in a 2-tile cone (10dmg, hits player and enemies).
- Recipe: Standard.
- Lore element: Every weapon here has been used. None of them have been cleaned.
- Exits: south -> b1.

### Room c1 — The Gauntlet
- Size: 12x8 tiles.
- Type: trap.
- Spawn:
  - 2x Berserker at (2,3), (9,5) (one at each end, charge through fire).
  - 1x Gladiator at (6,2) (center, shields and holds position).
- Loot: cult_relic (rare) at (11,1) (on a pedestal behind a fire gate).
- Hazards: fire gauntlet — braziers line both walls at (0,1), (0,3), (0,5), (0,7) and (11,1), (11,3), (11,5), (11,7). Knockable (8dmg/s fire spread). Ember grates on floor tiles (3,4) and (8,4) — erupt every 4s, 12dmg in 1-tile. LOCKED — requires KEY to enter.
- Recipe: 15-RageGauntlet.
- Lore element: The walls are scorched black. The last person who ran the gauntlet made it to the pedestal and burned to death reaching for the relic. Their skeleton is still there.
- Exits: west -> hub, east -> c2.

### Room c2 — Champion's Hall
- Size: 8x8 tiles.
- Type: chamber.
- Spawn:
  - 1x Guard at (5,3) (stationed at attention, patrols a small circuit).
- Loot: KEY(50%) at (2,2) (in a wall-mounted trophy case), stat_upgrade at (6,6) (on a weapon display pedestal).
- Hazards: trophy cases along north wall are interactable — 25% chance of trapped case (spring blade, 15dmg).
- Recipe: 02-Chokepoint.
- Lore element: Portraits of past Champions line the hall. The last portrait is an empty frame with a brass plaque: "YOUR NAME HERE."
- Exits: west -> c1.

### Room d1 — Spectator Stands
- Size: 10x8 tiles.
- Type: gallery.
- Spawn:
  - 2x Staff at (2,2), (8,2) (in the stands, throw debris and projectiles).
  - 1x Guard at (5,5) (patrolling the aisle between seat rows).
- Loot: random_weapon at (9,7) (dropped by a dead spectator in the corner).
- Hazards: thrown debris from Staff (8dmg, 2s cooldown, arc trajectory). Collapsing seating at (3,4)-(4,4) — if shot, collapses into a pit (instant kill if standing on it, blocks the aisle).
- Recipe: 03-Crossfire.
- Lore element: The seats are filled with mannequins dressed in finery. If you look away, their positions change.
- Exits: north -> hub, south -> d2.

### Room d2 — Beast Cages
- Size: 8x8 tiles.
- Type: storage.
- Spawn:
  - 1x Berserker at (4,4) (in a reinforced cage, breaks free when player enters — 1.5s delay as cage door bends open).
- Loot: KEY(50%) at (7,1) (hung on a hook by the cage keeper's station), ammo at (1,6) (in a supply crate).
- Hazards: cage at (3,3)-(5,5) — Berserker breaks out on entry. Three additional cages (empty) at (1,1)-(2,2), (6,1)-(7,2), (1,5)-(2,6) — interactable, contain minor lore text. Broken cage bars on the floor at (4,6) — tripping hazard, 5dmg and 0.5s stagger.
- Recipe: 14-LurkingHorror.
- Lore element: Claw marks on the inside of the cage. Claw marks on the outside. Something was locked in with something else.
- Exits: north -> d1.

### Room boss — The Arena
- Size: 16x14 tiles.
- Type: boss.
- Spawn:
  - 1x Champion at (8,2) (seated on a throne on the north platform, descends after waves).
  - Wave 1: 2x Gladiator at (2,8), (13,8).
  - Wave 2: 2x Berserker at (3,6), (12,6) + 1x Gladiator at (8,10).
  - Wave 3: 1x Berserker at (5,8) + 2x Gladiator at (3,10), (12,10) + 1x Guard at (8,7).
- Loot: cult_artifact at (8,12) (on a pedestal that rises from the sand after Champion falls).
- Hazards: four braziers at (1,1), (14,1), (1,12), (14,12) — knockable (8dmg/s fire spread). Throne platform at (6,0)-(10,3) — elevated, Champion descends via stairs at (6,3) and (10,3). Sand pit center (4,5)-(11,9) — no mechanical effect. Crowd throws debris from the stands every 10s (5dmg, random tile, telegraphed by shadow).
- Recipe: Standard.
- Lore element: The Champion has never lost. The Champion has never been replaced. The Champion does not remember being anything else.
- Exits: from hub (sealed until boss defeated), stairs to Floor 7 revealed at (8,13) after kill.

## Mini-boss Spec

### Intro
- Trigger: player enters boss room from hub.
- Cinematic: 2-3s slow-zoom from the arena floor up toward the throne platform. The Champion stands, draws a greatsword, and raises a shield. The unseen crowd erupts. Camera shakes with the roar. Sand particles swirl.
- Boss intro text: "Give them a show."

### Arena
- Size: 16x14 tiles.
- Hazards: braziers in corners (knockable, 8dmg/s fire spread), crowd debris (random 5dmg every 10s), throne platform (elevated, accessible via stairs).
- Breakable cover: weapon racks at (3,4), (12,4) (HP 60, drop random ammo on break). Wooden barricades at (5,11), (10,11) (HP 40). Throne (HP 100, can be destroyed in Phase 3).
- Entry: from hub.

### Phases
- Phase 1 "Honour" (100-50% HP): 3 waves of enemies spawn (see spawn list above). Champion watches from throne, buffing all enemies +15% damage per wave (+15%, +30%, +45%). After all waves cleared, Champion descends and engages directly. Greatsword combo: 3-hit sequence (20dmg, 25dmg, 30dmg), 1s between swings, 3s recovery after combo. Shield block: Shield HP 80, absorbs frontal damage. Arena taunt: screen shake + crowd roar every 15s, 0.5s stagger if player is within 4 tiles.
- Phase 2 "Glory" (50-25% HP or shield broken): Champion drops shield (if not already destroyed), dual-wields greatsword and a hand axe. Whirlwind: 360-degree spin, 35dmg, 1.5s duration, 6-tile radius. Charge rush: 8-tile linear charge, 40dmg + knockback (3 tiles), 2s wind-up (visible dust cloud). Crowd throws weapons into the arena (2 random melee weapon pickups for player, land at random tiles). Champion moves 20% faster.
- Phase 3 "Infamy" (25-0% HP): Champion throws both weapons at player (20dmg each, arc trajectory). Fights bare-handed: fists deal 30dmg, 2x attack speed, 2.0x limb damage multiplier. Grab attack: catches player, throws 5 tiles (25dmg + 1s stun). Damage scaling: all damage multiplied by a linear curve from 1.0x at 25% HP to 2.0x at 0% HP — Champion becomes exponentially more dangerous as death approaches. At 5% HP, crowd goes silent.

### Reward
- Kill reward: cult artifact (random from Arena pool).
- Exit: stairs to Floor 7 revealed at (8,13) after Champion defeat.

## Difficulty Curve
- Expected kills: 22.
- Expected time: 15 min.
- Hazard density: med.
- Enemy density: high.

## Replayability
- Branch-gated rooms: On 50% of seeds, room c1 (The Gauntlet) and c2 (Champion's Hall) are sealed — player must find KEY in b2 or d2. On the other 50%, room d1 (Spectator Stands) and d2 (Beast Cages) are sealed behind a collapsed passage.
- Random loot locations: b2 (random_weapon cycles between weapon stand, floor drop, and crate), d1 (random_weapon moves between corner seat, aisle, and under-seat stash), hub (SMG moves between three weapon rack positions along the north wall).
- Key location: KEY spawns 50% in c2 (Champion's Hall) in the trophy case, 50% in d2 (Beast Cages) on the cage keeper's hook. A second KEY spawns 50% in d2 (Beast Cages) in a hidden cage compartment, 50% in b2 (Armory) beneath the weapon crate.
