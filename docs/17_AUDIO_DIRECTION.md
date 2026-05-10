# AUDIO DIRECTION DOCUMENT — HOTEL
## Version 1.0

---

# 1. AUDIO PHILOSOPHY

## 1.1 Principles

- **Audio = gameplay information.** Каждый звук имеет purpose — не просто atmosphere
- **Per-floor identity.** Каждый этаж — уникальный sound world
- **Dynamic intensity.** Music отражает combat state
- **Silence is a tool.** Тишина — самый мощный audio moment
- **Industrial + organic.** Механические звуки + flesh sounds = Hotel identity

## 1.2 Audio Layers

| Layer | Purpose | Dynamic? |
|-------|---------|----------|
| Music | Atmosphere + energy | Yes (combat/exploration) |
| Ambient | World identity, constant | Partially (hazard-dependent) |
| Foley/Player | Player actions | Triggered |
| Enemy | Enemy state information | Triggered |
| Combat | Impact, gore, weapons | Triggered |
| UI | Menu, pickup, HUD | Triggered |

---

# 2. PER-FLOOR MUSIC

## 2.1 Floor 1 — Service Underground

**Style:** Industrial ambient
**Tempo:** 80 BPM
**Mood:** Oppressive, mechanical, dehumanizing

**Elements:**
- Deep bass drone (constant, C1-C2)
- Metallic percussion (pipe hits, valve turns)
- Rhythmic steam release (every 4 bars)
- Muffled industrial machinery in background
- No melody — pure texture

**Combat overlay:**
- Add distorted kick drum (4/4)
- Metallic scraping layer
- Bass drops on beat
- Tempo rises to 110 BPM

---

## 2.2 Floor 2 — Lust / Red Light District

**Style:** Synthwave seductive
**Tempo:** 100 BPM
**Mood:** Alluring, dangerous, hypnotic

**Elements:**
- Warm synth pad (minor key, lush)
- Slow pulsing bassline
- Breath-like vocal sample (processed, not words)
- Soft hi-hat pattern
- Occasional "moan" processed into musical note

**Combat overlay:**
- Harder synth lead (saw wave)
- Faster hi-hat
- Distorted bass
- Tempo 130 BPM

---

## 2.3 Floor 3 — Gluttony / Banquet Hall

**Style:** Distorted waltz
**Tempo:** 140 BPM (in 3/4 time signature)
**Mood:** Grotesque elegance, corrupted beauty

**Elements:**
- Waltz strings (but slightly detuned)
- Silverware percussion (clinks, scrapes)
- Bass waltz pattern
- Chewing sounds processed into rhythm
- Chandelier shimmer (high frequency shimmer)

**Combat overlay:**
- Strings become discordant
- Add distortion
- Waltz rhythm breaks down
- Tempo erratic (140 → 160 → 120)

---

## 2.4 Floor 4 — Greed / Vault

**Style:** Ticking percussion + cold synth
**Tempo:** 120 BPM
**Mood:** Precise, mechanical, relentless

**Elements:**
- Constant ticking (metronome-like)
- Coin counting percussion
- Cold synth arpeggios (minor, precise)
- Vault door bass (heavy sub)
- Calculator/button clicks as rhythm

**Combat overlay:**
- Ticking accelerates
- Alarm sounds layered
- Bass intensifies
- Tempo 150 BPM

---

## 2.5 Floor 5 — Sloth / Spa

**Style:** Droning bass + ambient wash
**Tempo:** 60 BPM (very slow)
**Mood:** Soporific, numbing, wrong

**Elements:**
- Deep drone bass (barely audible, felt)
- Water sounds processed into ambience
- Heartbeat (slow, 60 BPM)
- Muffled, distant everything
- Breathing sounds (not player's — someone else's)

**Combat overlay:**
- Drone deepens (sub-bass)
- Heartbeat accelerates
- Water sounds distort
- Tempo rises slightly to 80 BPM
- Music fights to stay quiet — unnerving during combat

---

## 2.6 Floor 6 — Wrath / Arena

**Style:** Metal riffs + rap beats
**Tempo:** 160 BPM
**Mood:** Aggressive, hype, violent

