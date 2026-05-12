# META-PROGRESSION SPEC — HOTEL
## Version 1.0

> Прогресс между run'ами. Unlock tree, стартовые разблокировки, recommendation-формула.

---

# 1. DESIGN PHILOSOPHY

- **No power creep between runs.** The game is roguelike — each run is self-contained.
- **Variety unlocks, not stat unlocks.** You unlock OPTIONS, not power.
- **Knowledge is progression.** Lore, enemy patterns, floor layouts — player skill matters.
- **Cosmetic + build variety.** New artifacts and stat upgrades in the starting pool = more run variety.

---

# 2. STARTING POOL (Available from Run 1)

## 2.1 Start-Unlocked Artifacts (4 of 12)

These 4 artifacts can appear on Floor 1 in every run:

| ID | Name | Why Start-Unlocked |
|----|------|--------------------|
| `a1_demon_eye` | Demon Eye | Simple trade-off, teaches artifact concept |
| `a2_blood_pact` | Blood Pact | HP buffer = forgiving for new players |
| `a3_iron_will` | Iron Will | Grab immunity = safety net |
| `a5_shadow_step` | Shadow Step | Dash = fun, encourages experimentation |

**The remaining 8 artifacts** require unlock conditions (see Section 4).

## 2.2 Start-Unlocked Stat Upgrades (2 of 11)

These 2 stats can appear on Floor 1 in every run:

| ID | Name | Why Start-Unlocked |
|----|------|--------------------|
| `s1_vitality_shard` | Vitality Shard | HP = most intuitive stat |
| `s2_swift_step` | Swift Step | Speed = feels good, easy to understand |

**All other stats** are available from their designated spawn floors (see 15_UPGRADE_DESIGN 2.3), but these two are guaranteed in the Floor 1 loot table.

---

# 3. NEW RUN START STATE

```
Player starts every run with:
  - HP: 100
  - Speed: 200 px/s
  - Weapons: Machete + Sawed-off (4 ammo)
  - Weapon slots: 2
  - Stats: 0 (none collected)
  - Artifacts: 0 (none collected)

Between runs, NOTHING carries over numerically.
What changes: the POOL of available pickups expands based on unlocks.
```

---

# 4. UNLOCK TREE

## 4.1 Artifact Unlocks

| Artifact | Unlock Condition | Rationale |
|----------|-----------------|-----------|
| A1 Demon Eye | **Default** | Starting pool |
| A2 Blood Pact | **Default** | Starting pool |
| A3 Iron Will | **Default** | Starting pool |
| A5 Shadow Step | **Default** | Starting pool |
| A4 Hunger Blade | Reach Floor 3 | Melee sustain = mid-game concept |
| A6 Golden Hand | Reach Floor 2 | Double pickups = need to understand baseline first |
| A7 Ring of Wrath | Reach Floor 4 | First-strike mechanic = needs combat mastery |
| A9 Third Eye | Reach Floor 6 | Information overload = reward for persistence |
| A8 Pact of Flesh | Clear Floor 5 mini-boss (Attendant Prime) | Cursed = earned through skill |
| A10 Demon Heart | Clear Floor 4 mini-boss (Accountant) | Cursed = earned through skill |
| A11 Crown of Thorns | Escape basement under 30s | Cursed = skill challenge |
| A12 Void Contract | Reach Floor 9 | Guaranteed spawn in final floor; unlocked by reaching it |

## 4.2 Stat Upgrade Unlocks (By Floor)

Stats appear in the loot pool based on floor reach, not explicit unlocks:

| Floor Available | Stats |
|----------------|-------|
| 1-2 (always) | S1 Vitality, S2 Swift Step, S4 Razor Edge, S5 Sure Shot, S10 Ammo Pouch |
| 3+ | + S3 Iron Skin, S6 Heavy Arm, S7 Quick Hands, S8 Steady Grip, S9 Second Wind, S11 Bloodlust |

