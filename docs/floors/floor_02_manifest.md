# Floor 2 — Red Light District (Lust)

## Atmosphere
- Colour palette: `#1A0A15` (floor — deep bruise-mauve, primary ground), `#0A0A0F` (walls — absolute black, perimeter), `#8B0035` (crimson — blood-velvet, drapes and hazard highlights), `#FF1A6D` (neon pink — electric accent, signage and light sources).
- Musical theme: Slow jazz saxophone degraded through a vinyl crackle filter. A sensual bass line that speeds up during combat. Off-key piano strikes on enemy kills. The music should feel seductive and wrong simultaneously.
- Sensory hook: Neon signs that flicker and cast moving coloured shadows. When a neon sign flickers, every shadow in the room shifts, making it impossible to trust silhouettes for a half-second. The flicker rate increases with combat intensity.

## Encounter Manifest

### Room a1 — Velvet Entryway
- Size: 8x6 tiles.
- Type: corridor.
- Spawn:
  - 0 enemies (safe zone).
- Loot: none.
- Hazards: none.
- Lore element: A velvet rope hangs between brass stanchions. Beyond it, the carpet is red and immaculate. A hostess stand holds a reservation book. Every name in it is the same: "GUEST".
- Exits: south → a2.

### Room a2 — Neon Corridor
- Size: 12x4 tiles.
- Type: corridor.
- Spawn:
  - 2x Staff at (3,2), (9,2).
- Loot: SMG hidden behind collapsed neon sign at (11,1).
- Hazards: exposed neon tubing at (6,1) — 5 dmg shock on contact, flickers as warning.
- Recipe: 02 (Chokepoint variant — Staff take cover behind fallen signage, funnel player through centre).
- Lore element: Neon signs line both walls: "LIVE GIRLS", "PEEP SHOW", "PRIVATE". One sign reads "EXIT" but the letters are burnt out. It has never led out.
- Exits: north → a1, south → hub.

### Room hub — The Lounge
- Size: 14x12 tiles.
- Type: hub.
- Spawn:
  - 1x Seductress at (10,3).
  - 1x Bodyguard at (7,8).
  - 2x Staff at (2,2), (12,10).
- Loot: Bat under bar counter at (1,11).
- Hazards: broken glass on floor at (5,5), (9,7) — 3 dmg per step, -30% move speed while standing on it.
- Recipe: 05 (Hub defence — Seductress holds elevated platform NE, Bodyguard patrols central bar, Staff cover flanks).
- Lore element: A circular bar dominates the centre. Bottles line every shelf, but every label reads "HOUSE SPECIAL". The bar stools are worn smooth from use, facing a stage that has no performer. Yet the spotlight is on.
- Exits: north → a2, east → b1, west → c1, south → d1.

### Room b1 — Hall of Mirrors
- Size: 14x12 tiles.
- Type: branch.
- Spawn:
  - 2x Seductress at (3,3), (11,9).
  - 1x Bodyguard at (7,6).
- Loot: Cult Blade (rare drop) on pedestal at (13,1) — 15% chance per run, otherwise 1x Ammo.
- Hazards: 8 mirror pillars at (2,2), (5,4), (9,4), (12,2), (2,9), (5,7), (9,7), (12,9) — indestructible, reflect projectiles (player bullets ricochet with 50% chance to hit player). Mirrors create visual copies of all entities (cosmetic only, no damage here).
- Recipe: 11 (Mirror maze — Seductress use mirrors for hit-and-run, Bodyguard charges through reflections to confuse targeting).
- Lore element: Every mirror shows the room slightly differently. In the reflections, the doors lead somewhere else. In one mirror, you can see a figure standing behind you. It is not there when you turn around.
- Exits: west → hub, east → b2.

### Room b2 — Peep Room
- Size: 6x6 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Staff at (4,4).
- Loot: Ammo at (1,1). Stat upgrade (Charisma Shard) behind loose panel at (5,5). KEY spawns here at 50% seed weight.
- Hazards: none.
- Lore element: Small viewing windows look into adjacent rooms. One window shows the Hall of Mirrors, but from an angle that does not exist. A chair faces the window. The cushion is still warm.
- Exits: west → b1.

### Room c1 — Silk Chamber
- Size: 10x8 tiles.
- Type: branch (LOCKED — requires Key).
- Spawn:
  - 2x Seductress at (2,3), (8,5).
- Loot: Pistol under silk pillow at (9,7).
- Hazards: silk curtains at (4,0)-(5,0) and (4,7)-(5,7) — block line of sight, can be walked through but slow movement by 40% for 1 tile. No damage.
- Recipe: 08 (Pincer pair — Seductress take opposite corners, use silk curtains as concealment for approach).
- Lore element: Silk drapes hang from every surface. The room smells of jasmine and something rotten underneath. A dressing table holds perfume bottles filled with a liquid that moves on its own.
- Exits: east → hub, west → c2.

### Room c2 — The Boudoir
- Size: 8x8 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Bodyguard at (4,4).
  - 1x Staff at (6,2).
- Loot: KEY spawns here at 50% seed weight (opposite b2). Ammo at (1,7).
- Hazards: candelabras at (2,1), (6,1) — open flame, 8 dmg/s on contact, can ignite silk drapes (fire spreads 1 tile/2s for 6s, 5 dmg/s in burning tile).
- Recipe: 06 (Sweeper pair — Bodyguard blocks centre, Staff flanks through drapes).
- Lore element: A four-poster bed dominates the room. The sheets are stained with lipstick in handprints that are too large for human hands. A music box on the nightstand plays a lullaby. It has no crank.
- Exits: east → c1.

### Room d1 — Red Light Gallery
- Size: 12x6 tiles.
- Type: corridor (wide).
- Spawn:
  - 1x Seductress at (2,3).
  - 1x Bodyguard at (6,2).
  - 2x Staff at (9,1), (10,4).
