# Floor 4 — The Vault (Greed)

## Atmosphere
- Colour palette: #0E0E1E (floor — deep midnight, cold institutional), #1A1A3A (walls — polished dark steel), #FFD700 (accent — gold trim on fixtures, lock mechanisms, accent lighting), #C0C8D0 (silver — door frames, vent grates, ceiling panels).
- Musical theme: Sparse, reverberant piano strikes over a low mechanical hum. Gold-coin shaker percussion builds tension. A distant clock ticking weaves through the background, accelerating near the boss room.
- Sensory hook: The heavy clunk of a vault door swinging open, followed by a rush of cold air and the glint of gold catching light from an unseen source.

## Encounter Manifest

### Room a1 — Security Checkpoint
- Size: 8x6 tiles.
- Type: corridor.
- Spawn:
  - 0 enemies.
- Loot: none.
- Hazards: lockdown doors (seal exits 4s, triggered when player loots or interacts with the security console at tile (4,2)).
- Recipe: Standard.
- Lore element: A smashed security monitor still flickers with the last guard's panicked face, frozen mid-scream.
- Exits: east -> a2.

### Room a2 — Steel Corridor
- Size: 10x4 tiles.
- Type: corridor.
- Spawn:
  - 2x Guard at (3,1), (7,2).
- Loot: ammo at (5,2).
- Hazards: laser grid (15dmg/s) across tiles (4,0)-(4,3), toggles every 3s.
- Recipe: 02-Chokepoint.
- Lore element: Bullet casings litter the floor — someone fought their way in before you and lost.
- Exits: west -> a1, east -> hub.

### Room hub — The Counting Room
- Size: 14x10 tiles.
- Type: hub.
- Spawn:
  - 1x Banker at (7,4) (center desk, patrols a tight 3-tile square around the counting table).
  - 2x Guard at (2,2), (11,2) (flanking the main entrance, elevated on short platforms).
  - 2x Staff at (5,7), (9,7) (near side offices, flee toward cover on alert).
- Loot: SMG at (7,1) (on the counting table, center-north).
- Hazards: spike walls along north and south edges (30dmg, 0.5s warning), lockdown doors at all four exits (seal 4s on Banker activation).
- Recipe: 13-Phalanx.
- Lore element: Mountains of banknotes are stacked floor to ceiling, every bill stamped with an eye-and-hand sigil.
- Exits: west -> a2, north -> b1, east -> c1, south -> d1, boss door (sealed until side paths cleared) -> boss.

### Room b1 — Safety Deposit Wing
- Size: 10x8 tiles.
- Type: storage.
- Spawn:
  - 2x Guard at (1,1), (8,6) (patrolling the aisles between deposit box columns).
  - 1x Staff at (5,4) (cowering behind a tipped cart).
- Loot: Shotgun at (9,7) (in the far corner, behind a collapsed shelf).
- Hazards: safe deposit boxes (interactable, 2s open, 25% trapped — 20dmg spring needle). Deposit boxes at (2,2), (2,5), (7,2), (7,5).
- Recipe: 11-Turtle.
- Lore element: One deposit box is labelled "GUEST 0001 — DO NOT OPEN." It has been pried open. Empty.
- Exits: south -> hub, north -> b2.

### Room b2 — The Archive
- Size: 6x6 tiles.
- Type: storage.
- Spawn:
  - 1x Staff at (3,3) (hiding behind a filing cabinet stack).
- Loot: ammo at (1,1), stat_upgrade at (4,1), KEY(50%) at (3,5) (in a wall safe behind a painting).
- Hazards: crusher ceiling (50dmg, 1s warning shadow) over tiles (2,2)-(3,3), triggered by opening the wall safe.
- Recipe: 05-DecoyTrap.
- Lore element: Ledger books record every soul that has checked into the Hotel — yours is the most recent entry, written in red ink.
- Exits: south -> b1.

### Room c1 — Laser Grid Hall
- Size: 12x8 tiles.
- Type: trap.
- Spawn:
  - 1x Banker at (10,2) (behind a reinforced glass booth, activates laser patterns).
  - 2x Vault Drone at (3,1), (8,6) (patrolling the grid corridors).
- Loot: cult_pistol (rare) at (11,1) (in a glass case at the far end, behind the Banker booth).
- Hazards: laser grids (15dmg/s) in three rows — (3,0)-(3,7), (6,0)-(6,7), (9,0)-(9,7). Each row cycles on/off in sequence, 2s per row. LOCKED — requires KEY to enter.
- Recipe: 16-TrapCombo.
- Lore element: Scorch marks on the walls outline the shapes of people who tried to run the grid.
- Exits: west -> hub, east -> c2.

### Room c2 — The Inner Vault
- Size: 8x8 tiles.
- Type: chamber.
- Spawn:
  - 1x Guard at (4,4) (standing at attention before the vault core).
- Loot: KEY(50%) at (2,2) (in a wall-mounted lockbox), ammo at (6,6), cult_artifact(10%) at (4,1) (on a pedestal inside the central vault cage).
- Hazards: spike walls on east and west edges (30dmg, 0.5s warning). Central vault cage locks player inside for 3s if they step on tile (4,3).
- Recipe: 10-KillBox.
- Lore element: The vault core hums with warmth, as though something inside is alive and breathing.
- Exits: west -> c1.