This matches 15_UPGRADE_DESIGN section 2.3 placement rules.

## 4.3 Unlock Trackers (Persistent Between Runs)

```gdscript
# save_manager.gd — persistent meta state
var meta_unlocked_artifacts: Array[String] = [
    "a1_demon_eye", "a2_blood_pact", "a3_iron_will", "a5_shadow_step"
]
var meta_deepest_floor: int = 1
var meta_bosses_killed: Dictionary = {}  # boss_id -> true
var meta_endings_achieved: Array[String] = []
var meta_basement_best_time: float = INF
var meta_total_runs: int = 0
```

## 4.4 Achievement Gates

| Gate | Unlocks | Persistent Tracking |
|------|---------|---------------------|
| Reach Floor 2 | A6 Golden Hand in pool | `meta_deepest_floor >= 2` |
| Reach Floor 3 | A4 Hunger Blade in pool | `meta_deepest_floor >= 3` |
| Clear Floor 4 boss | A10 Demon Heart in pool | `meta_bosses_killed["boss_accountant"]` |
| Reach Floor 4 | A7 Ring of Wrath in pool | `meta_deepest_floor >= 4` |
| Clear Floor 5 boss | A8 Pact of Flesh in pool | `meta_bosses_killed["boss_attendant_prime"]` |
| Reach Floor 6 | A9 Third Eye in pool | `meta_deepest_floor >= 6` |
| Basement under 30s | A11 Crown of Thorns in pool | `meta_basement_best_time < 30.0` |
| Reach Floor 9 | A12 Void Contract in pool | `meta_deepest_floor >= 9` |
| Ending A achieved | Lore: Sister's letter in menu | `meta_endings_achieved.has("A")` |
| Ending B achieved | Lore: Anna's photo in menu | `meta_endings_achieved.has("B")` |
| Ending C achieved | Lore: The original contract in menu | `meta_endings_achieved.has("C")` |
| Ending D achieved | Lore: Board meeting minutes in menu | `meta_endings_achieved.has("D")` |
| All 4 endings | Lore: Complete truth (hidden scene) | `meta_endings_achieved.size() == 4` |

---

# 5. MAIN MENU RECOMMENDATION SYSTEM

## 5.1 Purpose

After each run, the main menu shows a suggestion to guide the player toward natural progression.

## 5.2 Recommendation Logic

```gdscript
func get_recommendation(meta: MetaState) -> Dictionary:
    var deepest := meta.meta_deepest_floor
    var endings := meta.meta_endings_achieved
    var runs := meta.meta_total_runs

    # Priority 1: Never completed a run
    if deepest <= 1 and runs <= 2:
        return {
            "text_en": "Push deeper. Floor 2 awaits.",
            "text_ru": "Иди глубже. Этаж 2 ждёт.",
            "target_floor": 2
        }

    # Priority 2: Haven't reached mid-game
    if deepest <= 3:
        return {
            "text_en": "The Banquet Hall hungers. Try Floor 3.",
            "text_ru": "Банкетный зал голоден. Попробуй этаж 3.",
            "target_floor": 3
        }

    # Priority 3: Haven't reached late-game
    if deepest <= 5:
        return {
            "text_en": "The Spa is relaxing. Don't fall asleep. Try Floor 5.",
            "text_ru": "Спа расслабляет. Не засни. Попробуй этаж 5.",
            "target_floor": 5
        }

    # Priority 4: Haven't reached endgame
    if deepest <= 7:
        return {
            "text_en": "The Ballroom demands perfection. Try Floor 7.",
            "text_ru": "Бальный зал требует совершенства. Попробуй этаж 7.",
            "target_floor": 7
        }

    # Priority 5: Haven't reached Floor 9
    if deepest == 8:
        return {
            "text_en": "She's waiting. Floor 9.",
            "text_ru": "Она ждёт. Этаж 9.",
            "target_floor": 9
        }

    # Priority 6: Reached Floor 9 but no endings
    if deepest == 9 and endings.is_empty():
        return {
            "text_en": "You've seen the truth. But whose truth?",
            "text_ru": "Ты видел правду. Но чью?",
            "target_floor": 9
        }

    # Priority 7: Some endings achieved, push for others
    if not endings.has("B"):
        return {
            "text_en": "She can still be saved. Try sparing the Sister.",
            "text_ru": "Её ещё можно спасти. Попробуй пощадить Сестру.",
            "target_floor": 9
        }

    if not endings.has("C"):
        return {
            "text_en": "What if you never raised your weapon?",
            "text_ru": "Что если бы ты никогда не поднимал оружие?",
            "target_floor": 9
        }

    if not endings.has("D"):
        return {
            "text_en": "Every deal has two sides. Accept the offer.",
            "text_ru": "У каждой сделки две стороны. Прими предложение.",
            "target_floor": 9
        }

    # Priority 8: All endings achieved
    if endings.size() == 4:
        return {
            "text_en": "You've seen everything. Or have you?",
            "text_ru": "Ты видел всё. Или нет?",
            "target_floor": 1
        }

    # Fallback
    return {
        "text_en": "The Hotel remembers.",
        "text_ru": "Отель помнит.",
        "target_floor": mini(deepest, 9)
    }
```

