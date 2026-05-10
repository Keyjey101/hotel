# ENEMY DESIGN DOCUMENT — HOTEL
## Version 1.0

---

# 1. OVERVIEW

## 1.1 Enemy Philosophy

Все враги — бессмертные слуги культа. Они продали душу за вечную жизнь. Их нельзя убить — только калечить и временно обездвиживать. Регенерация — в реальном времени, прямо в бою.

**Core design principles:**
- Каждый враг — **читаемая угроза**. Игрок видит силуэт → понимает поведение
- **Калечение = тактика**, не зрелище. Потеря конечности меняет поведение врага
- **Координация** — враги работают вместе, не просто толпой
- **Захват живым** — приоритет для большинства врагов, не убийство
- **Регенерация = clock** — каждый раненый враг — тикающая бомба

## 1.2 Stat Framework

Базовые статы для масштабирования:

| Stat | Описание |
|------|----------|
| Torso HP | Основное здоровье (0 = disabled) |
| Head HP | Здоровье головы (0 = stun + blind) |
| Arm HP (L/R) | Здоровье руки (0 = severed) |
| Leg HP (L/R) | Здоровье ноги (0 = severed) |
| Speed | Скорость передвижения (px/s) |
| Detection | Дальность обнаружения (px) |
| Attack Range | Дальность атаки (px) |
| Attack Speed | Ударов в секунду |
| Grab Strength | Сила захвата (0-10) |
| Regen Speed | Множитель скорости регенерации |
| Aggression | 0-10, насколько агрессивно преследует |
| Coordination | 0-10, насколько координируется с другими |

## 1.3 Damage State Behavior Rules

**Универсальные правила для ВСЕХ врагов:**

| State | Speed | Attack | Behavior |
|-------|-------|--------|----------|
| Healthy | 100% | 100% | Normal AI |
| Head damaged | 100% | 80% | Staggered, blind (reduced detection ×0.3) |
| One arm lost | 90% | 60% (one-handed) | Drops weapon, reduced grab |
| Both arms lost | 70% | 0% melee | Retreats toward severed arm, defensive |
| One leg lost | 50% | 80% | Hops or crawls, more aggressive (cornered) |
| Both legs lost | 15% (crawl) | 60% | Immobile mostly, faster regen (+30%) |
| Arms + legs lost | 5% (writhe) | 0% | Fully disabled, fastest regen (+50%) |
| Torso HP = 0 | 0% | 0% | Collapsed, regen from zero (60-90s full recovery) |

---

# 2. BASE ENEMY TYPES

Базовые типы появляются на нескольких этажах. Вариации через colour tint и minor behavior differences.

---

## 2.1 STAFF (Персонал)

*«Они были первыми. Первыми, кто продал. Теперь они — фундамент.»*

**Архетип:** Слабый, многочисленный, паникующий. Cannon fodder с неожиданной опасностью в группе.

| Stat | Value |
|------|-------|
| Torso HP | 40 |
| Head HP | 15 |
| Arm HP | 12 |
| Leg HP | 14 |
| Speed | 120 px/s |
| Detection | 200 px |
| Attack Range | 40 px (melee) |
| Attack Speed | 1.0/s |
| Grab Strength | 2 |
| Regen Speed | ×1.0 (базовая: 30s/limb) |
| Aggression | 3 |
| Coordination | 2 |

**Визуал:**
- Компактный, сутулый силуэт (22×32 px)
- Униформа: grey/brown, фартук или жилетка
- В руках: поднос, метла, тряпка — импровизированное оружие
- Движется нервно, дёргано
- **Floor tint**: униформа подстраивается под палитру этажа

**Поведение:**
- **Patrol**: Медленно ходит между точками, смотрит по сторонам
- **Alert**: Замирает → кричит (alert nearby в радиусе 250px) → бежит прочь или атакует
- **Chase**: Если в группе (3+) — атакует. Если один — убегает, зовёт помощь
- **Engage**: Слабые удары подносом/метлой. Низкий урон, быстрый swing
- **Mutilated**:
  - Потерял руку: бросает оружие, убегает к ближайшему Guard
  - Потерял ногу: ползёт к выходу из комнаты
  - Потерял всё: лежит, кричит (действует как alert beacon для других)

**Особенность:** Staff в группе 4+ получает бонус courage (+4 Aggression). Толпа персонала = реальная угроза.

**Spawn:** Этажи 1-5 (на более высоких — заменяется на более опасные типы)

---

## 2.2 GUARD (Охрана)

*«Они не полиция. Они — мышцы системы. И у них есть инструкции.»*

**Архетип:** Организованный, тактический. Основной source grab attempts. Работает парами.

| Stat | Value |
|------|-------|
| Torso HP | 70 |
| Head HP | 25 |
| Arm HP | 20 |
| Leg HP | 22 |
| Speed | 140 px/s |
| Detection | 280 px |
| Attack Range | 50 px (melee baton), 200 px (pistol) |
| Attack Speed | 0.8/s melee, 0.5/s ranged |
| Grab Strength | 7 |
| Regen Speed | ×0.9 |
| Aggression | 6 |
| Coordination | 8 |