**Elements:**
- Distorted guitar riffs (heavy, rhythmic)
- Rap-style drum beat (808 bass, trap hi-hats)
- Crowd chant (distorted, layered)
- Screaming vocal samples (buried in mix)
- Bass drop on downbeat

**Combat overlay:**
- Full metal arrangement
- Guitar solos during mini-boss
- Rap vocal samples emerge
- Double-time sections
- Tempo 180 BPM
- **This is the LOUDEST floor**

---

## 2.7 Floor 7 — Envy / Observatory

**Style:** Ambient cosmic horror
**Tempo:** None (free-time, arrhythmic)
**Mood:** Vast, empty, watching

**Elements:**
- Cosmic drone (slowly evolving)
- Ethereal choral samples (reversed, processed)
- Sparse piano notes (single notes, long reverb)
- Star static (white noise, filtered)
- Whispers (barely audible, no words)

**Combat overlay:**
- Drone intensifies
- Whispers become louder
- Piano becomes cluster chords
- Sounds arrive LATE (500ms delay — unnerving)
- No rhythm — pure texture

---

## 2.8 Floor 8 — Pride / Ballroom

**Style:** Orchestral synth
**Tempo:** 130 BPM
**Mood:** Elegant, grand, oppressive beauty

**Elements:**
- Orchestral strings (synth, but realistic-ish)
- Electronic beat underneath (hidden, felt)
- Piano arpeggios (complex, classical)
- Choral pads (opera-style, wordless)
- Waltz influences but in 4/4

**Combat overlay:**
- Full orchestra + full synth simultaneously
- Strings become aggressive
- Beat becomes prominent
- Choral becomes chant
- Tempo 160 BPM
- Most "beautiful" combat music — unsettling contrast

---

## 2.9 Floor 9 — Satan's Sanctum

**Style:** ALL STYLES COLLIDING
**Tempo:** Shifting
**Mood:** Reality breaking down

**Phase 1 (Entry):** Pure silence. Then a single piano note.
**Phase 2 (Sister):** Faint heartbeat. Then... a music box melody. Simple. Childish. Anna's lullaby.
**Phase 3 (Satan fight):** All floor styles layered simultaneously — industrial + synthwave + waltz + ticking + drone + metal + cosmic + orchestral — building to cacophony
**Phase 4 (Final phase):** Everything cuts out. Silence. Then one bass drop. Then pure noise. Then silence.

---

# 3. SOUND EFFECTS

## 3.1 Player SFX

| Action | Sound Description | Priority |
|--------|-------------------|----------|
| Footstep (concrete) | Hard sole click, slight echo | High |
| Footstep (wet) | Squelch + splash | High |
| Melee swing | Whoosh (speed-dependent) | High |
| Melee hit (flesh) | Wet impact + crunch | Critical |
| Melee hit (wall) | Hard clang | Medium |
| Ranged fire | Weapon-specific (see below) | Critical |
| Throw wind-up | Whoosh (building) | High |
| Throw release | Whoosh (releasing) | High |
| Weapon pickup | Metal/wood clink | High |
| Weapon switch | Quick swap sound | Medium |
| Hurt (light) | Gasp + impact | High |
| Hurt (heavy) | Cry + impact + crunch | Critical |
| Death/capture | Scream cut short → silence | Critical |
| Dodge/dash | Whoosh + ghost trail | Medium |

## 3.2 Weapon SFX

| Weapon | Melee Sound | Ranged Sound | Throw Sound |
|--------|------------|-------------|-------------|
| Machete | Sharp slice + spray | — | Spinning whoosh + stick |
| Knife | Quick stab + squelch | — | Fast zip + impact |
| Axe | Heavy chop + crack | — | Heavy whoosh + embed |
| Bat | Solid crack + echo | — | Tumble rattle + bounce |
| Cult Blade | Slice + occult hum | — | Spinning whoosh + syphon chime |
| Sawed-off | — | BOOM (close, loud) | Tumble + random BANG |
| Pistol | — | Sharp crack | Tumble + random pop |
| SMG | — | Rapid taps | Tumble + random spray |
| Shotgun | — | Deep BOOM + pump | Heavy tumble + big BANG |
| Cult Pistol | — | Ethereal shot + hum | Fast zip + soul rip sound |
| Bottle | Glass smash | — | Arc whoosh + SHATTER |
| Chair | Wood crack | — | Heavy tumble + crash |
| Severed Limb | Wet slap | — | Tumble + splatter |
| Wire | Tight wire snap | — | Fast zip + tangle snap |
| Cult Relic | — | — | Ominous hum + REALITY TEAR |

