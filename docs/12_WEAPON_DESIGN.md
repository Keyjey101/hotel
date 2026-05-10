# WEAPON DESIGN DOCUMENT — HOTEL
## Version 1.0

---

# 1. WEAPON SYSTEM OVERVIEW

## 1.1 Core Principles

- **15 weapon types**, каждый уникален
- **ЛЮБОЕ оружие можно бросить** с уникальным эффектом
- **2 слота** — носишь 2 оружия, переключаешься мгновенно
- **Ammo** — огнестрельное имеет патроны, melee — безлимитное
- **Pick up / Drop** — оружие на полу видно, подбираешь нажатием
- **Weapon economy** — ключевой skill: подобрать правильное оружие в правильный момент

## 1.2 Weapon Data Structure

Каждое оружие определяется:

| Parameter | Описание |
|-----------|----------|
| name | Название |
| type | melee / ranged / improvised |
| damage | Базовый урон (torso hit) |
| limb_damage | Множитель урона по конечностям (×) |
| speed | Кадров между атаками (меньше = быстрее) |
| range | Дальность в px |
| knockback | Сила отбрасывания (0-100) |
| stun_chance | Шанс stun (0.0-1.0) |
| stun_duration | Длительность stun (секунды) |
| sever_chance | Шанс отрубить конечность (0.0-1.0) |
| ammo | Патроны (−1 = infinite) |
| throw_damage | Урон при броске |
| throw_speed | Скорость полёта |
| throw_effect | Спецэффект при попадании |
| throw_arc | Траектория: straight / arc / spin |
| sprite | Путь к спрайту |
| pickup_sprite | Спрайт на полу |

---

# 2. MELEE WEAPONS

---

## 2.1 MACHETE (Мачете) — STARTING WEAPON

*«Простой инструмент. Не гламурный. Но эффективный.»*

| Parameter | Value |
|-----------|-------|
| Type | Melee |
| Damage | 20 |
| Limb Damage | ×1.5 |
| Speed | 12 frames (0.2s) |
| Range | 45 px |
| Knockback | 15 |
| Stun Chance | 0.1 |
| Stun Duration | 0.3s |
| Sever Chance | 0.25 |

**Melee Attack:**
- Horizontal slash arc (90°)
- Быстрый swing, хороший coverage
- Animation: wind-up (2f) → swing (6f) → recovery (4f)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 18 |
| Throw Speed | 400 px/s |
| Throw Arc | Spin (rotates vertically) |
| Throw Effect | Stick — застревает в цели, 3s bleed (3 dmg/s) |

**Visual:** Wide blade, wooden handle, 16×6 px. Worn, practical look.

**Design note:** Стартовое оружие. Reliable, без экстрима. Хороший sever chance для early game.

---

## 2.2 KNIFE (Нож)

*«Маленький. Быстрый. Точный. Не для убийства — для хирургии.»*

| Parameter | Value |
|-----------|-------|
| Type | Melee |
| Damage | 10 |
| Limb Damage | ×2.0 |
| Speed | 6 frames (0.1s) |
| Range | 30 px |
| Knockback | 5 |
| Stun Chance | 0.05 |
| Stun Duration | 0.2s |
| Sever Chance | 0.15 |

**Melee Attack:**
- Quick stab (thrust, not slash)
- Очень быстрый — самый быстрый melee в игре
- Низкий урон, но высочайший limb damage — лучший для targetted mutilation
- Animation: thrust (3f) → pull (3f)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 12 |
| Throw Speed | 600 px/s (fastest throw) |
| Throw Arc | Straight |
| Throw Effect | Pin — прикалывает врага к стене если рядом стена (stun 3s). Иначе: stick + bleed 2 dmg/s × 3s |

**Visual:** Small thin blade, 10×4 px. Glinting tip.

**Design note:** The "surgeon's tool" — используй для точного калечения конкретных конечностей. Не для урона — для disassembly.

---

## 2.3 AXE (Топор)

*«Тяжёлый. Медленный. Безотказный. Кость — это просто дерево.»*

| Parameter | Value |
|-----------|-------|
| Type | Melee |
| Damage | 35 |
| Limb Damage | ×1.8 |
| Speed | 24 frames (0.4s) |
| Range | 50 px |
| Knockback | 40 |
| Stun Chance | 0.4 |
| Stun Duration | 0.8s |
| Sever Chance | 0.5 |