**Визуал:**
- Широкий, прямоугольный силуэт (28×34 px)
- Форма: тёмная униформа, пояс с экипировкой
- В руках: дубинка (melee) или пистолет (ranged)
- Двигается уверенно, целенаправленно
- Radio на поясе (анимация: подносит к голове при alert)

**Поведение:**
- **Patrol**: Маршруты по 2 (partner system). Один смотрит вперёд, другой назад
- **Alert**: Radio call → alert ALL guards на этаже → занимает позицию
- **Chase**: Flanking pattern — один бежит прямо, другой обходит сбоку
- **Engage**:
  - С дубинкой: подходит, бьёт, отступает, ждёт opening для grab
  - С пистолетом: держит дистанцию, стреляет (low damage, high stun)
  - **Grab attempt**: Подходит вплотную → grab animation → если второй Guard рядом → double grab = capture
- **Mutilated**:
  - Потерял руку: переключается на kick/headbutt, отходит к другому Guard
  - Потерял ногу: занимает позицию, стреляет издалека, координирует других
  - Потерял обе ноги: "command post" — сидит, направляет других (coordination radius +50%)

**Особенность:** Partner system — Guard всегда работает с другим Guard. Если partner убит/калечен — оставшийся становится агрессивнее (+3 Aggression) но менее осторожным.

**Spawn:** Этажи 1-7

---

## 2.3 HANDLER (Обработчик)

*«Они видели столько смертей, что смерть стала профессией. Бессмертие лишь сделало работу проще.»*

**Архетип:** Медленный, но смертельный в grab. Main capture threat. Пугающий.

| Stat | Value |
|------|-------|
| Torso HP | 90 |
| Head HP | 30 |
| Arm HP | 30 |
| Leg HP | 25 |
| Speed | 80 px/s |
| Detection | 180 px |
| Attack Range | 60 px (grab), 45 px (melee) |
| Attack Speed | 0.5/s |
| Grab Strength | 10 (max) |
| Regen Speed | ×0.7 (регенерирует медленнее — массивнее) |
| Aggression | 5 |
| Coordination | 4 |

**Визуал:**
- Крупный, массивный силуэт (30×36 px)
- Тучный, с длинными руками (exaggerated arms — key readability)
- Кровавый фартук поверх формы
- В руках: meat hook или удавка
- Двигается медленно, неотвратимо

**Поведение:**
- **Patrol**: Медленно ходит, волочит инструмент
- **Alert**: Не торопится. Поворачивается, идёт к игроку. Угрожающе
- **Chase**: Не бежит — идёт. Но не отстаёт. Нагоняет пока другие отвлекают
- **Engage**:
  - Meat hook swing: medium range, high damage, pulls player ближе
  - Grab: если вплотную → hold animation → player slowed 70% → нужен break free (3 rapid taps / 1.5s)
  - Если player grabbed + другой враг рядом → drag to basement trigger
- **Mutilated**:
  - Потерял руку: теряет hook, но продолжает grab одной рукой (Grab Strength 6)
  - Потерял обе руки: НО зубами! (Grab Strength 3, bite attack, creepy crawl)
  - Потерял ногу: продолжает идти, хромая. НЕ ОСТАНАВЛИВАЕТСЯ
  - Потерял обе ноги: ползёт к игроку. Самый страшный mutilated state

**Особенность:** Handler — единственный враг, который может solo grab → drag. Даже без рук — пытается укусить/задержать. Это persistent nightmare.

**Spawn:** Этажи 1-6

---

## 2.4 BUTCHER (Мясник)

*«Он не ненавидит тебя. Он просто делает свою работу. Ты — мясо. Он — нож.»*

**Архетип:** Агрессивный melee, fearless. Не хватает — рубит. Pure damage dealer.

| Stat | Value |
|------|-------|
| Torso HP | 80 |
| Head HP | 20 |
| Arm HP | 25 |
| Leg HP | 20 |
| Speed | 100 px/s |
| Detection | 150 px |
| Attack Range | 55 px (cleaver) |
| Attack Speed | 1.2/s |
| Grab Strength | 1 |
| Regen Speed | ×1.1 (быстрее — плоти много) |
| Aggression | 9 |
| Coordination | 2 |

**Визуал:**
- Широкий, мускулистый силуэт (26×34 px)
- Кровавый передник, голые руки (толстые — key readability)
- В руках: большой cleaver или топор
- Двигается тяжело, уверенно

**Поведение:**
- **Patrol**: Стоит на месте, точит нож. Minimal patrol
- **Alert**: Улыбается → бежит прямо к игроку
- **Chase**: Прямая линия, не фланкирует. Через других врагов (friendly fire risk)
- **Engage**: Heavy swings — высокий урон, медленный wind-up (0.4s), широкий arc
  - Cleaver swing: 30 damage, может отрубить player limb (если player HP < 30%)
  - Overhead chop: 40 damage, stun, 0.6s wind-up (telegraphed)
- **Mutilated**:
  - Потерял руку: переключается на kick (15 dmg) и headbutt (20 dmg)
  - Потерял обе руки: charges (бодает головой), 25 dmg, knockback
  - Потерял ногу: продолжает атаковать seated, swing range reduced но damage same
  - Потерял обе ноги: ползёт, bites, 10 dmg, slow но persistent

