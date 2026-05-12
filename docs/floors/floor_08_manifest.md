# Floor 8 — Ballroom (Pride)

## Atmosphere
- Colour palette: #2A2A2A black floor (marble tiles, ballroom base), #1A1A1A obsidian walls (paneled, absorbing light), #DAA520 royal gold (chandelier frames, crown moulding, door trim, Consort's regalia), #F5F5F0 ivory white (tablecloths, statues, marble columns), #8B0000 deep red (carpet runner down corridors, draping fabric, bloodstains beneath polish).
- Musical theme: Grand waltz in a minor key — strings and harpsichord. The tempo accelerates when guards enter formation. A single off-key piano note punctuates each chandelier crash. The waltz distorts and fragments as Royal Guards die, losing instrumentation one by one.
- Sensory hook: The explosive crunch of a chandelier detonating against marble — crystal shards skittering across the floor followed by ringing silence before the waltz resumes.

## Encounter Manifest

### Room a1 — Grand Staircase
- Size: 10x6 tiles.
- Type: corridor.
- Spawn:
  - 1x Royal Guard at (5,3).
- Loot: none.
- Hazards: none.
- Special mechanics: Introduction room. Royal Guard stands at attention at the top of the staircase, teaching the player the formation combat system. Guard fights solo — no formation available. Staircase tiles slope visually from (0,5) to (9,0).
- Recipe: 01-Ambush.
- Lore element: The bannister is carved with names of every guest who danced here. Your name is at the bottom. The date is blank.
- Exits: north -> a2.

### Room a2 — Portrait Gallery
- Size: 12x8 tiles.
- Type: gallery.
- Spawn:
  - 2x Royal Guard at (3,2), (9,6).
- Loot: none.
- Hazards: none.
- Special mechanics: Two Royal Guards patrol in loose Line formation along the gallery. Portraits on the walls are interactable — examining them reveals lore fragments about the Consort and the hotel's history of "entertainment." Guards coordinate: if one engages, the other repositions to flank within 3 seconds.
- Recipe: 04-ShieldWall.
- Lore element: The portraits depict the same man in different eras — always smiling, always wearing a crown. In the most recent, the crown is made of chandelier crystal.
- Exits: south -> a1, east -> hub.

### Room hub — The Ballroom
- Size: 20x16 tiles.
- Type: hub.
- Spawn:
  - 2x Royal Guard at (5,4), (14,4).
  - 1x Champion at (10,8).
- Loot: Shotgun at (18,2).
- Hazards: CHANDELIER ROOM — three chandeliers suspended at (5,6), (10,6), (15,6). Each has HP 30. When destroyed, falls for 40 AoE damage in radius 60px (approximately 2-tile blast). Crystal shards remain on floor as slow-down hazard for 10 seconds after impact.
- Special mechanics: Central hub. Grand ballroom space with marble columns at (3,3), (7,3), (13,3), (17,3), (3,12), (7,12), (13,12), (17,12). Columns provide cover from Royal Guard advances. Champion patrols the centre — teaches the player that Champions are elite variants with more HP and faster reaction to player behavior. Gold fixtures on the walls are destructible and drop visual coins (no gameplay value, cosmetic only).
- Recipe: 03-Crossfire.
- Lore element: The orchestra pit at the north end is empty. The instruments are playing themselves. The sheet music is blank.
- Exits: west -> a2, north -> b1, east -> c1, south -> d1, centre-north -> boss.

### Room b1 — Champagne Hall
- Size: 10x8 tiles.
- Type: corridor.
- Spawn:
  - 2x Royal Guard at (2,2), (8,6).
  - 1x Cultist at (5,4).
- Loot: Axe at (9,1).
- Hazards: Champagne towers at (3,5) and (7,3) — destructible, create 2-tile slippery floor zones when broken (player slides 1 tile in movement direction, no damage).
- Special mechanics: Royal Guards fight in Wedge formation with Cultist at the rear providing support. Guards try to funnel player toward the champagne towers. If towers are destroyed, the slippery floor disrupts player movement but also affects Guard pathing.
- Recipe: 07-Pincer.
- Lore element: Every champagne glass is full. None of them have bubbles. The liquid is the same temperature as a human body.
- Exits: south -> hub, east -> b2.

### Room b2 — Trophy Room
- Size: 8x8 tiles.
- Type: storage.
- Spawn:
  - 1x Champion at (4,4).
