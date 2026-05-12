# Floor 5 — The Spa (Sloth)

## Atmosphere
- Colour palette: #D0E0E0 (floor — pale tile, clinical white-green), #8AABA0 (walls — seafoam ceramic, warm damp stone), #3CBEB0 (accent — turquoise pool water, steam pipe highlights), #B8D8D0 (seafoam — fog colour, mist overlay, ambient glow).
- Musical theme: Slow, liquid synths with a heartbeat-like bass pulse. Muffled chimes echo as if heard through water. The tempo drags deliberately, lulling the player into a false calm before combat spikes.
- Sensory hook: A wet slap of bare feet on tile, followed by the hiss of a steam valve opening and the room filling with white fog.

## Encounter Manifest

### Room a1 — Reception Lounge
- Size: 10x6 tiles.
- Type: corridor.
- Spawn:
  - 0 enemies (Staff listed in spec flees before combat begins).
  - 1x Staff at (8,3) (non-combatant, flees through east door on player entry, triggers hub alert).
- Loot: none.
- Hazards: none.
- Recipe: Standard.
- Lore element: The reception desk holds a guest book. The last hundred entries are all the same name, written in progressively shakier handwriting.
- Exits: east -> a2.

### Room a2 — Steam Corridor
- Size: 8x6 tiles.
- Type: corridor.
- Spawn:
  - 1x Attendant at (5,3) (emerges from fog cloud at center, patrols east-west).
- Loot: ammo at (2,4) (on a wet bench along the south wall).
- Hazards: fog zone covering tiles (3,1)-(6,4) (60% opacity, player speed -30%). Steam pipe burst at (1,1) hisses on entry.
- Recipe: 19-DarknessFalls.
- Lore element: "RELAXATION IS MANDATORY" is stencilled on the wall in peeling gold leaf.
- Exits: west -> a1, east -> hub.

### Room hub — The Pool
- Size: 16x14 tiles.
- Type: hub.
- Spawn:
  - 2x Attendant at (3,4), (12,4) (patrolling the pool edge, north side).
  - 1x Drowned One at (8,9) (submerged in the central pool, ambush triggers when player is within 3 tiles).
  - 2x Staff at (2,11), (13,11) (near supply closets, flee toward corners on alert).
- Loot: Shotgun at (14,2) (on a poolside towel rack, northwest corner).
- Hazards: water pool covering tiles (5,7)-(10,11) (player speed -60%, Drowned One regen +5HP/s in water). Fog zone at (1,0)-(4,5) from an open steam vent.
- Recipe: 07-Pincer.
- Lore element: The pool water is warm and smells faintly of antiseptic. Something brushes against your ankles if you wade in.
- Exits: west -> a2, north -> b1, east -> c1, south -> d1, boss door (sealed until side paths cleared) -> boss.

### Room b1 — Sauna Wing
- Size: 10x8 tiles.
- Type: chamber.
- Spawn:
  - 2x Attendant at (2,2), (8,6) (flanking positions, one near the sauna door, one by the cooling bench).
- Loot: Wire at (5,7) (wrapped around a towel hook on the south wall).
- Hazards: dense fog fills tiles (2,1)-(7,6) (80% opacity, player speed -30%). Hot coals at (1,5)-(2,5) — contact deals 8dmg/s.
- Recipe: 08-HuntersDen.
- Lore element: Carved into the sauna bench: "I HAVE BEEN HERE SO LONG I FORGOT WHY I CAME."
- Exits: south -> hub, north -> b2.

### Room b2 — Mud Baths
- Size: 6x6 tiles.
- Type: storage.
- Spawn:
  - 1x Staff at (4,4) (sitting motionless in a mud bath, does not engage until player is within 2 tiles).
- Loot: stat_upgrade at (1,1) (on a supply shelf), ammo at (3,5) (in a mud-encrusted crate), KEY(50%) at (5,2) (hidden beneath a removable floor tile near the east wall).
- Hazards: mud pools covering tiles (2,2)-(4,4) (player speed -40%, no damage). Staff emerges from mud if disturbed.
- Recipe: 05-DecoyTrap.
- Lore element: The mud is warm and pulls at your legs. It feels like hands.
- Exits: south -> b1.

### Room c1 — Treatment Rooms
- Size: 10x8 tiles.
- Type: chamber.
- Spawn:
  - 1x Attendant at (7,2) (at a treatment table, moves to flank).
  - 1x Drowned One at (4,5) (in an immersion tub, ambush triggers when player steps on tile (3,4) or (4,4)).
- Loot: cult_blade (rare) at (9,1) (mounted on the wall behind glass, LOCKED room).
- Hazards: immersion tubs at (3,5)-(4,6) and (6,5)-(7,6) — water zones (speed -60%, Drowned One regen). Sedative mist in tiles (1,1)-(3,3) (additional -20% speed stacking with fog). LOCKED — requires KEY to enter.
- Recipe: 18-PoisonGarden.
- Lore element: Treatment charts on the wall describe procedures for removing memories, replacing them with obedience.
- Exits: west -> hub, east -> c2.

### Room c2 — The Surgery
- Size: 8x8 tiles.
- Type: chamber.
- Spawn:
  - 1x Guard at (5,4) (armed, stands watch over surgical equipment).
- Loot: KEY(50%) at (3,3) (inside a surgical instrument cabinet), ammo at (7,7) (in a supply crate).
- Hazards: surgical table at (4,3)-(5,4) — interactable, reveals lore only. Blood slick on tiles (2,5)-(3,6) — player speed -40%, no damage, loud splash audio cue.
- Recipe: 10-KillBox.
- Lore element: The surgical lights are still on. The last patient's restraints are worn through from the inside.
- Exits: west -> c1.