**Особенность:** Butcher наносит bonus damage по другим врагам (friendly fire = ×1.5). Это gameplay tool — замани Butcher в толпу.

**Spawn:** Этажи 3-8

---

## 2.5 CULTIST (Культнист)

*«Песня вечна. Кровь — нота. Ты — лишь такт.»*

**Архетип:** Ranged support. Стреляет издалека, призывает других, buffs. Приоритетная цель.

| Stat | Value |
|------|-------|
| Torso HP | 50 |
| Head HP | 20 |
| Arm HP | 15 |
| Leg HP | 15 |
| Speed | 90 px/s |
| Detection | 300 px (самый дальний) |
| Attack Range | 350 px (occult bolt) |
| Attack Speed | 0.4/s |
| Grab Strength | 0 |
| Regen Speed | ×1.2 (быстрая — магическая поддержка) |
| Aggression | 4 |
| Coordination | 9 |

**Визуал:**
- Худощавый, высокий силуэт (22×36 px)
- Robe с капюшоном, occult symbols
- В руках: ritual dagger (не использует в бою) + glowing orb/channeling hands
- Glow effect вокруг (aura — key readability)
- Двигается плавно, скользит

**Поведение:**
- **Patrol**: Медленно, задумчиво. Иногда молится (animation)
- **Alert**: Chant → buff all enemies in radius 200px (+20% speed, +20% damage, 8s)
- **Chase**: Держит дистанцию! Бежит AWAY если игрок ближе 100px
- **Engage**:
  - Occult bolt: ranged projectile, 15 dmg, slow but piercing (hits multiple)
  - Buff chant: 2s channel → +20% stats всем врагам в радиусе
  - Alert call: призывает 1-2 Staff/Guard с соседних комнат
- **Mutilated**:
  - Потерял руку: bolt слабее (10 dmg), buff duration halved
  - Потерял обе руки: НО chant через голос! No buff, но持续的 alert screams
  - Потерял ногу: teleports short distance (5s cooldown) — единственный враг с mobility ability
  - Потерял обе ноги: floats (levitation), медленно drifts, продолжает стрелять

**Особенность:** Cultist — highest priority target. Его buffs делают других врагов значительно опаснее. Но он НИКОГДА не grab —纯粹的 support/ranged.

**Spawn:** Этажи 2-9 (на каждом этаже от 1 до 3)

---

# 3. FLOOR-SPECIFIC ENEMY TYPES

---

## 3.1 FLOOR 2 — LUST / Red Light District

### SEDUCTRESS (Искусительница)

*«Ты хочешь остаться. Ты не знаешь почему. Но ты хочешь.»*

**Архетип:** Deception / Decoy. Сбивает с толку, отвлекает, заманивает.

| Stat | Value |
|------|-------|
| Torso HP | 35 |
| Head HP | 15 |
| Arm HP | 10 |
| Leg HP | 10 |
| Speed | 130 px/s |
| Detection | 250 px |
| Attack Range | 30 px (kiss = stun) |
| Attack Speed | 0.6/s |
| Grab Strength | 5 |
| Regen Speed | ×1.3 |
| Aggression | 2 |
| Coordination | 7 |

**Визуал:**
- Элегантный, тонкий силуэт
- Dress, маска, длинные перчатки
- Aura: soft pink glow (отличает от player)
- Двигается грациозно, seductively

**Поведение:**
- **Mirror Decoy**: Создаёт 1-2 иллюзорных копий себя (visual only, no collision). Копии бегают, "атакуют" — player тратит время/оружие на ghost
- **Lure**: Идёт к игроку, не атакуя. Когда рядом → Kiss (stun 1.5s)
- **Retreat**: После stun → убегает к Bodyguard
- **Mutilated**: Decoy ability weakens с каждой потерянной конечностью. Без рук = no decoy. Без ног = no lure.

---

### BODYGUARD (Телохранитель)

*«Её работа — защищать тех, кого нельзя заменить. Твоя работа — через него не пройти.»*

**Архетип:** Defender / Protector. Блокирует путь, защищает приоритетные цели (Seductress, Cultist).

| Stat | Value |
|------|-------|
| Torso HP | 100 |
| Head HP | 30 |
| Arm HP | 28 |
| Leg HP | 28 |
| Speed | 110 px/s |
| Detection | 200 px |
| Attack Range | 45 px (shield bash), 30 px (grab) |
| Attack Speed | 0.7/s |
| Grab Strength | 8 |
| Regen Speed | ×0.8 |
| Aggression | 5 |
| Coordination | 7 |

**Визуал:**
- Крупный, imposing силуэт
- Formal suit, sunglasses
- Shield (portable barrier — key readability)
- Двигается неторопливо, но inexorably

**Поведение:**
- **Shield Block**: Поднимает shield → blocks frontal attacks (melee + projectile). Shield имеет свой HP (60). Broken shield = normal enemy
- **Protect**: Если защищаемый (Seductress/Cultist) получает damage → Bodyguard repositions между ними и игроком
- **Shield Bash**: Bash → knockback 100px + stun 0.5s
- **Grab**: Standard grab, но сильнее с shield (push against wall + pin)
- **Mutilated**: Shield arm lost = no shield. Другая рука = продолжает bash и grab. Legs lost = sits, holds shield up as static barrier.