**Melee Attack:**
- Overhead chop (vertical)
- Самый медленный melee, но devastating
- High stagger → high sever → GUARANTEED sever если limb HP < 30%
- Animation: raise (8f) → chop (8f) → pull (8f)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 30 |
| Throw Speed | 300 px/s (slow) |
| Throw Arc | Arc (gravity-affected) |
| Throw Effect | Embed — застревает глубоко. 5s bleed (4 dmg/s). Цель slowed 40% пока axe embedded (7s) |

**Visual:** Heavy head, short handle, 14×12 px. Blood-stained blade.

**Design note:** The "finisher" — используй чтобы добить уже повреждённую конечность. Guaranteed sever — это надёжность.

---

## 2.4 BAT (Бита)

*«Не изящно. Зато громко. И больно. Очень больно.»*

| Parameter | Value |
|-----------|-------|
| Type | Melee |
| Damage | 18 |
| Limb Damage | ×0.8 |
| Speed | 14 frames (0.23s) |
| Range | 55 px |
| Knockback | 60 (highest melee) |
| Stun Chance | 0.35 |
| Stun Duration | 0.6s |
| Sever Chance | 0.05 |

**Melee Attack:**
- Wide horizontal swing (180° arc)
- Средний урон, но MASSIVE knockback
- Crowd control weapon — отбрасывай врагов от себя
- Animation: wind-up (3f) → swing (6f) → follow-through (5f)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 15 |
| Throw Speed | 350 px/s |
| Throw Arc | Tumble (rotates horizontally) |
| Throw Effect | Bounce — рикошетит от первой цели, летит дальше (60% damage на второй цели) |

**Visual:** Wooden bat, 20×4 px. Maybe with nails (cosmetic).

**Design note:** NOT для mutilation — для SPACE MANAGEMENT. Отбрасывай врагов, создавай room для дыхания.

---

## 2.5 CULT BLADE (Культовый клинок)

*«Клинок пил. Клинок помнит. Клинок хочет.»*

| Parameter | Value |
|-----------|-------|
| Type | Melee (cult) |
| Damage | 28 |
| Limb Damage | ×2.0 |
| Speed | 16 frames (0.27s) |
| Range | 55 px |
| Knockback | 20 |
| Stun Chance | 0.2 |
| Stun Duration | 0.5s |
| Sever Chance | 0.4 |

**Melee Attack:**
- Diagonal slash (two-hit combo при rapid press)
- Второй hit: ×1.3 damage
- Occult glow trail при swing (visual flair)
- Animation: slash1 (8f) → slash2 (8f) или recovery (4f)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 25 |
| Throw Speed | 450 px/s |
| Throw Arc | Spin (vertical rotation, occult trail) |
| Throw Effect | Blood Syphon — восстанавливает player HP = 30% от нанесённого throw damage (7-8 HP) |

**Visual:** Ornate blade, 20×6 px. Faint red glow, runes along blade.

**Design note:** Rare cult weapon — best melee overall. Blood Syphon throw = emergency heal. High risk (throw away best melee) / high reward (heal).

---

# 3. RANGED WEAPONS

---

## 3.1 SAWED-OFF (Обрез) — STARTING WEAPON

*«Дедово ружьё. Укороченное. Два выстрела. Больше не надо.»*

| Parameter | Value |
|-----------|-------|
| Type | Ranged |
| Damage | 25 (per pellet, 5 pellets) |
| Limb Damage | ×1.2 |
| Speed | 20 frames (0.33s) между выстрелами |
| Range | 120 px (effective), 180 px (max) |
| Knockback | 50 |
| Stun Chance | 0.3 |
| Stun Duration | 0.5s |
| Sever Chance | 0.15 |
| Ammo | 4 (2 per barrel, pump between shots) |

**Ranged Attack:**
- Cone spread (30°), 5 pellets
- Close range devastation, useless at range
- Pump animation между выстрелами (6f)
- Animation: fire (4f) → pump (6f) → ready

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 10 |
| Throw Speed | 300 px/s |
| Throw Arc | Tumble |
| Throw Effect | Discharge — 35% шанс что оружие стреляет при impact. Random direction, single pellet |

