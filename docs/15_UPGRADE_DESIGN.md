# UPGRADE & ARTIFACT DESIGN DOCUMENT — HOTEL
## Version 1.0

---

# 1. UPGRADE SYSTEM OVERVIEW

## 1.1 Three Layers

| Layer | Type | Source | Stacking |
|-------|------|--------|----------|
| **Stats** | Numerical bonuses | Floor pickups | Yes (additive) |
| **Cult Artifacts** | Trade-off modifiers | Rare pickups, boss rewards | No (choose 1 of each) |
| **Weapons** | Found weapons | Floor spawns, enemy drops | 2-slot inventory |

## 1.2 Design Principles

- Upgrades found DURING a run (per-run, не permanent)
- Stats are safe upgrades (pure benefit)
- Artifacts are RISKY upgrades (trade-off — deal with the devil)
- Weapons are situational (right tool for right moment)
- No upgrade makes you overpowered — difficulty scales

---

# 2. STAT UPGRADES

## 2.1 Complete List

| # | Name | Effect | Visual | Spawn Weight |
|---|------|--------|--------|-------------|
| S1 | Vitality Shard | +25 Max HP | Red crystal | 8 |
| S2 | Swift Step | +12% Movement Speed | Blue feather | 6 |
| S3 | Iron Skin | -15% Damage Taken | Grey shield | 5 |
| S4 | Razor Edge | +20% Melee Damage | Orange blade | 6 |
| S5 | Sure Shot | +20% Ranged Damage | Yellow crosshair | 5 |
| S6 | Heavy Arm | +25% Throw Damage | Purple fist | 4 |
| S7 | Quick Hands | +20% Pickup/Interact Speed | Green hand | 5 |
| S8 | Steady Grip | -30% Grab Vulnerability | Chain breaking | 4 |
| S9 | Second Wind | Regen 1 HP/s when HP <30% | White pulse | 3 |
| S10 | Ammo Pouch | +50% Ammo for all guns | Brown pouch | 5 |
| S11 | Bloodlust | +10% Damage for 3s after killing enemy | Red eye | 3 |

## 2.2 Stacking Rules

- Stats stack additively (2× Vitality Shard = +50 Max HP)
- Max 3 of same stat per run
- Diminishing returns after 2: 3rd stack = 50% value
- Player can hold unlimited stat upgrades (but floor spawns are limited)

## 2.3 Placement Rules

- **Floor 1-2:** 2-3 stat pickups per floor, common only (S1-S5, S10)
- **Floor 3-5:** 2-3 per floor, common + uncommon (S1-S8, S10-S11)
- **Floor 6-8:** 1-2 per floor, all types
- **Floor 9:** 1 guaranteed pickup (rare type)
- **Random position** within designated loot zones
- **Guaranteed minimum:** at least 1 stat pickup per branch

---

# 3. CULT ARTIFACTS

## 3.1 Design Philosophy

Каждый артефакт — это "сделка с дьяволом":
- Significant bonus AND significant penalty
- Cannot be removed once taken (commitment)
- Visual/audio tells when active
- Each one changes HOW you play, не просто "more numbers"

## 3.2 Complete List

### A1 — DEMON EYE (Демонов глаз)

*«Видишь дальше. Но близкое расплывается.»*

| | Effect |
|---|--------|
| **Bonus** | +30% ranged damage, +50% detection range (see enemy aggro) |
| **Cost** | -20% melee damage, screen edge vignette (reduced peripheral vision) |
| **Visual** | One eye glows red on player sprite |
| **Audio** | Whispering when enemies are near (direction indicator) |

---

### A2 — BLOOD PACT (Кровавый пакт)

*«Больше жизни. Но они голоднее.»*