---

## 3.2 FLOOR 3 — GLUTTONY / Banquet Hall

### CHEF (Шеф-повар)

*«Ты — ингредиент. Он — художник. Ужин подаётся всегда.»*

**Архетип:** Area denial + environmental hazard creator. СТРАШАЙНЫЙ в кухне.

| Stat | Value |
|------|-------|
| Torso HP | 75 |
| Head HP | 25 |
| Arm HP | 22 |
| Leg HP | 20 |
| Speed | 95 px/s |
| Detection | 180 px |
| Attack Range | 50 px (cleaver), 80 px (throw pot) |
| Attack Speed | 0.9/s |
| Grab Strength | 4 |
| Regen Speed | ×1.0 |
| Aggression | 7 |
| Coordination | 5 |

**Визуал:**
- Круглый, массивный силуэт
- Chef hat (tall — key readability), bloody apron
- В руках: giant cleaver + hot pan
- Steam/smell visual around him

**Поведение:**
- **Oil Slick**: Бросает hot oil на пол → скользкая зона (4×4 tiles, 5s). Player и enemies скользят
- **Pan Toss**: Кидает hot pan → AoE splash (20 dmg + burn: 5 dmg/s × 3s)
- **Cleaver Chop**: Heavy melee, 35 dmg, slow
- **Mutilated**: Less oil with one arm. No oil with no arms. Kicks hot things at player.

---

### TASTER (Дегустатор)

*«Он пробует всё. Всё. И теперь его кровь — яд.»*

**Архетип:** Suicide unit. При атаке melee — отравляет игрока. Walking hazard.

| Stat | Value |
|------|-------|
| Torso HP | 45 |
| Head HP | 12 |
| Arm HP | 10 |
| Leg HP | 10 |
| Speed | 150 px/s (быстрый!) |
| Detection | 220 px |
| Attack Range | 35 px |
| Attack Speed | 0.8/s |
| Grab Strength | 3 |
| Regen Speed | ×1.4 (быстрый — маленький) |
| Aggression | 7 |
| Coordination | 3 |

**Визуал:**
- Худой, болезненный силуэт
- Bloated stomach, pale skin, stains on clothes
- В руках: ничего (uses body as weapon)
- Green tint (poisoned — key readability)

**Поведение:**
- **Poison Blood**: Когда player наносит melee урон Taster → splash poison (3 dmg/s × 5s). RANGED = safe
- **Embrace**: Бежит к игроку, обнимает (grab) → poison transfer (8 dmg/s × 4s, MUST break free)
- **Corpse Burst**: Когда torso HP = 0 → взрыв poison cloud (radius 60px, 5s)
- **Mutilated**: Severed limbs → poison pool где лежат (environmental hazard). Full dismemberment = BIG poison pool

---

## 3.3 FLOOR 4 — GREED / Vault

### BANKER (Банкир)

*«Время — деньги. Твоя кровь — collateral. Сделка уже заключена.»*

**Архетип:** Trap activator. Не сражается напрямую — активирует environmental hazards.

| Stat | Value |
|------|-------|
| Torso HP | 50 |
| Head HP | 20 |
| Arm HP | 12 |
| Leg HP | 12 |
| Speed | 100 px/s |
| Detection | 250 px |
| Attack Range | Trigger (200px) |
| Attack Speed | 0.3/s (trap trigger) |
| Grab Strength | 1 |
| Regen Speed | ×1.0 |
| Aggression | 3 |
| Coordination | 9 |

**Визуал:**
- Худой, высокий силуэт
- Sharp suit, pocket watch, slicked hair
- В руках: pocket watch (animation: clicks it = trap trigger)
- Calm demeanour — не паникует никогда

**Поведение:**
- **Trap Master**: Активирует vault traps в радиусе 200px:
  - Spike walls (30 dmg, 0.5s wind-up)
  - Crusher ceilings (50 dmg, 1.0s wind-up, telegraphed)
  - Lockdown doors (close exits, 4s)
- **Evasion**: Высокий dodge chance — постоянно движется, не стоит на месте
- **Summon**: 5s channel → 2 Vault Drones спавнятся рядом
- **Mutilated**: Arms lost = no trap trigger (but can still summon with voice). Legs lost = float mechanism activates (moves anyway).

---

### VAULT DRONE (Дрон хранилища)

*«Механическая эффективность. Никакой души. Нечего отрубать.»*

**Архетип:** Mechanical enemy. NO limbs. Unique damage model.

| Stat | Value |
|------|-------|
| Torso HP | 60 |
| Speed | 160 px/s |
| Detection | 300 px |
| Attack Range | 40 px (shock) |
| Attack Speed | 1.0/s |
| Grab Strength | 0 |
| Regen Speed | Self-repair ×0.5 (very slow) |
| Aggression | 8 |
| Coordination | 6 |

**Визуал:**
- Маленький, круглый (20×20 px)
- Metallic, glowing eye, hovering
 Sparks при damage
