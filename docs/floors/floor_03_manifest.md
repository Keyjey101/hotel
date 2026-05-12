# Floor 3 — Banquet Hall (Gluttony)

## Atmosphere
- Colour palette: `#2A1508` (floor — dark mahogany-brown, primary ground, warped wood planks), `#1A0A04` (walls — deepest umber, almost black, wainscoting and panels), `#B8860B` (gold — candlelight glow, table settings, loot shimmer), `#6B0020` (burgundy — wine stains, curtains, dried blood on servingware).
- Musical theme: A grotesque waltz played on overweight strings and a detuned harpsichord. The tempo matches the player's movement speed — walking is 3/4 time, running accelerates to 6/8. A wet, smacking percussion layer fades in whenever the Gourmand eats. Cello drones sustain between rooms.
- Sensory hook: The sound of chewing. Constant, wet, unmistakable chewing. It comes from beyond every wall, under every floorboard. When combat starts, it stops — replaced by a single, held fork-scrape on a china plate that rises in pitch until the last enemy dies. Then the chewing resumes.

## Encounter Manifest

### Room a1 — Grand Foyer
- Size: 10x8 tiles.
- Type: corridor.
- Spawn:
  - 2x Staff at (3,2), (7,6).
- Loot: none.
- Hazards: overturned food cart at (5,4) — oil spill covers (4,3)-(6,5), slippery zone.
- Recipe: 01 (Standard — enemies spread evenly, patrol short routes).
- Lore element: A coat check window with numbered tags. The numbers go up to 999. All tags are gone. Behind the counter, coats hang in perfect rows, each with a name sewn into the collar. You do not recognise any of the names. You recognise all of the sizes.
- Exits: south → a2.

### Room a2 — Wine Cellar Stairs
- Size: 8x6 tiles.
- Type: corridor.
- Spawn:
  - 1x Staff at (4,4).
- Loot: Ammo at (1,5).
- Hazards: none.
- Lore element: Wine racks line the descending stairs. Every bottle is labelled with a year, but the years are in the future. One bottle is already open. It is still warm.
- Exits: north → a1, south → hub.

### Room hub — The Banquet Hall
- Size: 20x16 tiles.
- Type: hub.
- Spawn:
  - 1x Chef at (6,4).
  - 1x Taster at (15,4).
  - 3x Staff at (3,8), (10,8), (17,8).
  - 1x Guard at (10,12).
- Loot: Shotgun under banquet table at (10,14).
- Hazards:
  - Central banquet table at (4,6)-(16,10) — large obstacle, can be used as cover. Table can be flipped (interact action) to create barricade on one side (blocks movement, provides full cover). Flipping takes 1.5s.
  - Oil/grease spill at (2,3), (18,13) — slippery zones.
  - Boiling pot at (19,1) — 20 dmg/s, active for 4s then off for 6s, cycles.
- Recipe: 13 (Grand melee — Chef and Taster hold opposite ends of the table, Staff patrol the perimeter, Guard anchors the south. Player can flip table to split the engagement.)
- Lore element: The banquet table is set for a feast. Candelabras, silverware, crystal. Plates are laid out at every setting, each heaped with food that is somehow still steaming. The centrepiece is a roasted bird of indeterminate species. It is too large to be a turkey. It has too many wings.
- Exits: north → a2, east → b1, west → c1, south → d1.

### Room b1 — Kitchen
- Size: 12x8 tiles.
- Type: branch.
- Spawn:
  - 2x Chef at (3,2), (9,6).
  - 1x Staff at (6,4).
- Loot: Axe on butchers block at (11,1).
- Hazards:
  - Stove line at (0,0)-(0,7) — fire hazard, 15 dmg/s on contact.
  - Boiling pots at (2,1), (10,1) — 20 dmg/s, active 4s / off 6s.
  - Spoiled food poison zone at (7,5) — 3 dmg/s while standing in 2-tile radius, green particle effect.
- Recipe: 12 (Kitchen double — Chefs guard stove line and exit respectively, Staff runs interference between them).
- Lore element: This kitchen is larger than the one on Floor 1 and somehow older. The equipment is antique — cast iron, hand-cranked, stained black with use. A recipe book lies open on the counter. The page reads: "PREPARATION: Alive. COOKING TIME: Does not end. SERVING: Forever."
- Exits: west → hub, east → b2.

### Room b2 — Pantry
- Size: 6x6 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Staff at (3,3).
- Loot: Ammo at (1,1). Stat upgrade (Fortitude Shard) behind loose brick at (5,5). KEY spawns here at 50% seed weight.
- Hazards: spoiled food poison zones at (2,2), (4,4) — 3 dmg/s in 1-tile radius.
- Lore element: Shelves are stocked with jars. The labels are plain: "MEAT", "BROTH", "FAT", "BONE", "OTHER". The "OTHER" jars are the only ones that are sealed. The others have been opened and resealed many times. Some of them are breathing.
- Exits: west → b1.