**Visual:** Short barrel, wooden stock, saw marks, 16×8 px.

**Design note:** Стартовое ranged. Мощное вблизи, ограниченные патроны. Превращается в gamble при броске.

---

## 3.2 PISTOL (Пистолет)

*«Эффективный. Точный. Скучный. Но когда нужен — ничто не лучше.»*

| Parameter | Value |
|-----------|-------|
| Type | Ranged |
| Damage | 15 |
| Limb Damage | ×1.0 |
| Speed | 10 frames (0.17s) между выстрелами |
| Range | 350 px |
| Knockback | 10 |
| Stun Chance | 0.15 |
| Stun Duration | 0.3s |
| Sever Chance | 0.1 |
| Ammo | 12 |

**Ranged Attack:**
- Single bullet, precise, fast
- Good range, moderate damage
- Animation: fire (3f) → recoil (2f) → ready

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 8 |
| Throw Speed | 400 px/s |
| Throw Arc | Tumble |
| Throw Effect | Discharge — 25% шанс random shot при impact |

**Visual:** Compact handgun, 12×6 px. Dark metal.

**Design note:** Workhorse ranged. Не exciting но reliable. Хорош для добивания убегающих и sniping Cultists.

---

## 3.3 SMG

*«Когда один патрон не помогает. Помогает тридцать.»*

| Parameter | Value |
|-----------|-------|
| Type | Ranged |
| Damage | 8 |
| Limb Damage | ×0.7 |
| Speed | 4 frames (0.07s) между выстрелами |
| Range | 250 px |
| Knockback | 5 |
| Stun Chance | 0.05 |
| Stun Duration | 0.15s |
| Sever Chance | 0.03 |
| Ammo | 30 |

**Ranged Attack:**
- Full auto (hold button = continuous fire)
- Low per-hit damage, but massive DPS at close range
- Spread increases with sustained fire (accuracy degrades)
- Animation: fire (2f loop) → muzzle flash

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 8 |
| Throw Speed | 350 px/s |
| Throw Arc | Tumble |
| Throw Effect | Spray — 50% шанс: weapon fires 5 bullets в random directions при impact |

**Visual:** Boxier than pistol, magazine visible, 16×6 px.

**Design note:** Spray and pray. Good для stagger-locking enemies. Bad для precision mutilation. Throw = hilarious chaos.

---

## 3.4 SHOTGUN (Дробовик)

*«Когда обрез — это слишком мало.»*

| Parameter | Value |
|-----------|-------|
| Type | Ranged |
| Damage | 20 (per pellet, 8 pellets) |
| Limb Damage | ×1.5 |
| Speed | 30 frames (0.5s) между выстрелами |
| Range | 150 px (effective), 220 px (max) |
| Knockback | 70 (highest ranged) |
| Stun Chance | 0.4 |
| Stun Duration | 0.6s |
| Sever Chance | 0.2 |
| Ammo | 6 |

**Ranged Attack:**
- Wide cone (45°), 8 pellets
- DEVASTATING at close range (160 total potential damage)
- Slow pump между shots (10f)
- Animation: fire (4f) → pump (10f) → ready

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 12 |
| Throw Speed | 250 px/s (heavy) |
| Throw Arc | Arc (gravity) |
| Throw Effect | Discharge — 50% шанс full blast при impact (all 8 pellets in random forward cone) |

**Visual:** Long barrel, pump mechanism, 20×6 px. Intimidating.

**Design note:** The "room clearer". Один выстрел может mutilate несколько врагов сразу. Ограниченные патроны — используй wisely.

---

## 3.5 CULT PISTOL (Культовый пистолет)

*«Пули — это молитвы. Каждая — маленькая проповедь.»*

| Parameter | Value |
|-----------|-------|
| Type | Ranged (cult) |
| Damage | 22 |
| Limb Damage | ×1.5 |
| Speed | 14 frames (0.23s) |
| Range | 400 px (longest) |
| Knockback | 15 |
| Stun Chance | 0.2 |
| Stun Duration | 0.4s |
| Sever Chance | 0.25 |
| Ammo | 8 |