- Loot: stat_upgrade at (6,2), KEY at (6,2) — 50% chance spawn per seed.
- Hazards: Trophy cases along walls — destructible, drop gold coins (cosmetic) and occasionally a single shotgun shell.
- Special mechanics: Single Champion guards the trophy room. No formation support — fights with Elite AI enabled. Learns from player behavior: if player uses ranged attacks, Champion closes distance faster. If player uses melee, Champion times parries. Small room means nowhere to kite.
- Recipe: 11-Turtle.
- Lore element: The trophies are all first-place awards. The categories are things like "Most Devoted Guest" and "Longest Stay." The current year's trophy has your name engraved on it already.
- Exits: west -> b1.

### Room c1 — Throne Antechamber
- Size: 12x10 tiles.
- Type: chamber.
- Spawn:
  - 3x Royal Guard at (2,2), (10,2), (6,7).
  - 1x Cultist at (3,8).
- Loot: Sword at (11,1).
- Hazards: LOCKED — requires KEY to enter. Red carpet runner creates a visual funnel — player instinctively walks the centre line, which is where the Surround formation targets.
- Special mechanics: LOCKED room — requires KEY from b2, c2, or d2. Three Royal Guards form Surround formation when player enters — positions triangulate around the player's entry point. Cultist provides ranged support from the rear. The most dangerous room on the floor by enemy count. Throne at (6,1) is a set piece — approaching it triggers a brief dialogue from the Consort (voice through walls): "That seat is reserved."
- Recipe: 13-Phalanx.
- Lore element: The antechamber walls are lined with ancient hotel receipts. The totals are in currencies that don't exist. One is dated tomorrow.
- Exits: west -> hub, east -> c2.

### Room c2 — The Golden Chamber
- Size: 8x8 tiles.
- Type: gallery.
- Spawn:
  - 1x Champion at (3,5).
  - 1x Cultist at (6,2).
- Loot: KEY at (4,4) — 50% chance spawn per seed. Ammo at (7,7).
- Hazards: Gold leaf on walls reflects light — brief flash effect when weapons fire, momentary visibility reduction (0.3s) for player and enemies alike.
- Special mechanics: Champion and Cultist coordinate — Cultist lures with suppressive fire while Champion flanks through the gold-flecked shadows. Small but dense room. The golden walls make it hard to track enemy positions during combat due to flash interference.
- Recipe: 12-BaitAndSwitch.
- Lore element: Everything in this room is gold-plated. Underneath the plating, the original materials are bone.
- Exits: west -> c1.

### Room d1 — Crystal Gallery
- Size: 10x8 tiles.
- Type: gallery.
- Spawn:
  - 2x Royal Guard at (3,2), (7,6).
  - 1x Champion at (5,4).
- Loot: Bat at (1,7).
- Hazards: Crystal display cases along walls — destructible, create 1-tile difficult terrain (glass shards) when broken.
- Special mechanics: Royal Guards form Line formation blocking the gallery's centre. Champion commands from behind the line, learning from player approach. If player attacks from range, Guards advance in Shield Wall. If player rushes, Champion flanks through the crystal displays.
- Recipe: 17-EliteEscort.
- Lore element: The crystals contain trapped light. If you look closely, each one contains a tiny scene — a guest, screaming silently, forever.
- Exits: north -> hub, east -> d2.

### Room d2 — The Vault of Faces
- Size: 10x10 tiles.
- Type: storage.
- Spawn:
  - 2x Royal Guard at (2,3), (8,7).
  - 1x Champion at (5,5).
- Loot: Random weapon at (8,1). KEY at (1,8) — 50% chance spawn per seed.
- Hazards: Mask displays on walls — some masks emit a brief fear effect (0.5s movement slowdown) when player passes within 1 tile.
- Special mechanics: Final optional combat room. Royal Guards and Champion fight in coordinated Surround formation. Champion has been "learning" from all previous encounters on this floor — if the player has relied on a specific tactic (kiting, melee rush, chokepoint), the enemies counter it here. Mask fear effects can chain if player is not careful with positioning.
- Recipe: 20-WaveGate.
- Lore element: The masks on the walls are all the same face. They are all your face. Each one shows a different expression — and none of them are afraid.
- Exits: west -> d1.

### Room boss — The Consort's Ballroom
- Size: 18x14 tiles.
- Type: boss.
- Spawn:
  - 1x The Consort at (9,3).
  - 4x Royal Guard at (3,5), (15,5), (6,9), (12,9).
