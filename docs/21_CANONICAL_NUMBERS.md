# CANONICAL NUMBERS — HOTEL
## Single Source of Truth (v1.0)

> Этот документ — единственный источник числовых констант для проекта.
> Все другие документы обязаны ссылаться сюда и не противоречить.

---

## 1. DAMAGE ZONES: 6

| Index | Zone | ID | Has HP | Notes |
|-------|------|----|--------|-------|
| 0 | Head | `head` | Yes | Stun + blind when HP=0 |
| 1 | Left Arm | `left_arm` | Yes | Weapon drop when HP=0 |
| 2 | Right Arm | `right_arm` | Yes | Weapon drop when HP=0 |
| 3 | Left Leg | `left_leg` | Yes | Mobility loss when HP=0 |
| 4 | Right Leg | `right_leg` | Yes | Mobility loss when HP=0 |
| 5 | Torso | `torso` | Yes | Main HP pool; 0 = collapsed |

**Exceptions:** Vault Drone and Demon have NO limbs (torso-only, 1 zone).

**Source:** `DamageZone` enum in `combat/damage_system.gd`; confirmed by 01_GDD 2.2.1, 02_TDD 3.1.

---

## 2. MINI-BOSSES: 10

| # | Floor | Name | Type | ID |
|---|-------|------|------|----|
| 1 | 1 | Head Chef | Enhanced | `boss_head_chef` |
| 2 | 2 | Madame | Unique (deception) | `boss_madame` |
| 3 | 3 | The Gourmand | Unique (growth) | `boss_gourmand` |
| 4 | 4 | The Accountant | Enhanced (traps) | `boss_accountant` |
| 5 | 5 | Attendant Prime | Unique (stealth+fog) | `boss_attendant_prime` |
| 6 | 6 | The Champion | Unique (wave+1v1) | `boss_champion` |
| 7 | 7 | The Curator | Unique (theft+stealth) | `boss_curator` |
| 8 | 8 | The Consort | Unique (squad command) | `boss_consort` |
| 9 | 9 | The Sister | Unique (narrative) | `boss_sister` |
| 10 | 9 | Satan | Unique (final boss) | `boss_satan` |

**Floor 9 = 2 bosses** (Sister encounter then Satan). This makes 10 total, not 9.

**Source:** 14_BOSS_DESIGN, 01_GDD 2.4.3.

---

## 3. ENEMY TYPES: 21

| ID | Name | Category | Floors |
|----|------|----------|--------|
| `staff` | Staff (Персонал) | Base | 1-5 |
| `guard` | Guard (Охрана) | Base | 1-7 |
| `handler` | Handler (Обработчик) | Base | 1-6 |
| `butcher` | Butcher (Мясник) | Base | 3-8 |
| `cultist` | Cultist (Культнист) | Base | 2-9 |
| `seductress` | Seductress (Искусительница) | Floor 2 | 2 |
| `bodyguard` | Bodyguard (Телохранитель) | Floor 2 | 2 |
| `chef` | Chef (Шеф-повар) | Floor 3 | 3 |
| `taster` | Taster (Дегустатор) | Floor 3 | 3 |
| `banker` | Banker (Банкир) | Floor 4 | 4 |
| `vault_drone` | Vault Drone (Дрон хранилища) | Floor 4 | 4 |
| `attendant` | Attendant (Служитель спа) | Floor 5 | 5 |
| `drowned_one` | Drowned One (Утопленник) | Floor 5 | 5 |
| `gladiator` | Gladiator (Гладиатор) | Floor 6 | 6 |
| `berserker` | Berserker (Берсерк) | Floor 6 | 6 |
| `spy` | Spy (Шпион) | Floor 7 | 7 |
| `shadow_stalker` | Shadow Stalker (Теневой охотник) | Floor 7 | 7 |
| `royal_guard` | Royal Guard (Королевский гвардеец) | Floor 8 | 8 |
| `champion` | Champion (Чемпион) | Floor 8 | 8 |
| `demon` | Demon (Демон) | Floor 9 | 9 |
| `the_sister` | The Sister (Сестра) | Floor 9 | 9 |