**Ranged Attack:**
- Single bullet, piercing (проходит через 2-3 целей)
- Occult tracer (visual: red glowing trail)
- Higher sever chance чем normal pistol
- Animation: charge (4f) → fire (4f) → recoil (6f)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 15 |
| Throw Speed | 500 px/s (fast!) |
| Throw Arc | Straight |
| Throw Effect | Soul Rip — при попадании, 25% шанс disarm цель (force drop weapon) + 5s silence (no special abilities) |

**Visual:** Ornate pistol, 14×7 px. Golden inlay, faint glow.

**Design note:** Rare cult weapon. Piercing = line up enemies. Throw = tactical disarm. Best ranged overall но limited ammo.

---

# 4. IMPROVISED WEAPONS

---

## 4.1 BOTTLE (Бутылка)

*«В неё наливали счастье. Теперь в ней — инструмент.»*

| Parameter | Value |
|-----------|-------|
| Type | Improvised / Consumable |
| Damage | 8 |
| Limb Damage | ×0.5 |
| Speed | 10 frames |
| Range | 35 px |
| Knockback | 10 |
| Stun Chance | 0.3 |
| Stun Duration | 0.4s |
| Sever Chance | 0.0 |

**Melee Attack:**
- Swing → BREAKS on first hit
- After break: transforms into Broken Bottle (shard)
- Broken Bottle: 12 dmg, ×1.2 limb, bleed 2/s × 3s, 0.1 sever

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 10 |
| Throw Speed | 450 px/s |
| Throw Arc | Arc |
| Throw Effect | Shatter — AoE stun в radius 40px (0.8s). Создаёт glass hazard на полу (5 dmg если наступит) × 6s |

**Visual:** Amber bottle, 6×10 px. After break: jagged shard, 4×8 px.

**Design note:** The "panic button". Кинь для AoE stun. Или ударь → разбей → получи bleed weapon. Consumable — одноразовый в обеих формах.

---

## 4.2 CHAIR (Стул)

*«Импровизация — мать brutality.»*

| Parameter | Value |
|-----------|-------|
| Type | Improvised / Destructible |
| Damage | 15 |
| Limb Damage | ×0.6 |
| Speed | 18 frames |
| Range | 50 px |
| Knockback | 45 |
| Stun Chance | 0.25 |
| Stun Duration | 0.5s |
| Sever Chance | 0.0 |

**Melee Attack:**
- Wide swing (massive knockback)
- Degrades: breaks after 3 hits
- Broken chair = Wooden Plank (10 dmg, ×0.8 limb, medium speed)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 12 |
| Throw Speed | 250 px/s (slow, heavy) |
| Throw Arc | Arc (high gravity) |
| Throw Effect | Barricade — chair lands and stays as physical obstacle (blocks path, 50 HP, destroyable). Blocks enemies AND player |

**Visual:** Wooden chair, 14×14 px. Broken: plank, 16×4 px.

**Design note:** The "doorstopper". Кинь стул → creates barrier. Environmental tactic. Breaks → secondary weapon.

---

## 4.3 SEVERED LIMB (Отрубленная конечность)

*«Это была их рука. Теперь — твоя.»*

| Parameter | Value |
|-----------|-------|
| Type | Improvised / Gore |
| Damage | 8 (arm), 12 (leg) |
| Limb Damage | ×0.5 |
| Speed | 8 frames |
| Range | 35 px |
| Knockback | 5 |
| Stun Chance | 0.1 |
| Stun Duration | 0.2s |
| Sever Chance | 0.0 |

**Melee Attack:**
- Flail swing (desperate, sloppy animation)
- Low damage but always available (враги = source оружия)
- Arm: faster, less damage
- Leg: slower, more damage (heavier)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 6 (arm), 10 (leg) |
| Throw Speed | 350 px/s |
| Throw Arc | Tumble (chaotic) |
| Throw Effect | Demoralize — enemies in radius 60px: Aggression −3 × 3s (shocked seeing their own body part) |

**Visual:** Bloody limb with stump, 6×14 px (arm) / 8×14 px (leg). Gore trail when thrown.

**Design note:** The "last resort". Всегда есть если есть трупы. Throw demoralize — unique tactical option. Thematic perfection: using their immortality against them.