## 3.3 Enemy SFX

| Type | Alert Sound | Attack Sound | Hurt Sound | Mutilated Sound | Regen Sound |
|------|------------|-------------|-----------|----------------|-------------|
| Staff | Panicked yell | Weak swing | Yelp | Sobbing/crawling | Wet knitting |
| Guard | Radio click + shout | Baton crack + pistol pop | Grunt | Commanding shout (even mutilated) | Wet knitting |
| Handler | Low growl | Hook swing + chain | Deep grunt | Disturbing gurgle | Wet knitting, slower |
| Butcher | Madness laugh | Heavy chop | Snarl | Furious roar | Wet knitting |
| Cultist | Chant start | Occult bolt (energy) | Hiss | Moaning chant | Occult hum |
| Seductress | Soft whisper | Kiss (suction sound) | Gasp | Breathing heavy | Soft sigh + knitting |
| Bodyguard | Deep "halt" | Shield bash + grab | Heavy grunt | Orders (shorter) | Wet knitting |
| Chef | "Order up!" yell | Cleaver chop + sizzle | Oath | Kicking sounds | Wet knitting |
| Taster | Burping sound | Splash (poison) | Wheeze | Gurgling | Wet knitting, faster |
| Banker | Calculator clicks | Trap activate click | Gasp | Typing sounds | Wet knitting |
| Vault Drone | Electronic whine | Electric zap | Spark crack | N/A (no limbs) | Mechanical whir |
| Attendant | Soft "shh" | Steam hiss | Soft moan | Gentle humming | Wet knitting |
| Drowned One | Water splash | Gurgling grab | Bubbling cry | Wet crawling | Water + knitting |
| Gladiator | Battle cry | Weapon clash | War shout | Continued roaring | Wet knitting |
| Berserker | Inhuman scream | Heavy impact | Laughing | LAUGHING LOUDER | Wet knitting, angry |
| Spy | Near-silent | Quick slash | Yelp | Whisper | Wet knitting |
| Shadow Stalker | Shadow whisper | Claw tear (reality) | Dissolving sound | Puddle sound | Void hum |
| Royal Guard | Coordinated shout | Formation march | Group grunt | Orders to others | Wet knitting |
| Champion | Noble declaration | Heavy sword impact | Regal grunt | Defiant roar | Wet knitting |
| Demon | Inhuman frequency | Void tear | Reality crack | N/A | Void pulse |
| Sister | "You came" (soft) | Mirror of player weapons | Sad cry | N/A | Emotional |

## 3.4 Gore SFX

| Effect | Sound | Notes |
|--------|-------|-------|
| Limb sever | CRACK + wet spray + thud | Most satisfying sound in game |
| Blood splash | Wet splatter | Directional |
| Blood pool form | Dripping, spreading | Quiet but present |
| Severed limb bounce | Wet flop + roll | Physics-based |
| Regeneration start | Wet stretching begins | Unsettling |
| Regeneration mid | Flesh knitting, squelching | Organic, disturbing |
| Regeneration complete | Wet pop + sigh | Alert: enemy is back |
| Full dismemberment | Series of cracks + splatter | Big moment |
| Head sever | Distinct CRACK + silence | Dramatic stun |

## 3.5 Environmental SFX

| Element | Sound | Floor |
|---------|-------|-------|
| Pipe steam | Hissing, intermittent | 1 |
| Neon buzz | Electrical hum, flicker | 2 |
| Chandelier crystal | Subtle tinkling | 3, 8 |
| Coin counting | Mechanical clicking | 4 |
| Water dripping | Rhythmic drops | 5 |
| Crowd chant | Distorted cheering | 6 |
| Star hum | Low cosmic vibration | 7 |
| Clock ticking | Metronomic precision | 4, 8 |
| Fire crackle | Warm destruction | 6 |
| Mirror breaking | Sharp crash + echo | 2, 7 |
| Metal gate closing | Heavy clang + lock | All (doors) |
| Elevator ding | Off-key chime | All (transitions) |