### Room d1 — Gold Storage
- Size: 12x8 tiles.
- Type: storage.
- Spawn:
  - 1x Banker at (6,3) (on a raised platform overseeing the storage floor).
  - 2x Guard at (1,2), (10,6) (stationed at chokepoints between gold bar stacks).
- Loot: Axe at (11,1) (embedded in a wooden crate).
- Hazards: crusher ceiling (50dmg, 1s warning shadow) over tiles (4,3)-(5,5), activated by Banker. Collapsing gold bar stacks on tiles (2,5)-(3,5) if shot or exploded.
- Recipe: 03-Crossfire.
- Lore element: Every gold bar is stamped "PROPERTY OF THE HOTEL — REDEMPTION NOT AVAILABLE."
- Exits: north -> hub, south -> d2.

### Room d2 — Coin Minting
- Size: 8x8 tiles.
- Type: chamber.
- Spawn:
  - 1x Staff at (2,6) (operating the minting press).
  - 1x Guard at (6,2) (watching the entrance).
- Loot: KEY(50%) at (4,4) (inside the minting press hopper), stat_upgrade at (7,7) (behind a loose panel).
- Hazards: minting press crush zone (50dmg instant) on tiles (3,3)-(5,5), cycles every 4s. Hot metal splash (10dmg) on tiles adjacent to press when it stamps.
- Recipe: 09-GrenadeAlley.
- Lore element: Fresh-minted coins feature a face that shifts when you look at it from different angles — it might be yours.
- Exits: north -> d1.

### Room boss — The Accountant's Office
- Size: 14x12 tiles.
- Type: boss.
- Spawn:
  - 1x Accountant at (7,2) (seated behind an oversized mahogany desk, stands on player entry).
- Loot: cult_artifact at (7,10) (in a wall safe revealed after boss defeat).
- Hazards: spike walls along north and south edges (30dmg, 0.5s warning), crusher ceilings over tiles (3,4)-(4,6) and (10,4)-(11,6) (50dmg, 1s warning shadow), laser grids at (6,0)-(6,11) and (8,0)-(8,11) (15dmg/s, toggle on Accountant command), lockdown doors at entry (seal 4s on Phase 2 start). Breakable cover: desk at (7,2)-(8,3) (HP 150), four marble pillars at (3,2), (11,2), (3,9), (11,9) (HP 80 each), gold bar barricades at (5,5) and (9,5) (HP 40).
- Recipe: Standard.
- Lore element: The Accountant's ledger is open. Every line is a name. Every name has a number. Your name is at the bottom, and the number is still counting.
- Exits: from hub (sealed until boss defeated), stairs to Floor 5 revealed at (7,11) after kill.

## Mini-boss Spec

### Intro
- Trigger: player enters boss room from hub.
- Cinematic: 2-3s slow-zoom from the doorway toward the oversized desk. The Accountant snaps a pocket watch shut, rises, and the room lights shift to gold. Overhead lights flicker once.
- Boss intro text: "Your account is overdrawn."

### Arena
- Size: 14x12 tiles.
- Hazards: spike walls (north/south edges), crusher ceilings (two zones), laser grids (two vertical columns), lockdown doors (entry sealed in Phase 2).
- Breakable cover: mahogany desk (center), four marble pillars (corners), two gold bar barricades (mid-field).
- Entry: from hub.

### Phases
- Phase 1 "Audit" (100-50% HP): Accountant evades player, dashing between cover positions. Activates trap timers — spike walls pulse every 6s, crushers every 8s, lasers toggle every 4s. Occasional pistol shot (10dmg, single round, telegraphed by a pocket watch flash). Summons 1x Vault Drone every 20s from the arena edges.
- Phase 2 "Foreclosure" (50-25% HP): All trap cooldowns halved. Accountant throws gold bars (25dmg, arc trajectory, 1.5s wind-up). Two breakable walls on east and west sides of the arena are revealed, opening flanking alcoves with additional spike traps. Summons 2x Vault Drone every 20s.
- Phase 3 "Bankruptcy" (25-0% HP): ALL traps activate simultaneously and remain on for the phase. Accountant launches gold bar barrage (5x gold bars in rapid succession, 15dmg each, spread pattern). As Accountant's HP drops, traps progressively deactivate — lasers at 15%, crushers at 10%, spike walls at 5% — giving the player an increasingly open arena to close the kill.

### Reward
- Kill reward: cult artifact (random from Vault pool).
- Exit: stairs to Floor 5 revealed at (7,11) after Accountant defeat.

## Difficulty Curve
- Expected kills: 18.
- Expected time: 12 min.
- Hazard density: high.
- Enemy density: med.

## Replayability
- Branch-gated rooms: On 50% of seeds, room c1 (Laser Grid Hall) and c2 (The Inner Vault) are sealed — player must find KEY in b2 or d2. On the other 50%, d1 (Gold Storage) and d2 (Coin Minting) are sealed.
- Random loot locations: hub (SMG moves between table and side desk), b1 (Shotgun moves between three deposit box locations), d1 (Axe moves between crate positions).
- Key location: KEY spawns 50% in b2 (The Archive) at the wall safe, 50% in d2 (Coin Minting) in the press hopper. A second KEY spawns 50% in c2 (The Inner Vault) and 50% in d2 (Coin Minting), meaning on some seeds the player only needs one KEY run.