---

## 4.4 WIRE (Провод)

*«Тишина. Эффективность. Две секунды.»*

| Parameter | Value |
|-----------|-------|
| Type | Improvised / Grab |
| Damage | 5 (initial), 15/s (sustained) |
| Limb Damage | ×0.3 |
| Speed | 8 frames (grab), sustained while held |
| Range | 30 px (must be close) |
| Knockback | 0 |
| Stun Chance | 0.0 (special: always grabs) |
| Stun Duration | N/A (grab-based) |
| Sever Chance | 0.0 |

**Melee Attack:**
- Garrote: must be behind enemy → grab → sustained damage while held
- Enemy must be unaware or stunned для initiate
- During garrote: enemy can't alert others, can't attack, takes 15 dmg/s
- If enemy regens enough during garrote → breaks free
- Animation: wrap (4f) → pull (sustained loop)

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 3 |
| Throw Speed | 500 px/s (fast) |
| Throw Arc | Straight (long range) |
| Throw Effect | Tangle — wraps around target's legs: speed −50% × 4s. If both legs already damaged: speed −80% |

**Visual:** Thin wire, nearly invisible, 2×20 px when extended.

**Design note:** The "stealth option". Garrote unaware enemies для silent takedown (temporary). Throw = long range slow. Niche но powerful в right situations.

---

## 4.5 CULT RELIC (Культовый артефакт-оружие)

*«Он хочет быть использованным. Он ждёт. Он голоден.»*

| Parameter | Value |
|-----------|-------|
| Type | Improvised / Cult / Unique |
| Damage | 40 (burst) |
| Limb Damage | ×3.0 |
| Speed | 40 frames (0.67s) — charge weapon |
| Range | 60 px (melee burst) |
| Knockback | 80 |
| Stun Chance | 0.6 |
| Stun Duration | 1.2s |
| Sever Chance | 0.8 |
| Ammo | 1 (single use, consumed) |

**Melee Attack:**
- Charge 0.5s → massive occult burst
- 40 dmg, ×3.0 limb, 80% sever — GUARANTEED sever на любой limb
- Consumes the relic (weapon disappears after use)
- Screen effect: reality warps briefly at point of impact

**Throw:**
| Parameter | Value |
|-----------|-------|
| Throw Damage | 50 |
| Throw Speed | 200 px/s (slow, ominous) |
| Throw Arc | Float (drifts slowly, no gravity — supernatural) |
| Throw Effect | Reality Tear — AoE damage radius 80px, 30 dmg. All enemies in radius: limbs take 15 dmg each. Visual: screen cracks + blood vortex |

**Visual:** Small ornate object, 8×10 px. Glowing, shifting colours. Unsettling to look at.

**Design note:** The "nuke". Одноразовый, но devastating. Используй на мини-боссе или в безвыходной ситуации. Самый мощный предмет в игре — и самый редкий.

---

# 5. WEAPON COMPARISON TABLE

## 5.1 Melee Weapons

| Weapon | DMG | Limb× | Speed | Range | KB | Stun | Sever | Throw Effect |
|--------|-----|-------|-------|-------|----|------|-------|-------------|
| Machete | 20 | ×1.5 | Fast | 45 | 15 | 10% | 25% | Stick + bleed |
| Knife | 10 | ×2.0 | V.Fast | 30 | 5 | 5% | 15% | Pin / stick |
| Axe | 35 | ×1.8 | Slow | 50 | 40 | 40% | 50% | Embed + slow |
| Bat | 18 | ×0.8 | Med | 55 | 60 | 35% | 5% | Bounce ricochet |
| Cult Blade | 28 | ×2.0 | Med | 55 | 20 | 20% | 40% | Blood syphon |

## 5.2 Ranged Weapons

| Weapon | DMG | Limb× | Speed | Range | KB | Stun | Sever | Ammo | Throw Effect |
|--------|-----|-------|-------|-------|----|------|-------|------|-------------|
| Sawed-off | 25×5 | ×1.2 | Med | 120 | 50 | 30% | 15% | 4 | Random discharge |
| Pistol | 15 | ×1.0 | Fast | 350 | 10 | 15% | 10% | 12 | Random shot |
| SMG | 8 | ×0.7 | V.Fast | 250 | 5 | 5% | 3% | 30 | Random spray |
| Shotgun | 20×8 | ×1.5 | Slow | 150 | 70 | 40% | 20% | 6 | Full blast |
| Cult Pistol | 22 | ×1.5 | Med | 400 | 15 | 20% | 25% | 8 | Soul rip |