### Room c1 — Dessert Chamber
- Size: 10x8 tiles.
- Type: branch (LOCKED — requires Key).
- Spawn:
  - 2x Taster at (2,3), (8,5).
  - 1x Staff at (5,2).
- Loot: SMG inside sugar cabinet at (9,7).
- Hazards:
  - Sugar dust clouds at (4,4), (6,6) — reduce visibility to 2 tiles while inside the cloud. Dissipate after 10s, reform after 20s.
  - Caramel pool at (1,6) — sticky zone, -60% move speed, no damage.
- Recipe: 14 (Sweet trap — Tasters lurk behind sugar clouds for ambush, Staff guards the loot cabinet).
- Lore element: The room is white with powdered sugar. Dessert displays line every surface — cakes, pastries, confections of impossible intricacy. Every single one contains something that is not food. Teeth, mostly. Some rings.
- Exits: east → hub, west → c2.

### Room c2 — The Grotto
- Size: 8x8 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Guard at (4,4).
- Loot: KEY spawns here at 50% seed weight (opposite b2). Ammo at (7,7). Cult artifact at (1,1) — 10% chance per run, otherwise random ammo.
- Hazards:
  - Stalactite drip zone at (3,3)-(5,5) — water pools, slippery.
  - Fermentation gas pocket at (2,6) — if shot or ignited, 15 dmg AoE explosion in 2-tile radius, one-time.
- Recipe: 04 (Lone sentinel — Guard patrols in a tight diamond around the centre, high alert).
- Lore element: A natural cave beneath the Hotel, converted into a wine grotto. The walls are damp and the air is sweet with rot. Wine barrels line the walls, but the spigots leak something thick and red. It is not wine. The barrels are labelled with body weights.
- Exits: east → c1.

### Room d1 — Dining Gallery
- Size: 12x8 tiles.
- Type: corridor (wide).
- Spawn:
  - 1x Chef at (2,4).
  - 1x Taster at (10,3).
  - 2x Staff at (5,2), (8,6).
- Loot: Wire (crafting material) inside candelabra at (11,7).
- Hazards:
  - Overturned dining chairs at (3,1), (7,5) — small obstacles, block movement, can be kicked aside (0.3s).
  - Spoiled food poison zone at (6,4) — 3 dmg/s in 2-tile radius.
  - Grease trail at (4,3)-(6,3) — slippery path.
- Recipe: 15 (Gallery ambush — Chef holds near entry, Taster snipes from gallery rail, Staff create chaos in the middle).
- Lore element: Paintings of past banquets hang in gilded frames. In each painting, the guests are the same, but their plates are progressively emptier while their stomachs are progressively larger. In the last painting, the guests are eating each other. They are smiling.
- Exits: north → hub, south → d2.

### Room d2 — Smoke Room
- Size: 8x8 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Staff at (6,2).
  - 1x Guard at (3,5).
- Loot: KEY spawns here at 50% seed weight (opposite b2). Stat upgrade (Endurance Shard) inside cigar box at (7,7).
- Hazards:
  - Smoke haze at (2,2)-(5,6) — reduces visibility to 3 tiles, no damage. Smoke dissipates 30s after room is entered.
  - Cigar ember at (1,3) — 5 dmg on contact, can ignite smoke (fire flash, 12 dmg AoE, one-time).
- Recipe: 06 (Sweeper pair — Guard blocks access to key/shard, Staff patrols near entry).
- Lore element: Leather armchairs sit in a circle, each with an ashtray on the armrest. The ashtrays are full. One chair has an indentation in the cushion that suggests the sitter weighed over 400 pounds. The cigar smoke smells like burning hair.
- Exits: north → d1.

### Room boss — The Gourmand's Table
- Size: 16x14 tiles.
- Type: boss arena.
- Spawn:
  - 1x The Gourmand at (8,7).
- Loot: Cult artifact (random) dropped on kill.
- Hazards:
  - Central feast table at (4,4)-(12,10) — massive obstacle, can be used as cover. Table is loaded with food. The Gourmand eats from it to heal (see mechanics).
  - Oil/grease spills at (2,2), (14,2), (2,12), (14,12) — slippery zones.
  - Boiling pots at (0,5), (15,5), (0,9), (15,9) — 20 dmg/s, active 4s / off 6s.
  - Spoiled food poison zones at (1,7), (14,7) — 3 dmg/s in 2-tile radius.
