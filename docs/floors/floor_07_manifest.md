# Floor 7 — Observatory (Envy)

## Atmosphere
- Colour palette: #1A1A6A deep indigo (floor tiles, dominant base), #0A0A2A deep space blue (walls, ceiling void), #C0C0D0 silver (railings, telescope fixtures, door frames), #4B0082 purple (nebula fog, accent lighting, Curator's aura), #E6E6FA starlight (light sources, particle effects, camera lenses).
- Musical theme: Slow, crystalline arpeggios over a low sustained drone. Celesta and glass harmonica textures. Dissonant intervals swell when cameras detect the player. Subtle breathing effect in dark rooms — music itself seems to watch.
- Sensory hook: The soft mechanical whirr of surveillance cameras rotating on their mounts, punctuated by a sharp red focus-lock beep when one finds you.

## Encounter Manifest

### Room a1 — Telescope Gallery
- Size: 10x6 tiles.
- Type: gallery.
- Spawn:
  - 1x Spy at (7,2).
- Loot: none.
- Hazards: none.
- Special mechanics: None active. Introduction room — teaches Spy invisibility. Spy is visible briefly on room entry before cloaking.
- Recipe: 08-HuntersDen.
- Lore element: A brass placard on the largest telescope reads "Property of the Curator — Do Not Touch. Do Not Look. Do Not Want."
- Exits: east -> a2.

### Room a2 — Star Map Corridor
- Size: 12x4 tiles.
- Type: corridor.
- Spawn:
  - 1x Shadow Stalker at (9,2).
- Loot: none.
- Hazards: none.
- Special mechanics: Shadow Stalker patrols the length of the corridor, phasing through the central display console. Player must time movement past the console or engage.
- Recipe: 02-Chokepoint.
- Lore element: Star maps on the ceiling chart constellations that don't exist in any known sky — some are labeled with guest room numbers.
- Exits: west -> a1, east -> hub.

### Room hub — The Library
- Size: 14x12 tiles.
- Type: hub.
- Spawn:
  - 2x Spy at (3,3), (10,8).
  - 1x Shadow Stalker at (7,6).
- Loot: Shotgun at (12,2).
- Hazards: none.
- Special mechanics: Central hub with four branching paths. Bookshelves provide concealment from cameras and Spies. Light sources at (2,1), (7,1), (12,1), (2,10), (7,10), (12,10) — standing near them reveals cloaked Spies and highlights Shadow Stalkers mid-phase.
- Recipe: 03-Crossfire.
- Lore element: Books on the shelves are bound in a material that feels like skin. Their titles are all synonyms for "want."
- Exits: west -> a2, north -> b1, east -> c1, south -> d1, centre-north -> boss.

### Room b1 — Restricted Archives
- Size: 10x8 tiles.
- Type: storage.
- Spawn:
  - 2x Spy at (2,2), (8,6).
  - 1x Shadow Stalker at (5,4).
- Loot: SMG at (9,1).
- Hazards: DARK ROOM — 60% darkness overlay. Visibility reduced to a 4-tile radius around the player. Light sources at (1,1) and (8,7) provide full reveal radius when approached.
- Special mechanics: Stealth Zone active. Spies are fully invisible until they attack. Shadow Stalkers can phase through the archive shelving. Player can hide in shadows between shelves to break enemy detection.
- Recipe: 19-DarknessFalls.
- Lore element: Filing cabinets contain dossiers on every hotel guest — including the player. Yours has been recently updated.
- Exits: south -> hub, east -> b2.

### Room b2 — The Cipher Room
- Size: 8x8 tiles.
- Type: trap.
- Spawn:
  - 1x Cultist at (4,4).