## 5.3 Improvised Weapons

| Weapon | DMG | Limb× | Speed | Range | KB | Stun | Throw Effect | Durability |
|--------|-----|-------|-------|-------|----|------|-------------|-----------|
| Bottle | 8 | ×0.5 | Fast | 35 | 10 | 30% | Shatter AoE | 1 hit |
| Chair | 15 | ×0.6 | Med | 50 | 45 | 25% | Barricade | 3 hits |
| Severed Limb | 8-12 | ×0.5 | Fast | 35 | 5 | 10% | Demoralize | Infinite |
| Wire | 5+15/s | ×0.3 | Fast | 30 | 0 | Special | Tangle legs | Infinite |
| Cult Relic | 40 | ×3.0 | V.Slow | 60 | 80 | 60% | Reality Tear | 1 use |

---

# 6. WEAPON STRATEGY GUIDE

## 6.1 Role Breakdown

| Role | Best Weapons | Why |
|------|-------------|-----|
| Precision Mutilation | Knife, Cult Blade, Cult Pistol | High limb×, good sever |
| Crowd Control | Bat, Shotgun, Bottle | Knockback + AoE |
| Raw Damage | Axe, Shotgun, Cult Relic | High base damage |
| Space Management | Bat, Chair throw, Wire throw | Control positioning |
| Emergency | Cult Relic, Cult Blade throw | Nuke / heal |
| Stealth | Wire | Silent garrote |
| Desperation | Severed Limb | Always available |
| Long Range | Cult Pistol, Pistol | Reach + accuracy |

## 6.2 Synergy Combos

| Combo | How It Works |
|-------|-------------|
| **Knife → Axe** | Knife для точного limb damage → Axe для guaranteed sever |
| **Bat → Shotgun** | Bat knockback creates distance → Shotgun at perfect range |
| **Bottle throw → Machete** | Bottle stun AoE → Machete slash everyone stunned |
| **Wire throw → Pistol** | Wire tangle legs → Pistol прицельно в конечности |
| **SMG → Knife** | SMG stagger-lock → rush in → Knife для быстрого mutilation |
| **Cult Relic → Cult Blade throw** | Relic AoE damage all limbs → Blade throw для syphon heal |
| **Chair → anything** | Chair throw = barricade → control engagement |

---

# 7. SPAWN & PLACEMENT RULES

## 7.1 Weapon Availability Per Floor

| Weapon | Floor 1 | Floor 2 | Floor 3 | Floor 4 | Floor 5 | Floor 6 | Floor 7 | Floor 8 | Floor 9 |
|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| Machete | Start | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Knife | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Axe | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Bat | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Cult Blade | — | Rare | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Sawed-off | Start | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Pistol | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| SMG | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Shotgun | — | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Cult Pistol | — | — | Rare | Rare | ✓ | ✓ | ✓ | ✓ | ✓ |
| Bottle | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Chair | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Severed Limb | Always | Always | Always | Always | Always | Always | Always | Always | Always |
| Wire | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Cult Relic | — | — | — | Rare | — | Rare | — | Rare | ✓ |

## 7.2 Loot Table Weights

Общие правила:
- Knife, Pistol, Bottle: common (weight 10)
- Machete, Bat, SMG, Wire: uncommon (weight 5)
- Axe, Shotgun, Chair: rare (weight 3)
- Cult Blade, Cult Pistol: very rare (weight 1)
- Cult Relic: ultra rare (weight 0.5, max 1 per floor)

---

# 8. PLAYER STARTING LOADOUT

**Каждый run начинается с:**
- Мачете (slot 1)
- Обрез (slot 2, 4 патрона)

**Это intentional design:**
- Machete = reliable early mutilation
- Sawed-off = emergency burst для tough spots
- 4 shots = enough для early encounters, но не для всего этажа
- Forces player to scavenge immediately
