# Floor 1 — Service Underground (Sloth)

## Atmosphere
- Colour palette: `#4A4A3E` (concrete floor — drab olive-grey, primary ground), `#2A2A2E` (basement walls — near-black blue-grey, perimeter), `#7A5A2E` (rust stains — warm brown, hazard highlights and pipes), `#8A7A5A` (brass fixtures — muted gold, interactable objects and loot glints).
- Musical theme: Low drones on distorted tuba and bowed metal. A slow 4/4 heartbeat kick drum fades in during combat. Silence between rooms is diegetic — dripping water, humming pipes.
- Sensory hook: A flickering fluorescent tube that buzzes louder as enemies approach. The light stutter-syncs with the background music beat.

## Encounter Manifest

### Room a1 — Entry Shaft
- Size: 8x6 tiles.
- Type: corridor.
- Spawn:
  - 0 enemies (safe zone).
- Loot: none.
- Hazards: none.
- Lore element: A rusted service ladder descends from a sealed manhole above. Scratched tallies on the wall count 47 days. Whoever was here before stopped counting.
- Exits: south → a2.

### Room a2 — Service Corridor
- Size: 12x4 tiles.
- Type: corridor.
- Spawn:
  - 2x Staff at (3,2), (9,2).
- Loot: Knife on shelf at (11,1).
- Hazards: none.
- Recipe: 02 (Chokepoint variant — enemies converge from both ends of the narrow hall).
- Lore element: Name tags on a bulletin board: "Rodriguez", "Chen", "Kowalski". All crossed out in red wax.
- Exits: north → a1, south → hub.

### Room hub — Boiler Room
- Size: 14x12 tiles.
- Type: hub.
- Spawn:
  - 2x Staff at (3,3), (11,9).
  - 1x Guard at (7,6).
- Loot: Bat leaning against boiler at (1,10).
- Hazards: burst steam pipe at (6,4) — 10 dmg/s if walked through, cycles 3s on / 3s off.
- Recipe: 05 (Hub defence — Guard holds centre, Staff flank on patrol routes).
- Lore element: The central boiler has a nameplate: "HOTEL INFERNO — Model 666-B". A child's drawing is magnetized to it, depicting a stick figure family smiling inside a house that is on fire.
- Exits: north → a2, east → b1, west → c1, south → d1.

### Room b1 — Laundry Room
- Size: 10x8 tiles.
- Type: branch.
- Spawn:
  - 3x Staff at (2,2), (5,5), (8,6).
- Loot: Pistol tucked inside laundry cart at (9,1).
- Hazards: none.
- Recipe: 07 (Flanking trio — enemies take positions behind washing machines, rotate to maintain line of sight).
- Lore element: Industrial washers still tumbling. The loads inside are all identical white uniforms, fresh-pressed. Each one is stained at the collar with something that is not dirt.
- Exits: west → hub, east → b2.

### Room b2 — Linen Storage
- Size: 6x6 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Staff at (4,3).
- Loot: Ammo at (1,1). Stat upgrade (Vitality Shard) hidden behind shelving at (5,5). KEY spawns here at 50% seed weight.
- Hazards: none.
- Lore element: Shelves of perfectly folded sheets. One shelf is different — the linen here is coarse, brown, and smells of copper. It is stacked with surgical precision.
- Exits: west → b1.

### Room c1 — Meat Processing
- Size: 12x10 tiles.
- Type: branch (LOCKED — requires Key).
- Spawn:
  - 1x Handler at (6,5).
  - 2x Staff at (2,2), (10,8).
- Loot: Axe embedded in cutting block at (1,9).
- Hazards: meat grinder at (11,1) — instant kill zone if pushed in (environmental, 999 dmg). Blood pools at (3,7), (8,3) — slippery, no damage but -50% move speed for 1s.
- Recipe: 09 (Handler + entourage — Handler commands Staff to advance, retreats to grinder to bait player).
- Lore element: A chalkboard lists cuts: "LOIN — RACK — SHANK — LONG PIG". The last item is fresher than the others.
- Exits: east → hub, west → c2.

### Room c2 — Freezer Room
- Size: 8x8 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Guard at (4,4).
- Loot: KEY spawns here at 50% seed weight (opposite b2). Ammo at (7,7).
- Hazards: fog particles reduce visibility to 4 tiles. Frost patches at (2,2), (6,6) — slippery.
- Recipe: 04 (Lone sentinel — Guard patrols centre, very alert, 2x aggro range in fog).
- Lore element: Meat hooks hang from the ceiling, swaying gently as if someone just left. Body-shaped silhouettes are wrapped in plastic along the north wall. One of them is breathing.
- Exits: east → c1.

### Room d1 — Maintenance Tunnels
- Size: 16x4 tiles.
- Type: corridor (long).
- Spawn:
  - 2x Staff at (4,2), (12,2).
  - 1x Guard at (8,1).
- Loot: Wire (crafting material) on workbench at (15,1).
- Hazards: exposed electrical junction at (9,2) — 8 dmg shock on contact, arcs every 4s.
- Recipe: 03 (Guntlet — enemies staggered along a linear path, Guard holds the midpoint).
- Lore element: Graffiti on the tunnel walls in white paint: "THEY FEED US TO THE MACHINE". Below it, in different handwriting: "No. We feed ourselves."
- Exits: north → hub, south → d2.