- Loot: stat_upgrade at (6,2), KEY at (6,2) — 50% chance spawn per seed.
- Hazards: CAMERA ROOM — surveillance camera at (4,1) sweeps in a 180-degree arc. If player enters camera view, alerts Cultist and all enemies in connected rooms within 3 seconds. Camera can be destroyed in 1 hit but alerts nearby enemies.
- Special mechanics: Cipher machines along the walls emit low hum. Interacting with them produces random text fragments. Camera feeds to a monitor in hub room.
- Recipe: 05-DecoyTrap.
- Lore element: The cipher machines decode to the same message in every language: "Everything you have is borrowed."
- Exits: west -> b1.

### Room c1 — Observatory Dome
- Size: 12x10 tiles.
- Type: chamber.
- Spawn:
  - 2x Spy at (2,3), (9,7).
  - 2x Shadow Stalker at (6,2), (3,8).
- Loot: Machete at (11,1).
- Hazards: LOCKED — requires KEY to enter. CAMERA ROOM — surveillance camera at (6,1) sweeps the dome floor. Destroying it alerts all enemies in the room immediately.
- Special mechanics: LOCKED room — accessible only with KEY from b2, c2, or d2. High-value reward room. Central telescope at (5,5) is a light source that reveals all enemies in a 6-tile radius. Dome ceiling is open — starlight provides faint ambient visibility.
- Recipe: 10-KillBox.
- Lore element: The telescope is pointed at a room on Floor 3. The crosshairs are on the spot where you picked up your first weapon.
- Exits: west -> hub, east -> c2.

### Room c2 — Star Chamber
- Size: 8x8 tiles.
- Type: chamber.
- Spawn:
  - 1x Shadow Stalker at (2,6).
  - 1x Cultist at (6,2).
- Loot: KEY at (4,4) — 50% chance spawn per seed. Ammo at (7,7).
- Hazards: CAMERA ROOM — surveillance camera at (4,1). Smaller sweep arc than b2 but faster rotation.
- Special mechanics: Starlight projections on the floor create moving light patches. Standing in light reveals cloaked Spies (none present, but teaches mechanic). Shadow Stalker uses the dark patches to ambush.
- Recipe: 12-BaitAndSwitch.
- Lore element: The stars on the floor form a face. It looks like yours, but younger and happier.
- Exits: west -> c1.

### Room d1 — Shadow Gallery
- Size: 10x8 tiles.
- Type: gallery.
- Spawn:
  - 2x Spy at (3,2), (7,6).
  - 1x Cultist at (5,4).
- Loot: Knife at (1,7).
- Hazards: DARK ROOM — 60% darkness overlay. Visibility reduced to 4-tile radius. Light source at (5,4) — flickers on a 4-second cycle (2s on, 2s off). During off-cycle, Spies re-cloak.
- Special mechanics: Stealth Zone active. Paintings on the walls are barely visible — examining them with the light on reveals they are portraits of guests whose eyes have been scratched out. Cultist patrols near the flickering light source.
- Recipe: 14-LurkingHorror.
- Lore element: One painting is still intact. It is a portrait of the Curator. He is smiling. The smile has too many teeth.
- Exits: north -> hub, east -> d2.

### Room d2 — The Void Room
- Size: 10x10 tiles.
- Type: trap.
- Spawn:
  - 2x Shadow Stalker at (2,3), (7,7).
  - 1x Spy at (5,5).
- Loot: Random weapon at (8,1). KEY at (1,8) — 50% chance spawn per seed.
- Hazards: DARK ROOM — 60% darkness overlay. No light sources. The only light comes from the player's reduced visibility radius and brief flashes when enemies attack.
- Special mechanics: Stealth Zone active. Deepest dark room on the floor. Shadow Stalkers are nearly impossible to track mid-phase here. Spy at centre is a trap — it attacks from stealth when player reaches the random weapon. The void effect makes walls appear to breathe.
- Recipe: 16-TrapCombo.
- Lore element: The room has no ceiling. Looking up reveals not stars but the floor of the room above — and footprints that match your own.
- Exits: west -> d1.

### Room boss — The Curator's Study
- Size: 16x14 tiles.
- Type: boss.
- Spawn:
  - 1x The Curator at (8,7).
