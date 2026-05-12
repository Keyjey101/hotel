# Floor 9 — Satan's Sanctum (Final Floor)

## Atmosphere
- Colour palette: SHIFTING — Phase 1 #F0F0F0 sterile white (corridors, waiting room, hospital-grade clean), Phase 2 #F0E0E0 warm flesh (walls pulse subtly, organic textures emerge), Phase 3 #1A0A0A encroaching black (void bleeds in from edges, stars visible through cracks in walls), Phase 4 #FF0000 to #000000 void (Satan's domain — red pulse fading to absolute nothing, the hotel unravelling).
- Musical theme: Begins as silence — pure, clinical, uncomfortable. A single piano note echoes when the Sister speaks. As reality degrades, the hotel's leitmotif from Floors 1-8 returns in fragments, overlapping and discordant. Satan's phase features a full orchestra playing every floor theme simultaneously, resolving into silence on the Final Offer.
- Sensory hook: The absolute silence of the White Corridor on entry — no ambient sound, no music, no footsteps echoing. Just the player's breathing. Then, from the Memory Hall, the faintest sound of every sound from every floor playing at once, harmonizing.

## Encounter Manifest

### Room a1 — White Corridor
- Size: 8x4 tiles.
- Type: corridor.
- Spawn:
  - 2x Demon at (3,1), (6,2).
- Loot: none.
- Hazards: none.
- Special mechanics: Introduction room. Sterile white environment — clinical, hospital-like. Demons appear as dark smudges against the white, jarring visual contrast. Minimalist combat teaches that Demons are new enemy types: fast, erratic, aggressive. No cover, no hiding — pure corridor fight. Reality Shift: walls shimmer faintly when Demons die, as if the room is adjusting to their absence.
- Recipe: 01-Ambush.
- Lore element: The white walls are perfectly clean except for one handprint near (5,3). The handprint has six fingers.
- Exits: east -> a2.

### Room a2 — The Memory Hall
- Size: 14x4 tiles.
- Type: service.
- Spawn:
  - 0x enemies.