- НЕТ КОНЕЧНОСТЕЙ (key readability — явно не человек)

**Поведение:**
- **No Limbs**: Immune to mutilation. Only torso HP. Design exception — mechanical.
- **Shock**: Подлетает вплотную → electric shock (20 dmg + stun 0.8s)
- **Overcharge**: 3s charge → dash attack (40 dmg, knockback, self-damage 15)
- **Swarm**: Спавнится по 2-3, окружает игрока
- **Destroy**: HP = 0 → explodes (small AoE, 15 dmg, sparks)

---

## 3.4 FLOOR 5 — SLOTH / Spa

### ATTENDANT (Служитель спа)

*«Расслабься. Позволь нам позаботиться. Тебе не нужно... двигаться.»*

**Архетип:** Slowing specialist. Делает игрока медленным. Area denial через fog.

| Stat | Value |
|------|-------|
| Torso HP | 55 |
| Head HP | 18 |
| Arm HP | 14 |
| Leg HP | 14 |
| Speed | 70 px/s (медленный) |
| Detection | 200 px |
| Attack Range | 150 px (fog breath), 40 px (touch) |
| Attack Speed | 0.4/s |
| Grab Strength | 5 |
| Regen Speed | ×1.0 |
| Aggression | 2 |
| Coordination | 6 |

**Визуал:**
- Расслабленный, мягкий силуэт
- White spa uniform, towel over arm
- Gentle face, calm expression
- Mist/steam aura вокруг (key readability)

**Поведение:**
- **Fog Breath**: Выдыхает cloud of steam (radius 60px, 4s). Внутри: player speed −40%, visibility reduced (fog overlay)
- **Sedative Touch**: Melee → player speed −30% × 5s (stacks up to −60%)
- **Healing Mist**: Channel 3s → heals all enemies in radius 80px на 15% HP (включая limbs!)
- **Mutilated**: Fog weaker with one arm. No fog without arms. Still slows with touch.

---

### DROWNED ONE (Утопленник)

*«Они утонули в бассейне бессмертия. Теперь воды — их дом. И они голодны.»*

**Архетип:** Ambush predator. Прячется в воде, атакует внезапно.

| Stat | Value |
|------|-------|
| Torso HP | 65 |
| Head HP | 22 |
| Arm HP | 18 |
| Leg HP | 18 |
| Speed | 60 px/s (land), 180 px/s (water) |
| Detection | 150 px (land), 300 px (water — чувствует вибрации) |
| Attack Range | 50 px (grapple from water), 40 px (melee) |
| Attack Speed | 0.6/s |
| Grab Strength | 8 |
| Regen Speed | ×1.5 в воде, ×0.5 на суше |
| Aggression | 6 |
| Coordination | 3 |

**Визуал:**
- Bloated, waterlogged силуэт
- Pale blue-white skin, seaweed in hair
- Dripping water constantly
- В воде: виден только силуэт под поверхностью (ripple effect)

**Поведение:**
- **Ambush**: Скрывается в воде (pool tiles). Invisible until player в radius 80px
- **Grapple**: Выныривает → grab → тянет в воду. Player в воде: speed −60%, drowning damage 5/s
- **Crawl**: На суше — медленный, creepy crawling. В воде — быстрый, deadly
- **Regen**: В воде регенерирует ВТРОЕ быстрее. Выталкивай на сушу!
- **Mutilated**: In water, arms = less grab power. Legs = still swims fast. On land = helpless.

---

## 3.5 FLOOR 6 — WRATH / Arena

### GLADIATOR (Гладиатор)

*«Он ждал тебя. Он ждал кого угодно. Ему просто нужно кого-то убить.»*

**Архетип:** 1v1 duelist. Блокирует проходы. Forced encounter.

| Stat | Value |
|------|-------|
| Torso HP | 110 |
| Head HP | 35 |
| Arm HP | 30 |
| Leg HP | 25 |
| Speed | 130 px/s |
| Detection | 150 px |
| Attack Range | 60 px (spear), 40 px (sword) |
| Attack Speed | 0.7/s |
| Grab Strength | 3 |
| Regen Speed | ×0.9 |
| Aggression | 8 |
| Coordination | 4 |

**Визуал:**
- Мускулистый, высокий силуэт (28×36 px)
- Arena armor (shoulder pads, helmet)
- В руках: spear (long range) или sword + shield
- Stance-based (switches between aggressive and defensive)

**Поведение:**
- **Block Path**: Стоит в узком проходе. Player MUST engage. Cannot bypass
- **Parry**: Блокирует frontal melee attacks (50% chance). Successful parry → counter-attack
- **Spear Thrust**: Long range, 25 dmg, fast
- **Sword Combo**: 3-hit combo (15+20+25 dmg), telegraphed but devastating
- **Mutilated**: Loses weapon arm = switches to kicks + headbutt. Loses shield arm = no parry. Loses legs = continues fighting from ground (upper body still dangerous).

---

### BERSERKER (Берсерк)

*«Боль — это топливо. Кровь — это масло. Он не остановится. НИКОГДА.»*