### Room d1 — Relaxation Garden
- Size: 12x8 tiles.
- Type: gallery.
- Spawn:
  - 1x Attendant at (9,2) (pacing between garden statues).
  - 1x Drowned One at (3,5) (in a decorative pond, ambush triggers when player crosses tiles (2,4)-(4,6)).
  - 1x Staff at (10,6) (pruning dead plants, flees toward east wall).
- Loot: stat_upgrade at (1,1) (on a stone bench beneath a dead tree).
- Hazards: decorative pond at (2,4)-(4,6) (water zone, speed -60%). Fog drifts from tiles (7,1)-(11,3) (60% opacity, speed -30%). Withered vines on north wall — interactable, drop a health pickup (1x per run).
- Recipe: 14-LurkingHorror.
- Lore element: All the plants in the garden are dead, yet the fountains still run. The water never stops.
- Exits: north -> hub, south -> d2.

### Room d2 — Steam Engine Room
- Size: 10x8 tiles.
- Type: storage.
- Spawn:
  - 1x Guard at (7,2) (patrolling between boiler columns).
  - 1x Staff at (2,5) (tending a pressure valve, hostile on proximity).
- Loot: KEY(50%) at (8,6) (in a maintenance locker), random_weapon at (5,1) (on a workbench).
- Hazards: steam vents at (3,3), (6,4) (burst every 5s, 12dmg, 2-tile radius, 0.5s warning hiss). Fog fills tiles (4,2)-(7,5) (70% opacity). Pressurised pipes on south wall — shootable, burst for 15dmg in a 3-tile cone.
- Recipe: 09-GrenadeAlley.
- Lore element: A maintenance log reads: "Steam pressure rising. Valves won't close. The fog has a voice now."
- Exits: north -> d1.

### Room boss — Attendant Prime's Sanctuary
- Size: 14x12 tiles.
- Type: boss.
- Spawn:
  - 1x Attendant Prime at (7,3) (standing in the center of a circular bath, submerged to the waist).
- Loot: cult_artifact at (7,10) (revealed on a dais after Attendant Prime dissolves).
- Hazards: four steam valves at (2,2), (11,2), (2,9), (11,9) — destructible (HP 60 each). Destroying a valve reduces fog coverage. Water channels along north and south edges (speed -60%). Fog fills the arena (percentage varies by phase). Sedative zones around Attendant Prime (2-tile aura, -20% speed stacking).
- Recipe: Standard.
- Lore element: The bath water is opaque and green. When it drains, you will not like what is at the bottom.
- Exits: from hub (sealed until boss defeated), stairs to Floor 6 revealed at (7,11) after kill.

## Mini-boss Spec

### Intro
- Trigger: player enters boss room from hub.
- Cinematic: 2-3s slow-zoom over the water's surface toward the center of the circular bath. Attendant Prime rises slowly, water dripping from elongated limbs. The room's steam valves all open simultaneously and fog rushes in.
- Boss intro text: "You should have relaxed when you had the chance."

### Arena
- Size: 14x12 tiles.
- Hazards: water channels (north and south edges, speed -60%), fog (coverage varies by phase), sedative aura around boss (2-tile radius, -20% speed).
- Breakable cover: four steam valves (2,2), (11,2), (2,9), (11,9) — each reduces fog when destroyed. Marble benches at (4,5), (9,5), (4,6), (9,6) (HP 50 each).
- Entry: from hub.

### Phases
- Phase 1 "Welcome" (100-60% HP): Arena at 50% fog. Attendant Prime is invisible while inside fog tiles. Sedative Touch (melee, applies -20% speed stacking debuff, max -60%). Fog Breath — exhales a cone of fog (3-tile range, 90-degree spread) expanding fog zones. Heals 5HP/s while standing in fog. Teleports between fog patches every 6s.
- Phase 2 "Deep Tissue" (60-25% HP): Arena fog increases to 75%. Attendant Prime gains Grab+Drag — catches player, drags 4 tiles toward fog center (30dmg from Steam Blast on release, stuns 1.5s). Steam Blast: 30dmg in a 2-tile radius, 1s wind-up (loud hiss). Four steam valves become targetable — each destroyed reduces fog by ~11% (down to 30% if all four destroyed). Teleport frequency increases to every 4s.
- Phase 3 "Checkout" (25-0% HP): Fog surges to 90% coverage regardless of valves. Fog becomes TOXIC — 3dmg/s to player while standing in fog tiles. Attendant Prime becomes visible for 0.5s each time it attacks (window for player to track and deal damage). Strategy: lure boss out of fog by positioning at fog edges, punish attack windows.

### Reward
- Kill reward: cult artifact (random from Spa pool).
- Exit: stairs to Floor 6 revealed at (7,11) after Attendant Prime defeat.

## Difficulty Curve
- Expected kills: 16.
- Expected time: 14 min.
- Hazard density: high.
- Enemy density: low.

## Replayability
- Branch-gated rooms: On 50% of seeds, room c1 (Treatment Rooms) and c2 (The Surgery) are sealed — player must find KEY in b2 or d2. On the other 50%, room d1 (Relaxation Garden) and d2 (Steam Engine Room) are sealed behind a locked garden gate.
- Random loot locations: hub (Shotgun moves between three poolside positions), d2 (random_weapon cycles between workbench, locker, and pipe shelf), c1 (cult_blade moves between wall mount and hidden drawer).
- Key location: KEY spawns 50% in b2 (Mud Baths) beneath the floor tile, 50% in d2 (Steam Engine Room) in the maintenance locker. A second KEY spawns 50% in c2 (The Surgery) inside the cabinet, 50% in d2 (Steam Engine Room) in a secondary locker.