## 5.3 UI Placement

```
Main Menu:
┌───────────────────────────────────────────┐
│                                           │
│        H O T E L                          │
│                                           │
│   [NEW RUN]                               │
│   [CONTINUE]  (if run in progress)        │
│   [LORE JOURNAL]                          │
│   [SETTINGS]                              │
│                                           │
│   ┌─────────────────────────────────┐     │
│   │ 💡 "She's waiting. Floor 9."    │     │
│   └─────────────────────────────────┘     │
│                                           │
│   Deepest Floor: 7 | Runs: 14            │
│   Endings: A ✅ B ✅ C ⬜ D ⬜            │
│                                           │
└───────────────────────────────────────────┘
```

---

# 6. LORE JOURNAL (Between-Run Content)

## 6.1 Structure

Lore Journal is a menu-accessible collection of found notes and unlocked lore.

| Section | Content | Unlock |
|---------|---------|--------|
| **Documents** | All lore notes found across runs | Per-note, found in rooms |
| **Enemy Codex** | Enemy types encountered + stats | First encounter per type |
| **Boss Records** | Boss defeated + pattern notes | First kill per boss |
| **Artifact Archive** | Artifact descriptions + trade-offs | First pickup per artifact |
| **Endings Gallery** | Ending descriptions + conditions | Achievement per ending |
| **The Truth** | Hidden section, complete lore | All 4 endings achieved |

## 6.2 Persistence

```gdscript
var meta_lore_notes_found: Array[String] = []        # "F1-03", "F2-01", etc.
var meta_enemies_encountered: Array[String] = []       # "staff", "guard", etc.
var meta_artifacts_found: Array[String] = []           # "a1_demon_eye", etc.
```

These persist across runs. Finding a note once = permanently in journal.

---

# 7. NO GRIND, NO CURRENCY

**Explicit design decision:**

- No in-game currency between runs.
- No "soul" system (Hades-style).
- No upgrade tree that makes you stronger permanently.
- The ONLY between-run content is: **unlock pool expansion + lore collection.**

Why: The game's thematic core is "deals have prices." Giving free power between runs undermines that.

---

# 8. STAT VISIBILITY ON MAIN MENU

After each run, the main menu footer shows:

```
┌─────────────────────────────────────────────┐
│ Deepest: F7 | Runs: 23 | Bosses: 5/10      │
│ Artifacts: 8/12 | Endings: A ✅ B ⬜ C ⬜ D ⬜│
│ Best basement: 28s | Lore: 34%              │
└─────────────────────────────────────────────┘
```

This gives players goals without pressure. "5 more bosses to find." "2 endings left."
