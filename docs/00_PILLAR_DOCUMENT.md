# PILLAR DOCUMENT — HOTEL

## HIGH CONCEPT

**"The Raid" через призму Hotline Miami в сатанинском люксе.**

Roguelike 2D top-down на 9 этажах. Бессмертные враги. Core mechanic — расчленение как способ управления угрозами. Каждый run — 30-40 минут штурма снизу вверх. Провал — подвальный escape или потеря всего run. Оружие — инструмент и снаряд. Апгрейды — сделки с демонами. Финал — личная встреча с сестрой, которая стала чем-то иным.

---

## THEMATIC PILLARS

### 1. MUTILATION IS MASTERY
Расчленение — не визуальный эффект, а язык взаимодействия с игровым миром. Каждый враг — набор threat-компонентов, которые ты демонтируешь в реальном времени.

### 2. TIME IS YOUR ENEMY
Регенерация врагов создаёт perpetual urgency. Ты никогда не "в безопасности". Нет момента "комната зачищена" — есть "комната под контролем... пока".

### 3. EVERYTHING IS A WEAPON
15 типов оружия. Каждый — melee tool и projectile. Подобрал, использовал, бросил. Импровизация — core skill.

### 4. ASCENSION IS LOSS
Подъём вверх = потеря стабильности. Чем выше — тем surrealer, тем жестче, тем абсурднее. Здание ломает реальность.

### 5. DEALS HAVE PRICES
Культовые артефакты-апгрейды с trade-offs. Каждое улучшение — mini "сделка с дьяволом". Ничего не даётся бесплатно.

---

## ORIGINAL THEMATIC PILLARS (World)

### 1. IMMORTALITY IS PARASITIC
Бессмертие существует только через страдание других.

### 2. LUXURY IS ROTTEN
Богатство должно ощущаться зараженным, больным, демоническим.

### 3. VIOLENCE IS PERFORMANCE
Бой — это визуальная хореография, а не реализм.

### 4. THE BUILDING IS A CHARACTER
Отель должен ощущаться живым организмом.

### 5. ASCENSION IS SUFFERING
Подъем вверх должен ощущаться как descent into hell наоборот.

### 6. THE ELITE ARE MONSTERS
Богатые — буквально чудовища, а не метафора.

### 7. DISMEMBERMENT IS GAMEPLAY
Расчленение — core system, а не просто визуальный эффект.

---

## CORE GAMEPLAY LOOP

```
RUN START (Floor 1)
|
+-> ENTER ROOM
|   |
|   +-> ASSESS: Сколько врагов? Где оружие? Где выход?
|   |
|   +-> ENGAGE: Melee / Ranged / Throw / Environmental
|   |         |
|   |         +-> MUTILATE: Снижай threat через расчленение
|   |         |            (рука = нет оружия, нога = медленнее)
|   |         |
|   |         +-> MANAGE REGEN: Враги восстанавливаются
|   |         |                 -> Ре-калечить или отступить
|   |         |
|   |         +-> SCAVENGE: Подбирай оружие, ищи апгрейды
|   |
|   +-> NAVIGATE: HUB -> ветки комнат -> найти ключ/путь
|   |
|   +-> MINI-BOSS: Уникальная угроза -> победа -> следующий этаж
|
+-> FLOOR TRANSITION (load next floor)
|
+-> [IF HP = 0] -> CAPTURE -> BASEMENT ESCAPE
|                    |- Success -> продолжаешь текущий этаж
|                    +- Fail -> RUN OVER -> restart Floor 1
|
+-> FLOOR 9 -> SISTER -> SATAN -> ENDING
```

---

## KEY DESIGN DECISIONS