**Архетип:** Damage = power. Чем больше ранен — тем опаснее. Inverse difficulty.

| Stat | Value |
|------|-------|
| Torso HP | 90 |
| Head HP | 20 |
| Arm HP | 20 |
| Leg HP | 20 |
| Speed | 140 px/s (+30 per missing limb!) |
| Detection | 200 px |
| Attack Range | 45 px |
| Attack Speed | 1.0/s (+0.3 per missing limb!) |
| Grab Strength | 5 (+2 per missing limb!) |
| Regen Speed | ×0.5 (МЕДЛЕННАЯ — боль его питает, не плоть) |
| Aggression | 10 (max) |
| Coordination | 0 (pure rage) |

**Визуал:**
- Дикий, безумный силуэт
- Torn clothes, chains on wrists, scars everywhere
- Red eyes, frothing mouth
- С каждым потерянной конечностью — визуально REDDER, more agitated

**Поведение:**
- **Rage**: КАЖДАЯ потерянная конечность = +30% speed, +30% damage, +0.3 atk speed
- **Full Rage** (0 arms + 0 legs): ПОЛЗЁТ, bites, 40 dmg, fastest enemy in game. Horror moment
- **Charge**: Бежит прямо → tackle (30 dmg + knockback + stun)
- **No Coordination**: Бьёт ВСЁ — включая других врагов (friendly fire ×2.0)
- **Mutilated**: Не ослабляется. УСИЛИВАЕТСЯ. Это key design twist.

**Counter:** Лучший способ — НЕ КАлечить, а снизить torso HP до нуля (collapse). Или заманить во враждебную толпу и пусть дружественный огонь делает работу.

---

## 3.6 FLOOR 7 — ENVY / Observatory

### SPY (Шпион)

*«Ты не видишь его. Но он видит тебя. Всегда.»*

**Архетип:** Stealth assassin. Невидим до атаки.

| Stat | Value |
|------|-------|
| Torso HP | 40 |
| Head HP | 15 |
| Arm HP | 12 |
| Leg HP | 12 |
| Speed | 160 px/s (быстрый!) |
| Detection | 250 px |
| Attack Range | 35 px (backstab) |
| Attack Speed | 0.8/s |
| Grab Strength | 4 |
| Regen Speed | ×1.3 |
| Aggression | 6 |
| Coordination | 5 |

**Визуал:**
- Худой, miniminal силуэт
- Dark form-fitting suit, no visible face
- Partially transparent (key readability — ripple/прозрачность)
- Red eyes glint (only visible hint)

**Поведение:**
- **Invisible**: В patrol/chase — невидим (transparency 90%). Слабое outline + red eye glint
- **Decloak**: При attack → становится видимым (0.3s reveal перед ударом)
- **Backstab**: Если атакует со спины игрока → ×2.5 damage (45 dmg)
- **Hit = Reveal**: Любой урон → visible на 3 секунды
- **Smoke Bomb**: При low HP → дым → teleport на 200px (reposition)
- **Mutilated**: Arms lost = slower attack, no smoke. Legs lost = decloak longer. Full mutilate = fully visible, helpless.

---

### SHADOW STALKER (Теневой охотник)

*«Стены — это рекомендации. Тени — его коридоры.»*

**Архетип:** Phase-walker. Проходит сквозь стены. Нетрадиционный pathing.

| Stat | Value |
|------|-------|
| Torso HP | 60 |
| Head HP | 20 |
| Arm HP | 16 |
| Leg HP | 16 |
| Speed | 120 px/s |
| Detection | 200 px |
| Attack Range | 50 px (shadow claw) |
| Attack Speed | 0.9/s |
| Grab Strength | 6 |
| Regen Speed | ×1.1 |
| Aggression | 7 |
| Coordination | 4 |

**Визуал:**
- Amorphous, flowing силуэт (не вполне человеческий)
- Dark purple-black, wispy edges
- Clawed hands (exaggerated — key readability)
- Двигается как fluid, не как человек

**Поведение:**
- **Phase**: Проходит сквозь стены и мебель (3s cooldown). Не через закрытые двери
- **Shadow Claw**: 20 dmg + 10s "shadow mark" (player outlined, all enemies see through walls)
- **Ambush**: Фазит через стену → appears рядом с игроком
- **Mutilated**: Arms lost = no claws (pushes instead, 5 dmg). Legs lost = phases more often (2s cooldown). Full mutilate = dissolves into puddle, slow regen.

---

## 3.7 FLOOR 8 — PRIDE / Ballroom

### ROYAL GUARD (Королевский гвардеец)

*«Они — элита элиты. Совершенство в жестокости.»*

**Архетип:** Elite Guard — усиленная версия Guard. Formation fighter.

| Stat | Value |
|------|-------|
| Torso HP | 100 |
| Head HP | 30 |
| Arm HP | 28 |
| Leg HP | 28 |
| Speed | 130 px/s |
| Detection | 280 px |
| Attack Range | 55 px (halberd), 250 px (crossbow) |
| Attack Speed | 0.6/s melee, 0.4/s ranged |
| Grab Strength | 7 |
| Regen Speed | ×1.0 |
| Aggression | 7 |
| Coordination | 10 (max) |