---

# 4. DYNAMIC MUSIC SYSTEM

## 4.1 State Machine

```
EXPLORATION (base music, calm)
    │
    ├── Enemy alerts player → TENSION (add threat layer)
    │       │
    │       ├── Combat engaged → COMBAT (full combat music)
    │       │       │
    │       │       ├── Multiple enemies → INTENSE (louder, faster)
    │       │       │       │
    │       │       │       └── Boss → BOSS (unique boss music)
    │       │       │
    │       │       └── Last enemy dying → VICTORY STING (2s)
    │       │
    │       └── Lost enemy → TENSION FADE → EXPLORATION (5s)
    │
    └── No alert → EXPLORATION (sustained)
```

## 4.2 Transition Rules

| Transition | Time | Method |
|-----------|------|--------|
| Exploration → Tension | 1s | Crossfade, add layer |
| Tension → Combat | 0.5s | Hard switch, beat-sync |
| Combat → Intense | 0.5s | Add layer, tempo increase |
| Intense → Boss | 1s | Transition sting + new track |
| Boss → Victory | 2s | Victory sting, then fade |
| Combat → Exploration | 3s | Slow crossfade, remove layers |
| Any → Silence (Floor 9) | Instant | Hard cut |

## 4.3 Implementation in Godot 4

Using AudioStreamPlayer + AudioStreamRandomizer + Tween for crossfades.

Each floor has:
- `exploration_track` (loop)
- `tension_track` (loop, designed to layer on exploration)
- `combat_track` (loop, designed to replace or layer)
- `boss_track` (unique per boss)

---

# 5. AUDIO CUES FOR GAMEPLAY

## 5.1 Critical Audio Information

Players MUST be able to hear these (accessibility consideration — visual backup needed):

| Information | Audio Cue | Visual Backup |
|-------------|-----------|---------------|
| Enemy alerting others | Shout/radio sound | Alert icon above enemy |
| Enemy behind player | Footstep directional audio | Damage direction indicator |
| Enemy regenerating near you | Wet knitting sound (3D positioned) | Red glow on regenerating enemy |
| Low HP warning | Heartbeat + vignette | Red vignette overlay |
| Grab incoming | Chain/hand sound | Visual grab telegraph |
| Weapon pickup available | Subtle chime | Interact prompt |
| Mini-boss phase change | Musical sting + scream | Visual phase transition |

## 5.2 3D Audio (Positional)

Godot 4 AudioStreamPlayer2D for positional audio:
- Enemy footsteps (direction + distance)
- Enemy attacks (direction)
- Regen sounds (direction + proximity = urgency)
- Blood splatter (direction)
- Weapon impacts (position)

---

# 6. AUDIO PRODUCTION SUMMARY

## 6.1 Music Tracks Needed

| Track | Duration | Floor |
|-------|----------|-------|
| Exploration ×9 | 3-4 min each (loop) | All floors |
| Combat ×9 | 2-3 min each (loop) | All floors |
| Boss ×10 | 2-4 min each | Boss encounters |
| Victory sting | 2s | Universal |
| Death sting | 3s | Universal |
| Basement music | 3 min (loop) | Basement |
| Menu music | 2 min (loop) | Title |
| Ending music ×4 | 1-2 min each | Endings |
| **Total** | **~120 minutes** | |

## 6.2 SFX Needed

| Category | Count | Priority |
|----------|-------|----------|
| Player actions | ~25 | MVP |
| Weapons (15 × 3 states) | ~45 | MVP (5 weapons first) |
| Enemies (21 × 5 states) | ~105 | Phased |
| Gore | ~15 | MVP (core 5) |
| Environment | ~30 | Phased |
| UI | ~15 | MVP |
| Music transitions | ~10 | MVP |
| **Total** | **~250** | |

## 6.3 Production Priority

1. Core combat SFX (hits, severs, blood) — MUST have for prototype
2. Player SFX (footsteps, attacks)
3. 3-5 basic enemy SFX (alert, attack, hurt, regen)
4. Floor 1 music (exploration + combat)
5. Boss music (Floor 1)
6. UI sounds
7. Additional floors music + SFX
8. Ambient layers
9. Dynamic music transitions
10. Full SFX for all enemies