### Room d2 — Generator Room
- Size: 10x8 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Guard at (3,5).
  - 1x Staff at (8,2).
- Loot: KEY spawns here at 50% seed weight (opposite b2). Random weapon on tool rack at (9,7).
- Hazards: generator hum zone at (5,4) — standing within 2 tiles muffles all audio cues for the player (no danger, disorientation).
- Recipe: 06 (Sweeper pair — Guard pushes player toward Staff who has ranged position).
- Lore element: The generator has a hand-crrank and a label: "EMERGENCY USE ONLY — DO NOT STOP". It has never been stopped. The fuel line runs red.
- Exits: north → d1.

### Room boss — Head Chef's Kitchen
- Size: 16x14 tiles.
- Type: boss arena.
- Spawn:
  - 1x Head Chef at (8,7).
- Loot: Cult artifact (random) dropped on kill.
- Hazards:
  - Industrial stoves along north wall at (4,0)-(6,0), (9,0)-(11,0) — fire hazard, 15 dmg/s if touched. Stoves can be pushed into boss for 40 dmg.
  - Meat hooks at (2,3), (13,3), (2,10), (13,10) — destructible, collapse on destruction dealing 25 dmg in 2-tile radius. Can be shot to drop on boss.
  - Grease spills at (5,6), (10,7), (7,11) — slippery, no damage, slide 2 tiles in movement direction.
- Breakable cover: prep tables at (4,5), (11,5), (4,9), (11,9) — 2 hits to destroy.
- Entry: from hub (north door). 4 total entry points (N, S, E, W). E and W locked during fight.
- Lore element: The kitchen is spotless. Immaculate. Every knife is sharpened, every pot polished. The Head Chef stands at the central island, seasoning something you cannot see. He says: "You are early. The main course has not yet arrived. No matter. We will make do with the appetizer."
- Exits: north → hub (post-fight). Stairs down at (8,13) → Floor 2.

## Mini-boss Spec

### Intro
- Trigger: player enters Head Chef's Kitchen from hub.
- Cinematic: 2.5s slow-zoom from door to Head Chef at (8,7). Camera pans across stoves (flames flare), hooks (sway), then settles on the Chef's face. He sharpens a cleaver once.
- Boss intro text: "The Head Chef has been cooking longer than the Hotel has been standing."

### Arena
- Size: 16x14 tiles.
- Hazards: fire stoves (15 dmg/s), meat hooks (destructible, 25 dmg on fall), grease (slippery).
- Breakable cover: 4x prep tables (2 hits each, HP 30).
- Entry: from hub (north door). East and west doors lock on encounter start, unlock on Chef death.

### Phases
- Phase 1 "Service" (100-60% HP): The Chef fights with professional efficiency. Cleaver Sweep (35 dmg, 2-tile arc melee). Charge (25 dmg + 0.8s stun, dashes 6 tiles toward player). Pot Toss (20 dmg + burn 5 dmg/s for 3s, AoE 2-tile radius, thrown from stove positions). Kitchen Call (summons 1 Staff from a side door, cooldown 20s).
- Phase 2 "Main Course" (60-30% HP or 1 limb lost): The Chef's apron tears. Speed +20%. Furious Chop (50 dmg + knockdown 1.0s, 1-tile melee, wind-up 0.6s). Meat Hook Swing (30 dmg + pull player 3 tiles toward Chef, uses ceiling hooks). Double Pot (two simultaneous Pot Toss AoEs). Rage Charge (40 dmg + wall stun 1.2s, 8-tile dash, rebounds off walls).
- Phase 3 "Dessert" (30-0% HP or 2+ limbs lost): The Chef is falling apart and desperate. Stove Push (pushes a stove 4 tiles, 30 dmg + leaves fire trail for 5s). Fling Everything (throws 3 random kitchen items in succession — each 15-25 dmg, random trajectory). Kitchen Call x3 (summons 3 Staff + 1 Guard from all doors, one-time trigger). Desperate Grab (grab attack, 8 dmg/s for 3s hold, must mash to escape).

### Reward
- Kill reward: random cult artifact.
- Exit: stairs at (8,13) to Floor 2.

## Difficulty Curve
- Expected kills: 17 (Staff x14, Guard x5, Handler x1).
- Expected time: 12-15 min.
- Hazard density: medium.
- Enemy density: medium.

## Replayability
- Branch-gated rooms: Branch C (c1 Meat Processing, c2 Freezer Room) is locked. Key is required. The other two branches (B and D) are always open.
- Random loot locations: d2 Generator Room random weapon (pool: Pistol, SMG, Shotgun, Axe, Wire — picks one). Boss cult artifact randomised from floor 1 artifact pool.
- Key location: b2 Linen Storage (50% seed) or d2 Generator Room (50% seed). When key is in b2, player can immediately unlock Branch C. When key is in d2, player must traverse the long Maintenance Tunnels first, increasing encounter count before the locked branch.