**Breakdown:** 5 base + 2×7 floors (F2-F8) + 2 (F9) = 5 + 14 + 2 = **21**.

**Source:** 11_ENEMY_DESIGN section 7 (count summary), confirmed against GDD 2.4.1.

---

## 4. STAT UPGRADES: 11

| ID | Name | Effect | Spawn Weight |
|----|------|--------|-------------|
| `s1_vitality_shard` | Vitality Shard | +25 Max HP | 8 |
| `s2_swift_step` | Swift Step | +12% Movement Speed | 6 |
| `s3_iron_skin` | Iron Skin | -15% Damage Taken | 5 |
| `s4_razor_edge` | Razor Edge | +20% Melee Damage | 6 |
| `s5_sure_shot` | Sure Shot | +20% Ranged Damage | 5 |
| `s6_heavy_arm` | Heavy Arm | +25% Throw Damage | 4 |
| `s7_quick_hands` | Quick Hands | +20% Pickup/Interact Speed | 5 |
| `s8_steady_grip` | Steady Grip | -30% Grab Vulnerability | 4 |
| `s9_second_wind` | Second Wind | Regen 1 HP/s when HP <30% | 3 |
| `s10_ammo_pouch` | Ammo Pouch | +50% Ammo for all guns | 5 |
| `s11_bloodlust` | Bloodlust | +10% Damage for 3s after kill | 3 |

**Stacking:** Additive, max 3 same stat per run, 3rd = 50% value.

**Source:** 15_UPGRADE_DESIGN 2.1.

---

## 5. CULT ARTIFACTS: 12

| ID | Name | Rarity |
|----|------|--------|
| `a1_demon_eye` | Demon Eye / Демонов глаз | common |
| `a2_blood_pact` | Blood Pact / Кровавый пакт | common |
| `a3_iron_will` | Iron Will / Железная воля | common |
| `a4_hunger_blade` | Hunger Blade / Голодный клинок | rare |
| `a5_shadow_step` | Shadow Step / Теневой шаг | common |
| `a6_golden_hand` | Golden Hand / Золотая рука | rare |
| `a7_ring_of_wrath` | Ring of Wrath / Кольцо гнева | rare |
| `a8_pact_of_flesh` | Pact of Flesh / Пакт плоти | cursed |
| `a9_third_eye` | Third Eye / Третий глаз | rare |
| `a10_demon_heart` | Demon Heart / Сердце демона | cursed |
| `a11_crown_of_thorns` | Crown of Thorns / Венец терновый | cursed |
| `a12_void_contract` | Void Contract / Вердикт пустоты | cursed |

**Source:** 15_UPGRADE_DESIGN 3.2.

---

## 6. TOTAL ROOMS: 88

| Floor | Rooms | Name |
|-------|-------|------|
| 1 | 10 | Service Underground |
| 2 | 10 | Red Light District |
| 3 | 11 | Banquet Hall |
| 4 | 10 | Vault |
| 5 | 10 | Spa |
| 6 | 9 | Arena |
| 7 | 10 | Observatory |
| 8 | 10 | Ballroom |
| 9 | 8 | Satan's Sanctum |
| **Total** | **88** | |

**+1 Basement** (shared layout, not counted per-floor).

**Source:** 13_FLOOR_DESIGN section 11 (progression summary), confirmed by room-by-room count per floor.

---

## 7. OTHER FIXED CONSTANTS

| Element | Count | Notes |
|---------|-------|-------|
| Floors | 9 | Handcrafted |
| Weapon types | 15 | See 12_WEAPON_DESIGN |
| Weapon slots (base) | 2 | Can increase to 3 via Crown of Thorns |
| Player base HP | 100 | |
| Player base speed | 200 px/s | |
| Max weapon slots | 2 (base) | +1 with a11 |
| Basement layouts | 1 | Shared |
| Endings | 4 | A, B, C, D |
| Collision layers | 8 | See 02_TDD 3.4 |
| Regeneration baseline | 30 s/limb | ×regen_speed per enemy |
| Viewport | 640×360 | Pixel-perfect |
| Tile size | 32×32 | |
| Max active enemies on screen | 10 | Performance budget |
| Run duration target | 30-40 min | |