- Loot: Wire (crafting material) in display case at (11,5).
- Hazards: neon sign collapse zone at (5,0) — sign falls when player steps on (5,1) or (5,2), 15 dmg, one-time trap.
- Recipe: 10 (Gallery gauntlet — ranged Seductress at entry, Bodyguard mid-gallery, Staff cover the exit).
- Lore element: Paintings line the walls. Each depicts a scene of intimacy that becomes increasingly grotesque from left to right. The final painting is a portrait of the player, looking over their own shoulder.
- Exits: north → hub, south → d2.

### Room d2 — Dressing Room
- Size: 8x8 tiles.
- Type: branch-terminus.
- Spawn:
  - 1x Staff at (5,3).
  - 1x Guard at (2,6).
- Loot: KEY spawns here at 50% seed weight (opposite b2). Stat upgrade (Reflex Shard) in wardrobe at (7,7). Random weapon on vanity at (1,1).
- Hazards: cosmetics spill at (4,5) — slippery, no damage.
- Recipe: 04 (Sentinel + scout — Guard holds NW corner near key, Staff patrols near entry).
- Lore element: Vanities line the walls, each with a mirror. The mirrors reflect the room as it was 10 seconds ago. If you watch carefully, you can see enemies move before they round corners. The Hotel's cruelty has a sense of humour.
- Exits: north → d1.

### Room boss — Madame's Chamber
- Size: 14x12 tiles.
- Type: boss arena.
- Spawn:
  - 1x Madame at (7,6).
- Loot: Cult artifact (random) dropped on kill.
- Hazards:
  - 6x vanity mirrors (destructible) at (1,1), (12,1), (1,10), (12,10), (4,3), (9,3) — Madame uses these for teleportation. Breaking a mirror removes a teleport point. When shattered, mirror deals 10 dmg in 1-tile shard radius.
  - Central bed at (6,5)-(8,7) — large obstacle, indestructible, blocks movement and line of sight.
- Breakable cover: 2x chaise lounges at (2,6), (11,6) — 2 hits to destroy, HP 25.
- Entry: from hub (north door).
- Lore element: The room is a perfect mirror of The Lounge above, but inverted — the bar is a bed, the stage is a vanity, the bottles are candles. The Madame sits at her vanity, applying lipstick. She does not look up. "You found me," she says. "Or did I let you?" The lipstick she applies is the same crimson as the walls.
- Exits: north → hub (post-fight). Stairs down at (7,11) → Floor 3.

## Mini-boss Spec

### Intro
- Trigger: player enters Madame's Chamber from hub.
- Cinematic: 3s slow-zoom on Madame at vanity (7,6). She finishes applying lipstick, closes the compact, and stands. Camera pulls back to reveal mirror reflections showing her in multiple positions simultaneously. She turns to face the player.
- Boss intro text: "The Madame knows every face that enters the Hotel. She wears the ones she likes best."

### Arena
- Size: 14x12 tiles.
- Hazards: 6x vanity mirrors (destructible, teleport points, 10 dmg shard burst on break). Central bed (obstacle).
- Breakable cover: 2x chaise lounges (2 hits, HP 25).
- Entry: from hub (north door).

### Phases
- Phase 1 "Reflection" (100-50% HP): The Madame fights through her mirror clones. 2 mirror clones active (visual copies of Madame, deal 0 damage, exist to confuse targeting). Kiss (stun, 1.5s, melee range, no damage — sets up follow-ups). Dagger Swipe (15 dmg, quick melee). Kitchen Call equivalent: Madame summons no minions this phase. Breaking mirrors reduces active clone count (6 mirrors = 2 clones base; 3 mirrors = 1 clone; 0 mirrors = 0 clones). Strategy: destroy mirrors to strip her defence.
- Phase 2 "Shattered" (50-25% HP or 1 limb lost): Mirror clones now deal 5 dmg on contact (they are becoming real). 3 clones active if mirrors remain. Madame teleports between intact mirrors (0.5s vanish, reappear at mirror location). Mirror Shard Throw (20 dmg, piercing, travels through 1 entity, thrown from mirror position). Movement speed +15%. Breaking mirrors is now dangerous (shard burst) but still strategically vital.
- Phase 3 "True Face" (25-0% HP or 2+ limbs lost): All remaining mirrors shatter simultaneously (10 dmg each in radius, punishes players who left mirrors intact). Berserk mode — Madame is visible and real, no more clones. Dash (35 dmg, 5-tile lunge, 0.3s wind-up). Scream AoE (stun 1.0s, 3-tile radius centred on Madame, 15s cooldown). Summons 1x Bodyguard from entry door. Movement speed +30% over P1.

### Reward
- Kill reward: random cult artifact.
- Exit: stairs at (7,11) to Floor 3.

## Difficulty Curve
- Expected kills: 17 (Staff x9, Seductress x6, Bodyguard x4, Guard x1).
- Expected time: 10-14 min.
- Hazard density: medium.
- Enemy density: medium.

## Replayability
- Branch-gated rooms: Branch C (c1 Silk Chamber, c2 The Boudoir) is locked. Key is required. Branch B (Hall of Mirrors) is always open but contains the most complex encounter on the floor.
- Random loot locations: b1 Hall of Mirrors Cult Blade (15% rare drop, otherwise Ammo). d2 Dressing Room random weapon (pool: Pistol, SMG, Shotgun, Axe — picks one). Boss cult artifact randomised from floor 2 artifact pool.
- Key location: b2 Peep Room (50% seed) or d2 Dressing Room (50% seed). When key is in b2, the path is shorter but requires clearing the mirror maze. When key is in d2, player must clear the long gallery corridor first, then backtrack.