**Визуал:**
- Tall, imposing, perfect posture
- Ornate ceremonial armor, gold accents
- Halberd (long polearm) или crossbow
- Двигается строем, синхронно

**Поведение:**
- **Formation**: 2-4 Guards двигаются в formation:
  - Line: блокируют коридор плечом к плечу
  - Wedge: один впереди, двое сзади по бокам
  - Surround: расходятся, окружают игрока
- **Halberd Sweep**: Wide arc (120°), 25 dmg, hits multiple targets
- **Crossbow**: Precise shot, 20 dmg, high stun
- **Shield Wall**: Два Guards → unbreakable front (must flank or throw over)
- **Mutilated**: Formation breaks. One armed = switches to defensive. Legs lost = stays in position as obstacle.

---

### CHAMPION (Чемпион)

*«Один на один. Без правил. Без пощады. Это honour среди монстров.»*

**Архетип:** Elite duelist. Усиленный Gladiator. Сложнейший base enemy.

| Stat | Value |
|------|-------|
| Torso HP | 130 |
| Head HP | 40 |
| Arm HP | 35 |
| Leg HP | 30 |
| Speed | 140 px/s |
| Detection | 180 px |
| Attack Range | 65 px (greatsword) |
| Attack Speed | 0.5/s (heavy but devastating) |
| Grab Strength | 4 |
| Regen Speed | ×1.0 |
| Aggression | 8 |
| Coordination | 6 |

**Визуал:**
- Самый крупный base enemy (30×38 px)
- Full ceremonial plate armor, flowing cape
- Giant greatsword
- Gold/white/red colour scheme (Pride palette)

**Поведение:**
- **Greatsword Combo**: 4-hit combo с increasing damage (15-20-25-35). Last hit = guaranteed limb sever
- **Parry Master**: 70% parry frontal melee. Counter = guaranteed hit
- **Charge**: Rush attack, 40 dmg, armor during charge (damage reduction 50%)
- **Adaptive AI**: Учитывает player behavior. Если player спамит melee → больше parries. Если ranged → закрывает дистанцию быстрее
- **Mutilated**: Even more dangerous. One arm = switches to one-handed sword (faster). One leg = stays put but GREATsword sweeps wider. The most dangerous mutilated enemy.

---

## 3.8 FLOOR 9 — SATAN'S SANCTUM

### DEMON (Демон)

*«Не человек. Никогда не был. Это — чистая форма.»*

**Архетип:** Non-human. No limbs. Pure entity. Final floor only.

| Stat | Value |
|------|-------|
| Torso HP | 120 |
| Speed | 150 px/s |
| Detection | 300 px |
| Attack Range | 80 px (claw), 200 px (dark bolt) |
| Attack Speed | 1.0/s |
| Grab Strength | 0 |
| Regen Speed | ×1.5 |
| Aggression | 9 |
| Coordination | 5 |

**Визуал:**
- Inhuman silhouette (не пропорции человека)
- Tall, thin, elongated limbs, no clear head/body distinction
- Red/black, shifting form
- Glowing eyes, no other facial features

**Поведение:**
- **No Limb Model**: Immune to mutilation. Only torso HP. Different damage system entirely
- **Dark Bolt**: Ranged, 25 dmg, homing (slow, dodgeable)
- **Claw Combo**: Fast 3-hit (15-20-25)
- **Phase**: Briefly disappears → reappears behind player (6s cooldown)
- **Death**: HP = 0 → dissolves into shadow pool → regenerates from pool (45s full)

---

### THE SISTER (Сестра)

*«Ты пришёл за ней. Но она уже не та, кем была. Может, она — больше. Может, она — меньше.»*

**Архетип:** Unique narrative encounter. Не традиционный враг. Подробнее в Boss Design Document.