- Loot: Cult artifact (random) — dropped on kill.
- Hazards: CHANDELIER ROOM — four chandeliers at (4,4), (9,4), (14,4), (9,9). HP 30 each. Falling chandelier deals 40 AoE damage in 2-tile radius. Strategic tool against Royal Guards and Consort.
- Special mechanics: Squad Command — Consort commands 4 Royal Guards with specific formations. Shield Wall: Guards form a line between Consort and player. Surround: Guards triangulate around player. Pinch: Two Guards close from opposing sides. Royal Guard grab: a Guard immobilizes the player for 1.5s, setting up a ritual stab from Consort for 40 damage. Breaking formation requires killing or significantly damaging one Guard. Consort summons 1 replacement Guard every 30 seconds from the room's east and west archways. Maximum 4 Guards at any time.
- Recipe: Standard.
- Lore element: The Consort's throne is at the north end. It is identical to the hotel's front desk. He has always been checking you in.
- Exits: south -> hub (entry), stairs (exit on kill).

## Mini-boss Spec

### Intro
- Trigger: Player enters boss room from hub.
- Cinematic: 2-3s slow-zoom on The Consort seated at his throne, surrounded by four Royal Guards in perfect formation. He rises, adjusts his crown of chandelier crystal, and descends the steps. The guards snap to attention.
- Boss intro text: "Every guest must dance. The only question is who leads."

### Arena
- Size: 18x14 tiles.
- Hazards: Four chandeliers (destructible, strategic). Broken chandelier shards create 1-tile difficult terrain for 10s after impact. Ornamental pillars at (3,3), (15,3), (3,11), (15,11) provide partial cover.
- Breakable cover: Ornamental pillars (HP 80, absorb damage but crumble after sufficient hits). Gold trim along walls (cosmetic destruction).
- Entry: south wall, from hub.

### Phases
- Phase 1 "Retinue" (4 Guards alive): Consort stands safely behind Shield Wall. Commands coordinated patterns — Surround to trap, Pinch to pressure, Shield Wall to protect himself. Consort does not attack directly. Player must break formation by killing at least one Guard to create an opening. Guards in formation take 20% less damage (formation bonus). Chandeliers can be dropped on clustered formations for massive damage. If a Guard is killed, remaining Guards reposition into the next strongest formation within 2 seconds.
- Phase 2 "Court" (2-3 Guards alive): Consort begins to panic — commands become more aggressive but less coordinated. Formation bonus drops to 10%. Throws ornamental daggers dealing 15 damage each, aimed at player's last known position. Guards attack more frequently but with less discipline — they break formation to pursue. Consort moves around the arena, no longer staying behind the Shield Wall. Dialogue between attacks: "This is MY floor! You are a GUEST!"
- Phase 3 "Alone" (0-1 Guards alive): Consort fights directly with desperate fury. Rapier Thrust: fast long-range stab dealing 25 damage with narrow hitbox. Fan Swipe: wide cone attack dealing 20 damage with knockback 2 tiles. Summon: 3-second channel (interruptible with sufficient damage) that calls a new Royal Guard from an archway. Desperate Scream: AoE stun for 0.5s centered on Consort, then immediately sprints to the nearest archway to begin a Summon. If summon succeeds, loops back to Phase 2 behavior temporarily. At 10% HP: Consort's crown shatters, he drops to his knees. Dialogue: "You... you were supposed to stay."

### Reward
- Kill reward: Cult artifact (random selection from floor-themed pool).
- Exit: Stairs revealed behind the Consort's throne, descending to Floor 9.

## Difficulty Curve
- Expected kills: 20 enemies across floor (Royal Guards: 13, Champions: 5, Cultists: 3, plus boss with 4+ guards).
- Expected time: 14-20 min.
- Hazard density: med.
- Enemy density: high.

## Replayability
- Branch-gated rooms: On 35% of seeds, room c1 (Throne Antechamber) has its lock connected to a KEY only in d2, forcing the full d-branch traversal. On 25% of seeds, room b2 (Trophy Room) has the Champion replaced with a Royal Guard, reducing b-branch difficulty as compensation for a harder c-branch.
- Random loot locations: Room d2 random weapon varies per seed (full weapon pool). Room hub Shotgun shifts between (18,2) and (1,14) based on seed. Room b2 stat_upgrade type alternates between health and speed on a per-seed basis.
- Key location: KEY spawns in exactly one of b2, c2, or d2 per run (33/33/34 split). When c2 holds the KEY, the player must commit to the longer c-branch combat chain before accessing c1. When d2 holds the KEY, the player must clear the most formation-dense rooms on the floor.