- Breakable cover: 4x serving carts at (3,2), (13,2), (3,12), (13,12) — 2 hits to destroy, HP 35. Can be pushed 1 tile as a move action to reposition.
- Entry: from hub (north door).
- Lore element: The room is a cathedral of consumption. Chandeliers of bone hang from chains. The walls are lined with serving stations, each attended by a motionless Staff member who watches with dead eyes. At the head of the table, a throne made of fused cutlery. The Gourmand sits in it. He is enormous. He is still growing. He looks at the player and licks his lips. "You are just in time," he says. "I have saved the best course for last."
- Exits: north → hub (post-fight). Stairs down at (8,13) → Floor 4.

## Mini-boss Spec

### Intro
- Trigger: player enters The Gourmand's Table from hub.
- Cinematic: 3s slow-zoom from entry to The Gourmand at (8,7). Camera starts on the feast table (pans across steaming food), rises to the bone chandeliers, then settles on the Gourmand's face. He swallows something. He smiles. A burp shakes the camera.
- Boss intro text: "The Gourmand has never stopped eating. The Hotel keeps serving. He will never be full."

### Arena
- Size: 16x14 tiles.
- Hazards: grease spills (slippery), boiling pots (20 dmg/s cycling), poison zones (3 dmg/s), central feast table (obstacle + Gourmand healing source).
- Breakable cover: 4x serving carts (2 hits, HP 35, pushable 1 tile).
- Entry: from hub (north door).

### Unique Mechanic: Consumption
- The Gourmand eats corpses to grow. Any enemy that dies in the arena (summoned minions) leaves a corpse. The Gourmand will path toward corpses and consume them over 2s.
- Each corpse eaten: +25 HP heal, +5% damage to all attacks, +0.1x size multiplier.
- Player must destroy corpses (melee attack on downed enemy, 0.5s action) or knock them off the table to deny healing.
- The Gourmand can also eat from the feast table for 15 HP (does not increase damage/size), 3s action, table has infinite uses.

### Phases
- Phase 1 "Appetizer" (normal — 0-1 corpses eaten): The Gourmand is slow but massive. Slow Walk (moves at 60% player speed, cannot sprint). Belly Bump (25 dmg melee, 1-tile knockback, 0.4s wind-up — his belly jiggles before the hit). Vomit Spray (cone attack, 15 dmg + slow 30% for 3s, 3-tile range, 45-degree cone, 8s cooldown). Summons 1x Staff from side doors every 15s (corpses left by Staff are the Gourmand's food source).
- Phase 2 "Main Course" (triggered after 2+ corpses eaten): The Gourmand grows to 1.5x size. Speed increases to 80% player speed. Belly Flop AoE (30 dmg + knockdown 1.0s, jumps to player position, 3-tile impact radius, 12s cooldown, 0.8s air time — shadow on ground shows landing zone). Grab + Devour (melee grab, 10 dmg/s hold, Gourmand chews on the player for up to 4s, player must mash to escape — if not escaped in 4s, swallowed for instant 50 dmg + spit out). Summons 1x Taster every 20s (Tasters are worth more HP to the Gourmand if eaten — he prioritises their corpses). Boiling pots begin cycling faster (4s on / 3s off).
- Phase 3 "Digestif" (triggered after 4+ corpses eaten OR HP drops below 30%): The Gourmand grows to 2x size. Speed increases to 100% player speed. Rolling Charge (50 dmg, rolls across entire arena width, destroys breakable cover on contact, rebounds off walls once, 15s cooldown). Acid Pool (spews persistent acid zone at player position, 10 dmg/s, lasts 8s, zone is 3x3 tiles, 10s cooldown). Desperate Consumption (eats own severed limbs — if he has lost any limbs, he regenerates 30 HP per limb consumed, can trigger once per limb, does not reduce his combat capability). The feast table begins to crack — after 30s in P3, the table collapses and can no longer be eaten from. All remaining serving carts explode outward (15 dmg in 2-tile radius each).

### Reward
- Kill reward: random cult artifact.
- Exit: stairs at (8,13) to Floor 4.

## Difficulty Curve
- Expected kills: 21 (Staff x13, Chef x3, Taster x4, Guard x2).
- Expected time: 15-20 min.
- Hazard density: high.
- Enemy density: high.

## Replayability
- Branch-gated rooms: Branch C (c1 Dessert Chamber, c2 The Grotto) is locked. Key is required. Branch C also contains a 10% cult artifact chance in c2, rewarding key-seeking players.
- Random loot locations: c2 The Grotto cult artifact (10% chance, otherwise random ammo). b1 Kitchen encounter complexity varies with stove/pot timing. Boss difficulty scales non-linearly with corpse management — skilled players who destroy corpses will face an easier P2/P3, while careless players face an escalating challenge.
- Key location: b2 Pantry (50% seed) or d2 Smoke Room (50% seed). When key is in b2, the path through Kitchen is shorter but Kitchen has the densest hazard layout on the floor (stoves, boiling pots, poison zones). When key is in d2, the player must clear the long Dining Gallery first (more enemies, fewer hazards) then backtrack.