**Preview:**
- Появляется на Floor 9
- Связана с narrative arc игрока
- Имеет attack patterns, но также "hesitation moments"
- Игрок делает выбор: fight или submit
- Подробнее в Boss Design Document (Task #5)

---

# 4. ENEMY COORDINATION SYSTEM

## 4.1 Role Assignment

Когда несколько врагов в бою, они автоматически принимают роли:

| Role | Behavior | Кто берёт |
|------|----------|-----------|
| FRONTLINE | Идёт прямо к игроку, melee range | Guard, Handler, Butcher, Gladiator, Berserker |
| FLANKER | Обходит сбоку/сзади | Guard, Spy, Shadow Stalker |
| SUPPORT | Держит дистанцию, buffs/shoots | Cultist, Banker, Attendant |
| DEFENDER | Блокирует пути, защищает других | Bodyguard, Royal Guard |
| AMBUSHER | Ждёт момента для surprise | Spy, Shadow Stalker, Drowned One |

## 4.2 Alert Chain

```
Staff (see player) → scream → radius 250px
  ├→ Guard (hear scream) → radio → ALL guards on floor
  ├→ Cultist (hear scream) → chant → buff nearby enemies
  └→ Handler (alerted) → moves toward player slowly

Guard (see player) → radio → ALL guards + alert nearby
  ├→ Other guards reposition (flanking)
  └→ Staff in radius flee to safety

Cultist (sees combat) → buff chant → all enemies in radius stronger
```

## 4.3 Group Compositions Per Floor

| Floor | Typical Group | Size |
|-------|--------------|------|
| 1 | Staff ×3-5 + Guard ×1-2 | 4-7 |
| 2 | Seductress ×1-2 + Bodyguard ×1-2 + Staff ×2-3 | 4-7 |
| 3 | Chef ×1-2 + Taster ×1-2 + Staff ×2 + Guard ×1 | 5-7 |
| 4 | Banker ×1 + Vault Drone ×2-3 + Guard ×2 | 5-6 |
| 5 | Attendant ×2-3 + Drowned One ×1-2 + Staff ×2 | 5-7 |
| 6 | Gladiator ×1-2 + Berserker ×1-2 + Butcher ×2 | 4-5 |
| 7 | Spy ×2 + Shadow Stalker ×1-2 + Cultist ×1 | 4-5 |
| 8 | Royal Guard ×2-4 + Champion ×1 + Cultist ×1 | 4-6 |
| 9 | Demon ×2-3 + unique encounters | 2-4 |

---

# 5. DIFFICULTY SCALING

## 5.1 Per-Floor Scaling

| Floor | Enemy HP Mult | Enemy Speed Mult | Regen Speed Mult | Aggression Mult |
|-------|--------------|-----------------|-----------------|----------------|
| 1 | ×1.0 | ×1.0 | ×1.0 | ×1.0 |
| 2 | ×1.0 | ×1.05 | ×1.0 | ×1.1 |
| 3 | ×1.1 | ×1.05 | ×1.05 | ×1.1 |
| 4 | ×1.1 | ×1.1 | ×1.05 | ×1.15 |
| 5 | ×1.15 | ×1.1 | ×1.1 | ×1.15 |
| 6 | ×1.2 | ×1.15 | ×1.15 | ×1.25 |
| 7 | ×1.25 | ×1.15 | ×1.15 | ×1.25 |
| 8 | ×1.3 | ×1.2 | ×1.2 | ×1.3 |
| 9 | ×1.5 | ×1.3 | ×1.3 | ×1.5 |

## 5.2 In-Run Scaling

В пределах одного run:
- Каждый пройденный этаж: +5% enemy stats на следующих этажах
- Это НЕ бесконечный scaling — max bonus = +40% (8 floors completed)
- Encourages efficient play: less damage taken = easier later floors

---

# 6. SPRITE PRODUCTION SUMMARY

| Enemy Type | Unique Frames | 5 Directions | Mutilation Variants | Total Frames | Priority |
|-----------|--------------|--------------|---------------------|-------------|----------|
| Staff | ~15 | 75 | ~40 | ~115 | MVP |
| Guard | ~18 | 90 | ~50 | ~140 | MVP |
| Handler | ~16 | 80 | ~50 | ~130 | MVP |
| Butcher | ~16 | 80 | ~45 | ~125 | High |
| Cultist | ~18 | 90 | ~45 | ~135 | High |
| Seductress | ~20 | 100 | ~40 | ~140 | Medium |
| Bodyguard | ~18 | 90 | ~45 | ~135 | Medium |
| Chef | ~18 | 90 | ~40 | ~130 | Medium |
| Taster | ~14 | 70 | ~35 | ~105 | Medium |
| Banker | ~14 | 70 | ~35 | ~105 | Medium |
| Vault Drone | ~10 | 50 | 0 (no limbs) | ~50 | Medium |
| Attendant | ~16 | 80 | ~40 | ~120 | Medium |
| Drowned One | ~18 | 90 | ~45 | ~135 | Medium |
| Gladiator | ~20 | 100 | ~50 | ~150 | Low |
| Berserker | ~16 | 80 | ~50 | ~130 | Low |
| Spy | ~16 | 80 | ~40 | ~120 | Low |
| Shadow Stalker | ~18 | 90 | ~40 | ~130 | Low |
| Royal Guard | ~20 | 100 | ~50 | ~150 | Low |
| Champion | ~22 | 110 | ~55 | ~165 | Low |
| Demon | ~14 | 70 | 0 (no limbs) | ~70 | Low |

**Total: ~2,315 frames for all 20 enemy types**

**MVP (3 types): ~385 frames**
**Full game: ~2,315 frames**

---

# 7. ENEMY TYPE COUNT SUMMARY

| Category | Count | Types |
|----------|-------|-------|
| Base (multi-floor) | 5 | Staff, Guard, Handler, Butcher, Cultist |
| Floor 2 (Lust) | 2 | Seductress, Bodyguard |
| Floor 3 (Gluttony) | 2 | Chef, Taster |
| Floor 4 (Greed) | 2 | Banker, Vault Drone |
| Floor 5 (Sloth) | 2 | Attendant, Drowned One |
| Floor 6 (Wrath) | 2 | Gladiator, Berserker |
| Floor 7 (Envy) | 2 | Spy, Shadow Stalker |
| Floor 8 (Pride) | 2 | Royal Guard, Champion |
| Floor 9 (Sanctum) | 2 | Demon, The Sister |
| **TOTAL** | **21** | |
