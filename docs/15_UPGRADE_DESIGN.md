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