| | Effect |
|---|--------|
| **Bonus** | +50% Max HP, +1 HP/s passive regen |
| **Cost** | Enemy regeneration +40% faster |
| **Visual** | Red aura around player, blood drips from enemies faster |
| **Audio** | Heartbeat audible (player's), enemies' regen sound louder |

---

### A3 — IRON WILL (Железная воля)

*«Нельзя схватить. Но нельзя и убежать.»*

| | Effect |
|---|--------|
| **Bonus** | Immune to grab/capture. Break free instantly from any hold |
| **Cost** | -25% movement speed. Cannot dodge roll (if upgrade available) |
| **Visual** | Metal shackles on player wrists (glow when grab attempted) |
| **Audio** | Metal clank when enemy grab fails |

---

### A4 — HUNGER BLADE (Голодный клинок)

*«Кормишься их болью. Но места для оружия меньше.»*

| | Effect |
|---|--------|
| **Bonus** | Melee attacks heal: 15% of damage dealt → HP |
| **Cost** | -1 weapon slot (can only carry 1 weapon) |
| **Visual** | Mouth appears on player's melee weapon |
| **Audio** | Chomping sound on melee hit, healing chime |

---

### A5 — SHADOW STEP (Теневой шаг)

*«Шаг через тень. Но тень становится короче.»*

| | Effect |
|---|--------|
| **Bonus** | +1 dash charge (quick dodge, 0.2s invulnerability, 3s cooldown) |
| **Cost** | -40% throw distance, -30% throw speed |
| **Visual** | Shadow trail when dashing |
| **Audio** | Whoosh on dash, shadowy whisper |

---

### A6 — GOLDEN HAND (Золотая рука)

*«Всё — в двойном размере. Включая жадность.»*

| | Effect |
|---|--------|
| **Bonus** | Double ALL pickups: stat upgrades, ammo, weapon drops |
| **Cost** | Halved ammo for all guns. Weapons degrade 2× faster (improvised) |
| **Visual** | Gold shimmer on player hands |
| **Audio** | Coin clink on pickup |

---

### A7 — RING OF WRATH (Кольцо гнева)

*«Первый удар — гром. Остальные — шёпот.»*

| | Effect |
|---|--------|
| **Bonus** | +60% damage to enemies at full health (first strike bonus) |
| **Cost** | -40% damage to enemies already damaged |
| **Visual** | Fire glow on player's weapon when enemy at full HP |
| **Audio** | Roar on first strike, whimper on subsequent |

---

### A8 — PACT OF FLESH (Пакт плоти)

*«Их тела — твоё оружие. Но тело помнит.»*

| | Effect |
|---|--------|
| **Bonus** | Severed limbs become WEAPONS automatically (pick up on sever). Severed limbs deal ×2.0 damage and have ×1.5 limb mult |
| **Cost** | Player HP drains at 2 HP/s (constant). Cannot be healed by Second Wind |
| **Visual** | Player skin becomes pale. Severed limbs glow when nearby |
| **Audio** | Flesh tearing sound when auto-equipping limb |

---

### A9 — THIRD EYE (Третий глаз)

*«Видишь правду. Но правда ломает разум.»*

| | Effect |
|---|--------|
| **Bonus** | See enemy aggro ranges (visual circles), see enemy health bars, see hidden enemies (Spy shimmer enhanced), see trap trigger zones |
| **Cost** | Screen occasionally glitches (0.5s static, random, ~every 15s). Cannot be disabled during combat |
| **Visual** | Third eye on forehead (glowing). Info overlays on enemies |
| **Audio** | Static burst during glitch |

---

### A10 — DEMON HEART (Сердце демона)

*«Второй шанс. Но они тоже сильнее.»*

| | Effect |
|---|--------|
| **Bonus** | On death: revive with 50% HP at current position (once per run). Clear all nearby enemies (stun 2s) |
| **Cost** | ALL enemies have +25% HP per limb AND +15% damage |
| **Visual** | Glowing red heart visible on player chest. Shatters on revival |
| **Audio** | Heartbeat (loud on low HP). Shatter sound on revival |

---

### A11 — CROWN OF THORNS (Венец терновый)

*«Больше оружия. Но каждая рана — двойная.»*

| | Effect |
|---|--------|
| **Bonus** | +1 weapon slot (3 slots total). +15% attack speed on all weapons |
| **Cost** | +30% damage taken from all sources. Blood pools damage player (3 dmg/s in blood) |
| **Visual** | Thorny crown on player head, thorns glow when hit |
| **Audio** | Thorns scrape sound when taking damage |

---

### A12 — VOID CONTRACT (Вердикт пустоты)

*«Финал. Без вариантов.»*

| | Effect |
|---|--------|
| **Bonus** | +50% damage to mini-bosses and Satan. +30% limb sever chance on all attacks |
| **Cost** | Basement escape becomes IMPOSSIBLE (capture = instant run over). No second chances |
| **Visual** | Black contract paper floats near player, sigils on arms |
| **Audio** | Deep drone when in boss arena. Silence in basement |

---

## 3.3 Artifact Pickup Rules

- Player approaches artifact → pickup prompt
- **Artifact description shows BOTH bonus AND cost** before pickup
- Player must CONFIRM (press interact again within 2s)
- Once confirmed: CANNOT be removed for rest of run
- Max 1 of each artifact per run (can stack different artifacts)
- No theoretical max — but each one adds a cost

## 3.4 Artifact Spawn Rules

| Source | Artifacts Available |
|--------|-------------------|
| Floor loot (rare) | Random from A1-A11 (weight 1) |
| Mini-boss reward | Random from A1-A11 (weight 3, higher tier) |
| Floor 9 guaranteed | A12 available (Void Contract) |
| Basement escape reward | 1 random artifact (bonus for escaping) |

---

# 4. UPGRADE INTERACTION TABLE

Как артефакты взаимодействуют:

| Combo | Interaction |
|-------|-------------|
| A2 (Blood Pact) + A10 (Demon Heart) | Revive at 75% HP instead of 50%, но enemies +65% limb HP |
| A3 (Iron Will) + A11 (Crown of Thorns) | Immune to grab + 3 slots, но +30% damage taken is devastating |
| A4 (Hunger Blade) + A1 (Demon Eye) | Ranged weakened, but melee heals — forced melee build |
| A5 (Shadow Step) + A6 (Golden Hand) | Dash for safety + double pickups, но throws useless + ammo halved |
| A7 (Ring of Wrath) + A8 (Pact of Flesh) | First strike massive, limb weapons powerful, но constant HP drain |
| A9 (Third Eye) + A2 (Blood Pact) | Full information + HP buffer, но enemies regen insanely fast |
| A12 (Void Contract) + anything | Boss killer, но ONE mistake = run over |

---

# 5. PROGRESSION CURVE

## 5.1 Expected Upgrade Acquisition Per Run

| Floor | Stats Found | Artifacts Found | Weapons Found |
|-------|------------|----------------|---------------|
| 1 | 2-3 | 0-1 (boss) | 3-4 |
| 2 | 2-3 | 0-1 | 2-3 |
| 3 | 2-3 | 0-1 | 2-3 |
| 4 | 2 | 0-1 | 2-3 |
| 5 | 2 | 0-1 | 2 |
| 6 | 1-2 | 0-1 | 2 |
| 7 | 1-2 | 0-1 | 1-2 |
| 8 | 1 | 0-1 | 1-2 |
| 9 | 1 | 1 (guaranteed A12) | 1 |
| **Total** | **14-20** | **1-5** | **16-22** |

## 5.2 Power Curve Target

Player power at end of successful run (Floor 9, pre-Satan):

| Stat | Base | With Upgrades | Multiplier |
|------|------|---------------|-----------|
| HP | 100 | ~200-300 | ×2-3 |
| Speed | 200 | ~240-260 | ×1.2-1.3 |
| Melee DMG | Base | ~+40-80% | ×1.4-1.8 |
| Ranged DMG | Base | ~+40-80% | ×1.4-1.8 |
| Throw DMG | Base | ~+25-50% | ×1.25-1.5 |
| Survivability | Base | Artifacts-dependent | Variable |

**Target:** Player feels significantly more powerful than Floor 1, но NOT invincible. Floor 9 should still be dangerous.

---

# 6. PICKUP VISUAL DESIGN

## 6.1 Stat Upgrades

| Type | Visual (ground) | Visual (HUD icon) |
|------|----------------|-------------------|
| Vitality Shard | Small red crystal, glow | Red crystal |
| Swift Step | Blue feather, float | Blue feather |
| Iron Skin | Grey shield icon | Shield |
| Razor Edge | Orange blade spark | Blade icon |
| Sure Shot | Yellow crosshair | Crosshair |
| Heavy Arm | Purple fist glow | Fist |
| Quick Hands | Green hand shimmer | Hand |
| Steady Grip | Broken chain | Chain |
| Second Wind | White pulse orb | Pulse |
| Ammo Pouch | Brown pouch | Pouch |
| Bloodlust | Red eye glow | Eye |

**Pickup animation:** Float slightly, rotate, faint glow matching colour

## 6.2 Cult Artifacts

| Artifact | Visual (ground) | Visual (HUD) |
|----------|----------------|--------------|
| Demon Eye | Floating red eye | Eye icon (active glow) |
| Blood Pact | Signed paper in blood | Contract icon |
| Iron Will | Metal shackles | Shackle icon |
| Hunger Blade | Mouth on blade | Mouth icon |
| Shadow Step | Dark wisp | Shadow icon |
| Golden Hand | Gold handprint | Gold hand |
| Ring of Wrath | Fire ring | Fire ring |
| Pact of Flesh | Meat chunk with rune | Flesh icon |
| Third Eye | Glowing eye in triangle | Triangle eye |
| Demon Heart | Beating red heart | Heart (breaks on use) |
| Crown of Thorns | Thorny circlet | Crown |
| Void Contract | Black paper, floating | Contract (final) |

**Artifact pickup:** Dramatic pause (0.3s), screen flash, item floats to player, description popup with bonus/cost shown.

---

# 7. UI DISPLAY

## 7.1 Active Upgrades on HUD

- **Stat icons**: small row, bottom-right, max 8 visible (scroll if more)
- **Artifact icons**: larger, bottom-right above stats, with glow indicating active
- **Artifact cost**: NOT shown on HUD (player chose it, must remember)
- **Weapon slots**: top-left, current weapon highlighted

## 7.2 Upgrade Pickup Screen

```
┌─────────────────────────────────┐
│  [ARTIFACT NAME]                │
│                                 │
│  ★ BONUS: Description here      │
│  ✗ COST: Description here       │
│                                 │
│  [E] Accept    [ESC] Reject     │
│                                 │
│  ⚠ Cannot be removed this run   │
└─────────────────────────────────┘
```

Game pauses during artifact pickup. Player must actively choose.

---
---

# APPENDIX A: ARTIFACT SPEC v2 (DATA-DRIVEN)

> Каждый артефакт ниже — полная карточка, готовая к импорту в .tres resource.
> CODER-3: читай эти карточки как истину, не придумывай недостающие поля.

---

## A1 — DEMON EYE

```
id: a1_demon_eye
display_name_en: Demon Eye
display_name_ru: Демонов глаз
description: +30% ranged damage and +50% enemy detection range, but -20% melee damage and reduced peripheral vision.
flavor_text:
  "Видишь дальше. Но близкое расплывается."
  "Глаз открывается. Мир сжимается в точку прицела."
rarity: common
stat_mods:
  ranged_damage_mult: +0.30
  detection_range_mult: +0.50
  melee_damage_mult: -0.20
trigger: passive
trade_off: Screen edge vignette reduces peripheral vision by ~20%.
unlock_condition: none (available from floor 1)
visual_id: demon_eye_red_glow
balance_notes:
  Forces ranged build. Pairs badly with Hunger Blade (A4) — both penalise opposite damage type.
  Stacks additively with S5 Sure Shot. Detection range overlaps with Third Eye (A9) info.
```

---

## A2 — BLOOD PACT

```
id: a2_blood_pact
display_name_en: Blood Pact
display_name_ru: Кровавый пакт
description: +50% Max HP and +1 HP/s passive regen, but enemy regeneration is 40% faster.
flavor_text:
  "Больше жизни. Но они голоднее."
  "Кровь бежит быстрее — и их, и твоя."
rarity: common
stat_mods:
  max_hp_mult: +0.50
  hp_regen: +1.0
  enemy_regen_speed_mult: +0.40
trigger: passive
trade_off: Enemy regen +40% makes dismemberment less effective. Baseline 30s/limb → 21s/limb.
unlock_condition: none (available from floor 1)
visual_id: blood_pact_red_aura
balance_notes:
  HP buffer + Demon Heart (A10) revive = very tanky but enemies have +65% limb HP combined.
  Conflicts with time-pressure playstyle since enemies recover faster.
```

---

## A3 — IRON WILL

```
id: a3_iron_will
display_name_en: Iron Will
display_name_ru: Железная воля
description: Immune to grab and capture. Break free instantly from any hold. But -25% movement speed and no dodge roll.
flavor_text:
  "Нельзя схватить. Но нельзя и убежать."
  "Цепи спали. Ноги — тоже."
rarity: common
stat_mods:
  grab_immune: true
  move_speed_mult: -0.25
  can_dodge_roll: false
trigger: passive
trade_off: No dodge roll even if dash upgrade acquired. Speed penalty makes kiting harder.
unlock_condition: none (available from floor 1)
visual_id: iron_will_shackles
balance_notes:
  Hard counter to Handler-heavy floors (1, 4, 5). Pairs well with Crown of Thorns (A11)
  for 3-slot capacity — but +30% damage taken from A11 is brutal with reduced speed.
```

---

## A4 — HUNGER BLADE

```
id: a4_hunger_blade
display_name_en: Hunger Blade
display_name_ru: Голодный клинок
description: Melee attacks heal 15% of damage dealt. But -1 weapon slot (only 1 weapon).
flavor_text:
  "Кормишься их болью. Но места для оружия меньше."
  "Клинок голоден. Ты — его столовая."
rarity: rare
stat_mods:
  melee_lifesteal: 0.15
  max_weapon_slots: -1
trigger: on_hit_dealt (melee only)
trade_off: Single weapon slot means no ranged backup unless you carry a gun and lose melee sustain.
unlock_condition: reach floor 3
visual_id: hunger_blade_mouth_weapon
balance_notes:
  Forces pure melee build. With Razor Edge (S4) and Vitality Shards (S1) = very sustainable.
  Anti-synergy with Demon Eye (A1) which nerfs melee. Synergy with Pact of Flesh (A8)
  for auto-equip limbs + lifesteal on them.
```

---

## A5 — SHADOW STEP

```
id: a5_shadow_step
display_name_en: Shadow Step
display_name_ru: Теневой шаг
description: +1 dash charge (0.2s invulnerability, 3s cooldown). But -40% throw distance and -30% throw speed.
flavor_text:
  "Шаг через тень. Но тень становится короче."
  "Тень — это мост. Но мост короток."
rarity: common
stat_mods:
  dash_charges: +1
  dash_invuln_duration: 0.2
  dash_cooldown: 3.0
  throw_distance_mult: -0.40
  throw_speed_mult: -0.30
trigger: on_dash_activate (player input)
trade_off: Throws become close-range only. No long-distance weapon throws.
unlock_condition: none (available from floor 1)
visual_id: shadow_step_trail
balance_notes:
  Defensive artifact. Pairs well with Golden Hand (A6) for safe double-pickup plays.
  Anti-synergy with Heavy Arm (S6) stat which boosts throws.
```

---

## A6 — GOLDEN HAND

```
id: a6_golden_hand
display_name_en: Golden Hand
display_name_ru: Золотая рука
description: Double ALL pickups (stats, ammo, weapon drops). But halved ammo and improvised weapons degrade 2x faster.
flavor_text:
  "Всё — в двойном размере. Включая жадность."
  "Две руки — вдвое больше. Два гроба — тоже."
rarity: rare
stat_mods:
  pickup_mult: 2.0
  ammo_mult: 0.5
  improvised_degrade_mult: 2.0
trigger: on_pickup
trade_off: Ranged weapons severely limited. Improvised break fast. Must rely on melee + doubled stat gains.
unlock_condition: reach floor 2
visual_id: golden_hand_shimmer
balance_notes:
  Best paired with melee-focused builds. Double stat upgrades = snowball potential.
  With Demon Eye (A1): ranged bonus helps offset halved ammo somewhat. Contradictory.
```

---

## A7 — RING OF WRATH

```
id: a7_ring_of_wrath
display_name_en: Ring of Wrath
display_name_ru: Кольцо гнева
description: +60% damage to enemies at full health (first strike). But -40% damage to already-damaged enemies.
flavor_text:
  "Первый удар — гром. Остальные — шёпот."
  "Гнев быстр. Упорство — нет."
rarity: rare
stat_mods:
  full_hp_enemy_damage_mult: +0.60
  damaged_enemy_damage_mult: -0.40
trigger: on_hit_dealt (checks target HP state)
trade_off: Sustained fights are weaker. Must one-shot or heavily wound on first hit per enemy.
unlock_condition: reach floor 4
visual_id: ring_wrath_fire_glow
balance_notes:
  Ideal for throw-heavy play (one big throw per enemy). Bad for bosses (long attrition).
  With Pact of Flesh (A8): first strike + powerful limb weapons but constant HP drain.
  Interaction: "full health" = torso HP is at 100%. Limbs don't count.
```

---

## A8 — PACT OF FLESH

```
id: a8_pact_of_flesh
display_name_en: Pact of Flesh
display_name_ru: Пакт плоти
description: Severed limbs auto-equip as weapons with ×2.0 damage and ×1.5 limb sever chance. But player HP drains at 2 HP/s constantly.
flavor_text:
  "Их тела — твоё оружие. Но тело помнит."
  "Плоть служит. Чья — неважно."
rarity: cursed
stat_mods:
  auto_equip_limbs: true
  limb_weapon_damage_mult: 2.0
  limb_weapon_sever_mult: 1.5
  player_hp_drain: 2.0
trigger: on_limb_sever (auto-equip) + passive (drain)
trade_off: Constant HP drain. Cannot be healed by Second Wind (S9). Must kill fast or die.
unlock_condition: clear floor 5 mini-boss
visual_id: pact_flesh_pale_skin
balance_notes:
  High risk / high reward. With Blood Pact (A2): +50% HP buffer helps, but drain still constant.
  With Hunger Blade (A4): lifesteal offsets drain IF you stay in melee. Dark synergy.
  Excludes S9 Second Wind healing (explicit interaction).
```

---

## A9 — THIRD EYE

```
id: a9_third_eye
display_name_en: Third Eye
display_name_ru: Третий глаз
description: See enemy aggro ranges, health bars, hidden enemies (Spy shimmer enhanced), and trap trigger zones. But screen glitches for 0.5s every ~15s during combat.
flavor_text:
  "Видишь правду. Но правда ломает разум."
  "Третий глаз открыт. То, что позади — смотрит на тебя."
rarity: rare
stat_mods:
  show_aggro_ranges: true
  show_enemy_hp: true
  reveal_hidden: true
  show_trap_zones: true
  screen_glitch_duration: 0.5
  screen_glitch_interval: 15.0
trigger: passive (information overlay) + passive (glitch timer)
trade_off: Glitch cannot be disabled during combat. At worst timing can interrupt aim for throws.
unlock_condition: reach floor 6
visual_id: third_eye_forehead_glow
balance_notes:
  Information is power. Best artifact for learning enemy patterns. Glitch is annoying but manageable.
  Stacks info-wise with A1 Demon Eye detection range (both reveal enemy info, different method).
```

---

## A10 — DEMON HEART

```
id: a10_demon_heart
display_name_en: Demon Heart
display_name_ru: Сердце демона
description: On death: revive with 50% HP at current position, once per run. Stun all nearby enemies for 2s. But all enemies gain +25% HP per limb and +15% damage.
flavor_text:
  "Второй шанс. Но они тоже сильнее."
  "Сердце бьётся дважды. Их — тоже."
rarity: cursed
stat_mods:
  revive_on_death: true
  revive_hp_pct: 0.50
  revive_stun_radius: 150
  revive_stun_duration: 2.0
  enemy_limb_hp_mult: +0.25
  enemy_damage_mult: +0.15
trigger: on_player_death (one-shot, once per run)
trade_off: Every enemy is harder for the entire run. Revive is one-time safety net.
unlock_condition: reach floor 4 mini-boss
visual_id: demon_heart_chest_glow
balance_notes:
  With Blood Pact (A2): revive at 75% instead of 50%, but enemies have +65% limb HP combined.
  Revive + Iron Will (A3) grab immunity = very safe second chance. But enemies hit 15% harder.
```

---

## A11 — CROWN OF THORNS

```
id: a11_crown_of_thorns
display_name_en: Crown of Thorns
display_name_ru: Венец терновый
description: +1 weapon slot (3 total) and +15% attack speed on all weapons. But +30% damage taken from all sources and blood pools deal 3 dmg/s.
flavor_text:
  "Больше оружия. Но каждая рана — двойная."
  "Венец давит. Давление — это привилегия."
rarity: cursed
stat_mods:
  max_weapon_slots: +1
  attack_speed_mult: +0.15
  damage_taken_mult: +0.30
  blood_pool_dmg: 3.0
trigger: passive
trade_off: Glass cannon. More weapons + faster attacks but you die much quicker.
unlock_condition: clear basement under 30 seconds
visual_id: crown_thorns_red
balance_notes:
  Triple-wielding is unique. With Iron Will (A3): immune to grab + 3 slots — very strong
  but +30% damage taken with -25% speed = getting hit more and hitting harder.
  Blood pool damage synergises with Pact of Flesh (A8) drain — both punish passively.
```

---

## A12 — VOID CONTRACT

```
id: a12_void_contract
display_name_en: Void Contract
display_name_ru: Вердикт пустоты
description: +50% damage to mini-bosses and Satan. +30% limb sever chance on all attacks. But basement escape becomes impossible — capture = instant run over.
flavor_text:
  "Финал. Без вариантов."
  "Подписано. Печатей нет. Выхода тоже."
rarity: cursed
stat_mods:
  boss_damage_mult: +0.50
  sever_chance_mult: +0.30
  basement_escape: false
trigger: passive
trade_off: No second chance on death. If captured → run over immediately. High stakes.
unlock_condition: reach floor 9 (guaranteed spawn)
visual_id: void_contract_black_paper
balance_notes:
  Final-floor artifact. Pure boss-killer. Anti-synergy with Demon Heart (A10) —
  if you have both, Demon Heart revive works but if captured, no basement, instant death.
  Best paired with defensive artifacts (Iron Will, Blood Pact) for survivability.
```

---
---

# APPENDIX B: STAT UPGRADE SPEC v2 (DATA-DRIVEN)

> S1–S11 complete card. S9 and S11 include exact pseudo-code triggers.

---

## S1 — VITALITY SHARD

```
id: s1_vitality_shard
display_name_en: Vitality Shard
display_name_ru: Осколок жизни
effect: +25 Max HP
type: additive
value: 25
max_stacks: 3
diminishing_3rd: 0.50 (3rd stack gives +12 instead of +25)
spawn_weight: 8
spawn_floors: 1-9
visual_id: vitality_shard_red_crystal
trigger: on_pickup (immediate, permanent for run)
pseudo_code:
  RunState.player_max_hp += 25  # or 12 if 3rd stack
  RunState.player_hp = min(RunState.player_hp + 25, RunState.player_max_hp)
```

---

## S2 — SWIFT STEP

```
id: s2_swift_step
display_name_en: Swift Step
display_name_ru: Быстрый шаг
effect: +12% Movement Speed
type: additive_percent
value: 0.12
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 6
spawn_floors: 1-9
visual_id: swift_step_blue_feather
trigger: on_pickup (immediate, permanent for run)
pseudo_code:
  RunState.player_speed *= (1.0 + 0.12 * count)  # count adjusted for diminishing
```

---

## S3 — IRON SKIN

```
id: s3_iron_skin
display_name_en: Iron Skin
display_name_ru: Железная кожа
effect: -15% Damage Taken
type: additive_percent
value: -0.15
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 5
spawn_floors: 1-9
visual_id: iron_skin_grey_shield
trigger: on_pickup (immediate, permanent for run)
pseudo_code:
  # In player take_damage():
  actual_damage = raw_damage * (1.0 - 0.15 * count)
```

---

## S4 — RAZOR EDGE

```
id: s4_razor_edge
display_name_en: Razor Edge
display_name_ru: Острый клинок
effect: +20% Melee Damage
type: additive_percent
value: 0.20
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 6
spawn_floors: 1-9
visual_id: razor_edge_orange_blade
trigger: on_pickup (immediate, permanent for run)
pseudo_code:
  # In melee damage calculation:
  melee_damage *= (1.0 + 0.20 * count)
```

---

## S5 — SURE SHOT

```
id: s5_sure_shot
display_name_en: Sure Shot
display_name_ru: Верный выстрел
effect: +20% Ranged Damage
type: additive_percent
value: 0.20
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 5
spawn_floors: 1-9
visual_id: sure_shot_yellow_crosshair
trigger: on_pickup (immediate, permanent for run)
pseudo_code:
  # In ranged damage calculation:
  ranged_damage *= (1.0 + 0.20 * count)
```

---

## S6 — HEAVY ARM

```
id: s6_heavy_arm
display_name_en: Heavy Arm
display_name_ru: Тяжёлая рука
effect: +25% Throw Damage
type: additive_percent
value: 0.25
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 4
spawn_floors: 1-9
visual_id: heavy_arm_purple_fist
trigger: on_pickup (immediate, permanent for run)
pseudo_code:
  # In throw damage calculation:
  throw_damage *= (1.0 + 0.25 * count)
```

---

## S7 — QUICK HANDS

```
id: s7_quick_hands
display_name_en: Quick Hands
display_name_ru: Быстрые руки
effect: +20% Pickup/Interact Speed
type: additive_percent
value: 0.20
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 5
spawn_floors: 1-9
visual_id: quick_hands_green_hand
trigger: on_pickup (immediate, permanent for run)
pseudo_code:
  # In interact/pickup timer:
  interact_time = base_time / (1.0 + 0.20 * count)
```

---

## S8 — STEADY GRIP

```
id: s8_steady_grip
display_name_en: Steady Grip
display_name_ru: Крепкий хват
effect: -30% Grab Vulnerability
type: additive_percent
value: -0.30
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 4
spawn_floors: 3-9
visual_id: steady_grip_broken_chain
trigger: on_pickup (immediate, permanent for run)
pseudo_code:
  # In grab check:
  grab_success_chance = base_grap_chance * (1.0 - 0.30 * count)
  # Also reduces break-free time:
  break_free_time = base_break_time * (1.0 - 0.30 * count)
```

---

## S9 — SECOND WIND

```
id: s9_second_wind
display_name_en: Second Wind
display_name_ru: Второе дыхание
effect: Regen 1 HP/s when HP < 30%
type: conditional_passive
value: 1.0  # HP per second
threshold: 0.30  # 30% of max HP
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 3
spawn_floors: 3-9
visual_id: second_wind_white_pulse
trigger: passive (checked every player tick)
pseudo_code: |
  # Checked every _process frame (delta seconds)
  func check_second_wind(delta: float, run_state: RunState) -> void:
      var stacks := run_state.get_stack_count("s9_second_wind")
      if stacks == 0:
          return
      var threshold := run_state.player_max_hp * 0.30
      if run_state.player_hp < threshold:
          var heal_rate := 1.0 * stacks  # 1 HP/s per stack
          # 3rd stack at 50%: (2 * 1.0) + (1 * 0.5) = 2.5 HP/s
          run_state.player_hp = min(
              run_state.player_hp + heal_rate * delta,
              threshold  # CAPPED at 30% — cannot regen above threshold
          )

  # INTERACTION: If player has a8_pact_of_flesh (Pact of Flesh),
  # Second Wind is DISABLED. The drain overrides the regen.
  # This is checked in the same function:
  if run_state.has_artifact("a8_pact_of_flesh"):
      return  # No second wind healing
```

---

## S10 — AMMO POUCH

```
id: s10_ammo_pouch
display_name_en: Ammo Pouch
display_name_ru: Патронная сумка
effect: +50% Ammo for all guns
type: multiplicative_percent
value: 0.50
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 5
spawn_floors: 1-9
visual_id: ammo_pouch_brown_pouch
trigger: on_pickup (immediate, retroactive to current weapons)
pseudo_code:
  # Applied when picking up any gun:
  gun.ammo = int(gun.base_ammo * (1.0 + 0.50 * count))
```

---

## S11 — BLOODLUST

```
id: s11_bloodlust
display_name_en: Bloodlust
display_name_ru: Кровожадность
effect: +10% All Damage for 3 seconds after killing an enemy
type: conditional_temporary
value: 0.10
duration: 3.0  # seconds
max_stacks: 3
diminishing_3rd: 0.50
spawn_weight: 3
spawn_floors: 3-9
visual_id: bloodlust_red_eye
trigger: on_kill (enemy torso HP reaches 0 or enemy collapses)
pseudo_code: |
  var bloodlust_timer: float = 0.0
  var bloodlust_stacks: int = 0

  # Triggered by EventBus.enemy_collapsed or when enemy.torso_hp <= 0:
  func on_enemy_killed(_enemy: CharacterBody2D) -> void:
      bloodlust_stacks = run_state.get_stack_count("s11_bloodlust")
      bloodlust_timer = 3.0  # Reset to 3 seconds on each kill

  # Checked every _process:
  func update_bloodlust(delta: float) -> void:
      if bloodlust_timer > 0:
          bloodlust_timer -= delta
          if bloodlust_timer <= 0:
              bloodlust_stacks = 0  # Expired

  # Applied in damage calculation:
  func get_bloodlust_damage_mult() -> float:
      if bloodlust_timer > 0:
          var effective_stacks := mini(bloodlust_stacks, 3)
          # 1 stack = +10%, 2 = +20%, 3 = +25% (diminishing on 3rd)
          var bonus := 0.0
          for i in range(effective_stacks):
              if i < 2:
                  bonus += 0.10
              else:
                  bonus += 0.05  # 50% of 0.10
          return 1.0 + bonus
      return 1.0

  # Usage: final_damage = base_damage * get_bloodlust_damage_mult()
  # Note: stacks extend duration on consecutive kills (chain killing).
  # A new kill resets timer to 3.0 but does NOT increase stack beyond what you picked up.
```