- Loot: none.
- Hazards: none.
- Special mechanics: SERVICE room — narrative-only, no combat. A long corridor where the left wall contains tile fragments from Floors 1, 3, 5, and 7, and the right wall contains fragments from Floors 2, 4, 6, and 8. Left wall: Floor 1 rust (#8B4513) tiles at (1-3,0-3), Floor 3 gold (#D4AF37) tiles at (4-6,0-3), Floor 5 turquoise (#40E0D0) tiles at (7-9,0-3), Floor 7 indigo (#1A1A6A) tiles at (10-12,0-3). Right wall: Floor 2 crimson (#DC143C) tiles at (1-3,0-3), Floor 4 gold (#FFD700) tiles at (4-6,0-3), Floor 6 blood red (#660000) tiles at (7-9,0-3), Floor 8 royal gold (#DAA520) tiles at (10-12,0-3). Text appears on the floor at (7,2) when player walks over it: "the building is remembering itself through you." Walking the full length triggers a brief reality shimmer — the walls flicker between their original floor colours and the sterile white.
- Recipe: Standard.
- Lore element: Each tile fragment hums at the same frequency as its source floor. If you press your ear to the wall, you can hear the sounds of enemies you killed. They are not screaming.
- Exits: west -> a1, east -> hub.

### Room hub — The Waiting Room
- Size: 14x12 tiles.
- Type: hub.
- Spawn:
  - 0x enemies.
- Loot: none.
- Hazards: none.
- Special mechanics: Narrative hub — Sister encounter Phase 1 occurs here. The room is arranged like a hotel lobby crossed with a hospital waiting room: chairs at (3,3), (5,3), (7,3), (9,3), (11,3), a reception desk at (7,6), and magazine racks at (2,8), (11,8). Sister stands behind the reception desk. When player enters: room is sterile white. As player approaches Sister, reality shifts warm — palette transitions from #F0F0F0 to #F0E0E0 over 3 seconds. Sister dialogue: "You came." Pause. "I volunteered for this. For immortality. They said it was a promotion." Hub connects to all branches. No combat in this room. Four exits, but c1 and boss1 are initially gated behind narrative progression (c1 unlocks after Mirror Room, boss1 unlocks after c1).
- Recipe: Standard.
- Lore element: The magazines on the rack are all the same issue. The headline reads: "Promotion or Prison? Workers Share Their Stories." Every byline is the Sister's name.
- Exits: west -> a2, north -> b1, east -> c1 (LOCKED until b1 complete), centre-north -> boss1 (LOCKED until c1 complete).

### Room b1 — The Mirror Room
- Size: 10x8 tiles.
- Type: service.
- Spawn:
  - 0x enemies.
- Loot: none.
- Hazards: none.
- Special mechanics: Narrative-only — Sister encounter Phase 2 occurs here. Room contains a single large mirror at (5,4). Player enters alone. Sister's voice plays from the mirror: "Look." Mirror shows the player, but the reflection acts independently — it draws a weapon, lowers it, draws again. This is the choice room. Player must choose: Fight / Listen / Embrace. No combat occurs unless the player chooses Fight. The room palette shifts based on choice: Fight -> warm red tones, Listen -> soft blue, Embrace -> deep gold. After choice is made, the mirror shatters and the room returns to white. Exits unlock.
- Recipe: Standard.
- Lore element: The mirror's frame is made of hotel room keys — hundreds of them, each stamped with a different room number. All the numbers are the same: 999.
- Exits: south -> hub.

### Room c1 — The Throne Approach
- Size: 10x8 tiles.
- Type: corridor.
- Spawn:
  - 2x Demon at (3,3), (7,5).
- Loot: none.
- Hazards: LOCKED — unlocks after b1 (Mirror Room) is complete.
- Special mechanics: Final combat room before boss encounters. Demons fight with full aggression — no formations, no coordination, just raw violence. The corridor leads toward the boss chamber. Reality Shift active: room palette flickers between sterile white and encroaching black (#1A0A0A). When a Demon dies, the section of wall nearest to it permanently shifts to the dark palette, as if its death stains reality. By the time both Demons are dead, half the room has shifted dark.
- Recipe: 15-RageGauntlet.
- Lore element: The throne at the far end of the corridor is empty. It faces away from the player, toward a door that wasn't there a moment ago. The door is made of contracts.
- Exits: west -> hub, east -> boss1.

### Room boss1 — The Sister's Chamber
- Size: 14x12 tiles.
- Type: boss.
- Spawn:
  - 1x The Sister at (7,3) — only if player chose Fight.
- Loot: none (narrative resolution instead of loot).
- Hazards: Room palette shifts based on player choice. No physical hazards.
- Special mechanics: This is NOT a standard boss fight. It is a choice encounter with four possible resolutions:

  **If player chose FIGHT:**
  - Sister transforms — Torso HP 350. She copies the player's current loadout exactly (same weapons, same ammo counts). Fight proceeds as a mirror match.
  - Hesitation mechanic: every time Sister loses 20% HP, she pauses for 2 seconds. Dialogue plays: at 80% "Why are you doing this?", at 60% "I was like you once.", at 40% "Do you remember checking in?", at 20% "It doesn't have to end this way."
  - At <10% HP, fight stops. Player can choose to kill or spare.

  **If player chose LISTEN:**
  - No combat. Sister speaks for 60 seconds (player can walk around the room during). She explains the hotel's true nature: it is alive, it feeds on stay-duration, and every guest becomes part of the building. She chose to become staff because staff keep their minds longer. The player has been staff since Floor 1. The enemies were guests who didn't volunteer.
  - After dialogue: Sister opens the door to boss2. She steps aside.

  **If player chose EMBRACE:**
  - Sister draws a knife and stabs the player. Player takes 80% of current HP as damage. If player survives: Sister is horrified at her own action. "You... you trusted me." She drops the knife. The room shifts to gold. She opens the door to boss2 herself and walks through it, saying "I'll tell him you're coming. I'll tell him you're not afraid."
  - If the stab would kill the player: Sister catches the player before falling. "Not like this." Heals player to 20% HP. Same door opening sequence.

  **Resolution outcomes:**
  - Kill Sister (from Fight path) -> Ending A trigger set.
  - Spare Sister at <10% HP (from Fight path) -> Ending B trigger set.
  - Listen (never attack, full dialogue) -> Ending C trigger set.
  - Embrace (take the stab, survive) -> Ending D trigger set.

- Recipe: Standard.
- Lore element: The chamber has no ceiling. Above is the hotel — all nine floors stacked vertically, visible in cross-section. You can see every room you've been in. They are all empty now.
- Exits: south -> hub (entry), north -> boss2.

### Room boss2 — Satan's Sanctum
- Size: 18x14 tiles.
- Type: boss.
- Spawn:
  - 1x Satan at (9,4).
- Loot: Void Contract artifact — obtained after the Final Offer choice at 10% HP, not a standard drop.
- Hazards: Arena hazards change per phase (detailed below). No environmental hazards in Phase 1.
- Special mechanics: Final boss encounter. Satan fights in three phases with Torso HP 400/500/600 per phase (total 1500 HP). Phase transitions are triggered by HP thresholds, not by player choice. The arena transforms with each phase. The Sister's resolution affects Satan's dialogue and one minor mechanical change but does not change the core fight.
- Recipe: Standard.
- Lore element: Satan's desk is at the north end. It is the hotel's front desk, original and undamaged. The sign-in book is open. The last line reads: "Room 999 — Guest — Permanent." The name is yours. The ink is still wet.
- Exits: south -> boss1 (entry). Exit on completion depends on ending path.

## Mini-boss Spec (Sister Encounter)

### Intro
- Trigger: Player enters hub room (Phase 1) or Mirror Room (Phase 2).
- Cinematic: No cinematic zoom — the Sister is already present, standing calmly. The camera remains at standard height. The absence of a boss intro cinematic is intentional — she is not a boss. She is a person.
- Boss intro text: "You came." (Phase 1, hub). "Look." (Phase 2, Mirror Room).

### Arena
- Size: 14x12 tiles (Sister's Chamber, if Fight path chosen).
- Hazards: None.
- Breakable cover: None.
- Entry: from hub (narrative gate).

### Phases (Fight Path Only)
- Phase 1 "Recognition" (100-60% HP): Sister mirrors player's movement patterns with a 0.5s delay. Uses copied loadout identically to player. Hesitates briefly at 80% HP mark. Dialogue: "Why are you doing this?"
- Phase 2 "Confrontation" (60-20% HP): Sister becomes more aggressive — delay drops to 0.2s. Uses environmental positioning to gain advantage. Hesitates at 40% HP. Dialogue: "Do you remember checking in?" Attack patterns begin to deviate from the player's — she develops her own style.
- Phase 3 "Resolution" (20-0% HP): Sister's movements become erratic, conflicted. Some attacks are deliberately aimed to miss. At <10% HP, combat freezes. Player is given the choice: Finish Her / Lower Weapon. Dialogue: "It doesn't have to end this way."

### Reward
- Kill reward: None (Ending A locked in).
- Spare reward: None (Ending B locked in).
- Listen reward: None (Ending C locked in).
- Embrace reward: None (Ending D locked in).
- Exit: North door to boss2 (Satan's Sanctum) unlocks after resolution regardless of choice.

## Boss Spec (Satan)

### Intro
- Trigger: Player enters boss2 from boss1.
- Cinematic: 3s slow-zoom on Satan seated behind the front desk. He is reading the sign-in book. He looks up, closes the book, and stands. His form shifts — sometimes a businessman, sometimes a judge, sometimes something with too many angles. He straightens his tie. The tie is made of contracts.
- Boss intro text: "Your stay is nearly over. Shall we discuss your bill?"

### Arena
- Size: 18x14 tiles.
- Hazards: Phase-dependent (see below).
- Breakable cover: Phase-dependent.
- Entry: south wall, from boss1.

### Phases
- Phase 1 "The Interview" (Torso HP 400, 100-0%):
  Satan is calm, collected, almost pleasant. Attacks are deliberate and telegraphed.
  - Handshake Grab: Satan extends hand toward player. If player is within 3 tiles and doesn't dodge within 0.8s, grabs and crushes for 30 damage.
  - Contract Throw: Tracking projectile that moves at moderate speed. Deals 20 damage + slow debuff (0.7x movement speed for 3 seconds). Can be destroyed with 3 hits from any weapon.
  - Dismiss: Knockback wave centered on Satan. Pushes player 200px (~6 tiles) and deals 15 damage. Used when player gets too close.
  - Summon: Calls 1x Demon from arena edges every 40 seconds. Maximum 2 Demons at once.
  - Dialogue between attacks: "Your reservation was... non-refundable." / "I do hope you've been enjoying the amenities." / "Every guest checks out eventually."
  - Arena: Standard 18x14. No environmental hazards. Desk at (9,2) is destructible (HP 100).

- Phase 2 "The Audit" (Torso HP 500, 100-0%):
  Satan loses composure. Cracks appear in his skin revealing void beneath. Arena begins to destabilize.
  - Reality Warp: Arena geometry shifts — pillars appear at (3,4), (15,4), (9,7), (3,10), (15,10) providing cover, then vanish 5 seconds later. Repeats every 15 seconds.
  - Fiscal Year: Time dilation — player moves at 0.5x speed for 3 seconds. Satan moves at normal speed. Used once every 30 seconds.
  - Hostile Takeover: Weapon theft mechanic (identical to Curator's). Satan phases through player and steals equipped weapon. Uses it against player for 10 seconds, then discards it at a random arena position. Player can pick it back up.
  - Liquidation: Three floor damage zones appear (3x3 tiles each), dealing 20 damage/second to player standing in them. Zones pulse visually before activating. Last 8 seconds.
  - Summon: Calls 2x Demons simultaneously every 35 seconds.
  - Dialogue: "Let me review your account." / "I'm afraid there are... discrepancies." / "Do you know how much you owe?"
  - Arena: Destabilizing. Edges flicker between the room and void. Floor tiles occasionally shift colour.

- Phase 3 "Bankruptcy" (Torso HP 600, 100-0%):
  Satan's form breaks down completely — a void entity wearing a tattered suit. The arena is now hostile.
  - Void Touch: Melee-range attack dealing 50 damage + no health regeneration for 5 seconds. Telegraphed with a 1-second windup where Satan's arm elongates.
  - Economic Collapse: All arena surfaces become hostile. Safe zone (4x4 tiles) appears and moves to a random position every 6 seconds. Standing outside the safe zone deals 15 damage/second. Entire arena is bathed in red-to-black void effect.
  - Market Crash: Projectiles fire from all four walls simultaneously in wave patterns. Player must read and dodge the pattern (4 patterns, cycling). Each projectile deals 15 damage.
  - Summon: Calls 1x Demon every 20 seconds. Demons in this phase explode on death for 25 damage in a 2-tile radius.
  - At 10% HP: Satan stops attacking. Arena calms. Final Offer begins.
  - Dialogue: "This is NOT how this works." / "You can't just LEAVE." / "I own this building. I own every floor. I own YOU."
  - Arena: Full hostile. Shrinking safe zone. Visual chaos — all nine floor palettes flickering simultaneously.

### Final Offer (10% HP Trigger)
At 10% HP, combat freezes. Satan drops to one knee. The arena goes silent. He looks up.

Satan: "One last deal. You walk out. The hotel stays. Everything you did here... never happened. They all come back. You forget."

Player choice:
- **Accept**: Ending A/B path. Player leaves. Screen fades to white. Credits roll over the empty hotel slowly filling with new guests. The Sister is at the front desk. She doesn't recognize you.
- **Reject**: Player refuses. Satan screams. The void consumes him. The hotel begins to collapse floor by floor. Player must escape upward through the collapsing building (2-minute timed sequence, no enemies, pure platforming/navigation). Credits roll over the rubble.
- **Sign the Contract**: Player takes the sign-in book and writes a new entry — their own name as permanent staff. Satan is horrified: "No — that's MY —" Void consumes him. Player sits behind the desk. The hotel rebuilds around them. They are the new manager. Credits.

The ending variation also depends on the Sister resolution:
- Ending A (Killed Sister + Accept): "The Guest Who Forgot"
- Ending B (Spared Sister + Accept): "The Guest Who Was Spared"
- Ending C (Listened to Sister + Reject): "The Guest Who Remembered"
- Ending D (Embraced Sister + Reject): "The Guest Who Stayed"
- Ending E (Any Sister path + Sign Contract): "The New Management"

### Reward
- Kill reward: Void Contract artifact (unique — only obtainable here).
- Exit: Determined by Final Offer choice. No stairs — this is the final floor.

## Difficulty Curve
- Expected kills: 6 enemies across floor (4x Demons in combat rooms, 0-2x Demons in Satan fight depending on duration). Note: This floor is intentionally narrative-heavy with fewer combat encounters than previous floors. The difficulty is concentrated in the two boss encounters (Sister if Fight path, Satan always).
- Expected time: 15-25 min (varies heavily by narrative path — Listen/Embrace paths are faster, Fight path with Sister adds 3-5 minutes).
- Hazard density: low (most rooms have no hazards; Satan's arena has phase-dependent hazards).
- Enemy density: low (only 2 combat rooms before bosses; Satan summons are the primary enemy source).

## Replayability
- Branch-gated rooms: Rooms b1 (Mirror Room) and c1 (Throne Approach) are narrative-gated, not key-gated. b1 is always accessible from hub. c1 unlocks after b1 is completed. boss1 unlocks after c1 is completed. This linear progression is intentional — the floor is about narrative buildup. However, the CONTENT of b1 changes based on a hidden seed variable: the mirror's reflection may show the player in different states (armed vs. unarmed, healthy vs. damaged) which subtly alters the Sister's dialogue in Phase 2, providing different context for the choice.

- Random loot locations: No random loot on this floor. The only "loot" is the Void Contract artifact from Satan, which is guaranteed. This is by design — the final floor strips away the accumulation loop.

- Key location: No KEY spawns on this floor. All locks are narrative-gated. The floor's "key" is the player's own choices.

- Four endings and seed variation:
  - **Ending A "The Guest Who Forgot"** (Kill Sister + Accept Final Offer): Player leaves the hotel. Everyone is revived. Player has no memory. Post-credits scene: a new guest checks in. They look exactly like the player.
  - **Ending B "The Guest Who Was Spared"** (Spare Sister + Accept Final Offer): Sister leaves with the player. Both forget. Post-credits scene: the hotel's front desk. A new manager arrives. It's the Consort, alive again.
  - **Ending C "The Guest Who Remembered"** (Listen to Sister + Reject Final Offer): Player escapes as hotel collapses. Carries all memories. Post-credits scene: the rubble. A hand reaches out from beneath. The Sister's hand. She's still wearing her name tag.
  - **Ending D "The Guest Who Stayed"** (Embrace Sister + Reject Final Offer): Player and Sister escape together. Both remember. Post-credits scene: a new building is under construction. The architect's blueprints show the exact layout of the hotel. The architect has six fingers.
  - **Ending E "The New Management"** (Any Sister path + Sign Contract): Player becomes the hotel. Post-credits scene: a new guest walks in. The player — now behind the desk — says: "Welcome to the Hotel. Checking in?"

  Per-run seed changes:
  - Satan's Phase 1 dialogue pool shifts — he references specific floors the player spent the most time on, specific enemies killed most, and whether the player favored stealth or aggression.
  - The Memory Hall tile fragments rearrange their floor-association order on each seed, changing which floor colours appear on which wall.
  - The Sister's hesitation dialogue in the Fight path changes based on total kills across the run. High-kill players hear guilt-laden lines. Low-kill players hear confusion-laden lines.
  - Satan's Phase 3 attack patterns (Market Crash) select from a pool of 8 patterns. Each seed chooses 4 patterns in a fixed order, so the dodge sequence differs between runs.
  - The Final Offer scene's background shifts based on which boss miniboss artifacts the player collected across Floors 1-8 — the collected artifacts appear floating behind Satan as trophies, and he references each one by name.