- Loot: Cult artifact (random) — dropped on kill.
- Hazards: Display cases along north and south walls (destructible, drop weapons during Phase 2). Surveillance cameras at (3,1), (12,1) — decorative, already disabled by Curator.
- Special mechanics: Weapon Theft mechanic active. Curator can phase through player and steal currently equipped weapon. Stolen weapon appears in Curator's hands and is used against the player. Player fights bare-handed until weapon is reclaimed by dealing sufficient damage to Curator. Display cases in Phase 2 contain weapons player can grab as alternatives.
- Recipe: Standard.
- Lore element: The Curator's desk has a guestbook. Every entry is in your handwriting. The dates are all tomorrow.
- Exits: south -> hub (entry), stairs (exit on kill).

## Mini-boss Spec

### Intro
- Trigger: Player enters boss room from hub.
- Cinematic: 2-3s slow-zoom on The Curator standing behind his desk, adjusting white gloves. He looks up as if he already knew you were coming. The camera locks on his face — his eyes are solid silver.
- Boss intro text: "Ah, another piece for the collection. Do hold still — this won't hurt me at all."

### Arena
- Size: 16x14 tiles.
- Hazards: Display cases (destructible, contain weapons in Phase 2). Shadow zones in corners that reduce visibility.
- Breakable cover: Display cases at (2,3), (5,3), (10,3), (13,3), (2,10), (5,10), (10,10), (13,10).
- Entry: south wall, from hub.

### Phases
- Phase 1 "Acquisition" (100-50% HP): Curator phases in and out of visibility, attempting to pass through the player to steal the equipped weapon. If stolen: Curator wields it — shotgun blasts, SMG bursts, or melee swings depending on weapon type. Shadow bolt attack deals 20 damage. Summons 1x Spy every 25 seconds from the room edges. Player must damage Curator while dodging their own weapon's attacks.
- Phase 2 "Collection" (50-25% HP): Curator steals more aggressively — faster phase speed, shorter cooldown between attempts. Display Case mechanic activates: 4 stolen weapons appear in display cases along the walls (positions: (3,3), (12,3), (3,10), (12,10)). Player can interact with any display case to grab a weapon, even if their original was stolen. Curator attacks from unexpected angles by phasing through walls, repositioning behind the player. Shadow bolt upgraded to twin bolts, 20 damage each.
- Phase 3 "Exhibition" (25-0% HP): Curator attempts to steal BOTH player weapons simultaneously. If successful: player fights bare-handed (punch attacks only, 5 damage). Shadow Realm mechanic: dark zone expands from Curator's position, reducing visibility by 70% in a 6-tile radius. Shadow Clone spawns — identical visual to Curator but deals only 25% damage and is confusing (attacks from mirrored positions). Curator's gloves come off — his hands are made of polished silver, reflecting everything they touch.

### Reward
- Kill reward: Cult artifact (random selection from floor-themed pool).
- Exit: Stairs revealed behind Curator's desk, leading to Floor 8.

## Difficulty Curve
- Expected kills: 17 enemies across floor (Spies: 8, Shadow Stalkers: 6, Cultists: 3, plus boss).
- Expected time: 12-18 min.
- Hazard density: med.
- Enemy density: med.

## Replayability
- Branch-gated rooms: On 40% of seeds, room c1 (Observatory Dome) is LOCKED with no KEY available in the c-branch — player must explore b2 or d2 for the KEY. On 30% of seeds, room d2 (The Void Room) is sealed until b1 is cleared.
- Random loot locations: Room d2 random weapon varies per seed (from full weapon pool). Room hub Shotgun placement shifts between (12,2) and (1,10) on a per-seed basis.
- Key location: KEY spawns in exactly one of b2, c2, or d2 per run (33/33/34 split). On seeds where b2 spawns the KEY, the b-branch becomes the critical path and c1/d2 are optional. On seeds where c2 or d2 spawns the KEY, players must commit to a longer route through enemy-dense rooms to unlock c1.