| Решение | Выбор | Обоснование |
|---------|-------|-------------|
| Структура | Roguelike, 9 этажей за run (~30-40 мин) | Replayability + mastery-driven |
| Player Character | Жертва, спасающая сестру, мачете + обрез | Emotional anchor + visual contrast |
| Combat Pacing | Гибрид: tight rooms + corridor chase | Natural tension arc |
| Immortal Enemies | Real-time регенерация в бою | Core uniqueness |
| Damage Model | 5 зон: голова, 2 руки, 2 ноги (торс = HP) | Granular but manageable |
| Mutilation Impact | Снижение threat + покупка времени | Tactical, не spatial |
| Weapons | 15 типов, все throwable, разные эффекты | Weapon economy как skill |
| Failure State | Capture -> basement escape -> lose run | Thematic + mechanical |
| Floor Layout | HUB + branches, 10-15 комнат, большие комнаты | Exploration + direction |
| Progression Gate | Мини-босс держит ключ/охраняет выход | Clear objective per floor |
| Upgrades | Статы + культовые артефакты + оружие | Три слоя build variety |
| Basement | 1 layout на все этажи, разные враги | Scope control |
| Run Variation | Random spawn + random loot + route variation + boss variation | Replayability без floor mutations |
| Сестра | Narrative + twist, gameplay element на 9 этаже | Personal stakes |
| Controls | WASD + mouse aim | Precision для throw mechanics |

---

## RUN VARIATION (Replayability Systems)

| Механика | Что меняется | Implementation |
|----------|-------------|----------------|
| Random enemy spawn | Позиции и типы врагов рандомизируются | Spawn point pool + random selection |
| Random loot | Оружие и артефакты в разных местах | Loot table + random placement |
| Route variation | Hub-ветки открываются/закрываются | Gate system per run seed |
| Boss variation | Паттерны мини-боссов меняются | Attack pattern pool + random selection |

---

## FLOOR MAP

| # | Name | Sin | Palette (3-4 цвета) | Key Mechanic | Enemy Focus | Audio Style |
|---|------|-----|---------------------|-------------|-------------|-------------|
| 1 | Service Underground | — | Серый, тусклый зелёный, ржавый | Tutorial, базовый combat | Персонал, охрана | Industrial ambient |
| 2 | Red Light District | Похоть | Красный, розовый, чёрный | Зеркала-декой, отвлечения | Искусители, bodyguards | Synthwave seductive |
| 3 | Banquet Hall | Обжорство | Золотой, бордовый, гнило-зелёный | Ловушки-прессы, скользкий пол | Повара-мясники, tasters | Distorted waltz |
| 4 | Vault | Жадность | Золотой, стальной, тёмно-синий | Сейфы с оружием, механические ловушки | Bankers, security drones | Ticking percussion |
| 5 | Spa | Лень | Бирюзовый, белый, туманный | Замедление, пар как obstacle | Attendants, drowned ones | Droning bass |
| 6 | Arena | Гнев | Красный, ржавый, чёрный | Arena waves, no retreat | Gladiators, berserkers | Metal riffs + rap |
| 7 | Observatory | Зависть | Тёмно-синий, серебряный, фиолетовый | Невидимые враги, stealth zones | Spies, shadow stalkers | Ambient cosmic horror |
| 8 | Ballroom | Гордыня | Золотой, белый, кровавый | Elite AI, coordinated squads | Royal guards, champions | Orchestral + synth |
| 9 | Satan's Sanctum | — | Белый -> чёрный -> red shift | Сестра + Сатана, shifting reality | Demons, the transformed sister | All styles collide |

---

## SCOPE SUMMARY

| Element | Count |
|---------|-------|
| Floors | 9 (handcrafted) |
| Rooms per floor | 10-15 |
| Total rooms | ~100-135 |
| Enemy types | 15-20 |
| Weapon types | 15 |
| Mini-bosses | 9 (mix: enhanced + unique) |
| Upgrades (stats) | ~8-10 |
| Cult artifacts | ~10-12 |
| Basement layout | 1 (shared) |

---

## MVP SCOPE (Vertical Slice)

**Floor 1 — Service Underground**, полностью functional:

- 3 базовых enemy types (персонал, охрана, обработчик)
- 5 weapons (мачете, обрез, нож, бита, пистолет)
- Per-limb damage + real-time regen
- Throwable weapons
- 1 mini-boss
- Basement escape
- Basic upgrades (2-3 stat boosts, 1 cult artifact)
- HUD
- Run start / run end flow

---

## ART & AUDIO DIRECTION

### Visual
- Pixel art, 32x32 tiles, ~640x360 viewport
- Per-floor strict palette (3-4 доминирующих цвета)
- Высокая читаемость gore при среднем pixel resolution

### Audio
- Synthwave/industrial base
- Per-floor уникальный стиль
- Dynamic music (intensifies с combat, затихает в exploration)
- Включает элементы: rap, metal guitar riffs

### Controls
- WASD movement + mouse aim/shoot
