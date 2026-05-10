# GAME DESIGN DOCUMENT — HOTEL
## Version 0.1 — First Draft

---

# 1. OVERVIEW

## 1.1 High Concept

2D top-down pixel art roguelike. Игрок штурмует 9-этажный отель-культ сатаны снизу вверх, сражаясь с бессмертными врагами через систему расчленения. Каждый run — 30-40 минут. Проигрыш = сначала. Оружие — инструмент и снаряд. Апгрейды — сделки с демонами.

## 1.2 Genre

- Top-down 2D action
- Roguelike (handcrafted levels, per-run progression)
- Mutilation-focused combat

## 1.3 Inspirations

- Hotline Miami (pacing, weapon economy, pixel art violence)
- The Raid (vertical assault, escalating floors)
- John Wick (stylized violence, choreography)
- Hades (roguelike structure, run variety)
- They Will Kill You (tonal reference, wealth horror)

## 1.4 Target Platform

- PC (primary)
- Engine: Godot 4.x

## 1.5 Target Audience

- Fans of Hotline Miami, ruiner, Crimson Desert
- Roguelike enthusiasts
- Players seeking high-skill-ceiling combat
- Streamer-friendly content (visually striking, "clip-worthy" moments)

---

# 2. GAMEPLAY

## 2.1 Core Loop

```
RUN START -> FLOOR -> ROOMS -> MINI-BOSS -> NEXT FLOOR -> ... -> FLOOR 9 -> ENDING
                                    |
                              [HP = 0] -> BASEMENT -> ESCAPE or RUN OVER
```

Каждый run:
1. Игрок начинает на Floor 1 (Service Underground)
2. Проходит комнаты этажа, сражаясь с бессмертными врагами
3. Находит оружие, апгрейды, культовые артефакты
4. Побеждает мини-босса -> открывает путь наверх
5. Переходит на следующий этаж
6. При потере HP -> capture -> basement escape
7. Успешный escape -> продолжение текущего этажа
8. Провал escape -> run over, restart с Floor 1

## 2.2 Combat System

### 2.2.1 Damage Model

Враги имеют 5 damage zones:
- **Голова** (head) — отдельный HP
- **Левая рука** (left arm)
- **Правая рука** (right arm)
- **Левая нога** (left leg)
- **Правая нога** (right leg)
- **Торс** — основной HP pool

### 2.2.2 Mutilation Effects

| Damage | Effect |
|--------|--------|
| Потеря одной руки | Теряет оружие, снижается grab chance |
| Потеря обеих рук | Ползёт к отрубленной руке, не может grab/attack |
| Потеря одной ноги | Прыгает на одной или ползёт, пытается задержать/ранить |
| Потеря обеих ног | Обездвижен, атакует издалека если есть ranged, регенерирует быстрее |
| Полное расчленение | Disabled, даёт максимальное время до регенерации |

### 2.2.3 Regeneration System

- Все враги регенерируют в реальном времени
- Регенерация ВИДИМА: плоть нарастает анимированно
- Скорость регенерации: baseline ~30 секунд на конечность
- Чем больше урона — тем дольше полная регенерация
- Полностью расчленённый враг: ~60-90 секунд до полного восстановления
- Регенерация暂停s пока враг получает урон (reset timer)

### 2.2.4 Combat Pacing

**Гибридный режим:**
- Отдельные комнаты = tight encounters (3-8 врагов)
- Коридоры = pressure zones (враги преследуют из room в room)
- Большие залы = extended encounters (5-10 врагов, multiple engagement zones)

### 2.2.5 Player Mechanics

- **Melee attack** — направленный удар ближайшим оружием
- **Ranged attack** — стрельба из огнестрельного оружия (mouse aim)
- **Throw weapon** — ЛЮБОЕ оружие можно бросить (different effect per weapon)
- **Pick up** — подобрать оружие с пола / отнять у врага
- **Interact** — открыть дверь, активировать ловушку, открыть сейф
- **Dodge/roll** — quick evasion (if upgrade allows)

## 2.3 Weapon System

### 2.3.1 Weapon Categories

**Melee:**
1. Мачете — средний урон, быстрый swing, отсекает конечности
2. Нож — быстрый, низкий урон, высокий bleed
3. Топор — медленный, высокий урон, guaranteed limb sever
4. Бита — средний, knockback, stun chance
5. Меч (cult weapon) — редкий, высокий урон, special effect

**Ranged:**
6. Обрез — близкая дистанция, высокий урон, spread
7. Пистолет — средний урон, точный, быстрый
8. SMG — быстрый fire rate, низкий урон per hit
9. Дробовик — высокий урон, близкая дистанция, knockback
10. Культовый пистолет — редкий, piercing, special effect

**Improvised:**
11. Бутылка — бросок = stun, melee = разбивается = нож
12. Стул — knockback, разрушается после N ударов
13. Отрубленная конечность — бросок = stun, melee = слабый
14. Провод — garrote, slow, high damage если timed
15. Культовый артефакт-оружие — rare, unique effect

### 2.3.2 Throw Mechanics

Каждое оружие при броске:
- **Мачете** → spinning slash, medium damage, может отрубить на лету
- **Нож** → быстрый, точный, low damage, bleed
- **Топор** → медленный, arc trajectory, high damage, stun
- **Бита** → medium arc, knockback
- **Обрез** → роняет как blunt object, может discharge на impact
- **Пистолет** → blunt hit, может discharge
- **Бутылка** → разбивается, AoE stun
- **Конечность** → blunt hit, gore effect

(полный throw table для всех 15 — в отдельном баланс-документе)

### 2.3.3 Weapon Durability

Нет durability. Оружие не ломается (кроме improvised). Но:
- Оружие выпадает из рук при grab/stun
- Огнестрел имеет ammo (ограниченные патроны)
- Melee — безлимитное использование

## 2.4 Enemy System

### 2.4.1 Enemy Archetypes (15-20 total)

**Base Types (перекрёстно используются на нескольких этажах):**

| Type | Role | Behavior |
|------|------|----------|
| Staff (персонал) | Weak, numerous | Бегут, предупреждают других, armed импровизированным |
| Guard (охрана) | Stronger, organized | Патрулируют, coordinate, try to grab |
| Handler (обработчик) | Slow, deadly in grab | Идут к игроку, grab = capture attempt |
| Butcher (мясник) | Aggressive melee | Бесстрашные, сильные, но медленные |
| Cultist (культнист) | Ranged support | Стреляют издалека, призывают других |

**Unique Types (поэтажные):**

| Floor | Unique Enemies |
|-------|---------------|
| 2 | Seductress (отвлекает, decoy), Bodyguard (защищает приоритетные цели) |
| 3 | Chef (area denial, traps food), Taster (poisoned blood, damages on melee) |
| 4 | Banker (activates traps), Vault Drone (mechanical, no limbs) |
| 5 | Attendant (slows player), Drowned One (emerges from pools) |
| 6 | Gladiator (1v1 focus, blocks paths), Berserker (gets stronger when damaged) |
| 7 | Spy (invisible, backstab), Shadow Stalker (phases through walls) |
| 8 | Royal Guard (coordinated formations), Champion (elite variant) |
| 9 | Demon (no limbs, pure entity), The Sister (unique mechanics) |

### 2.4.2 Enemy AI

**Base Behavior:**
- Patrol → Alert → Chase → Engage → Mutilated state behavior
- Enemies communicate: видят игрока → alert nearby
- Coordination: guards flank, handlers push front, cultists support

**Damage State Behavior:**
- Full health: normal behavior
- Missing arm: drops weapon, reduced effectiveness
- Missing both arms: retreats toward arm, defensive
- Missing leg: slowed, more aggressive (cornered)
- Missing both legs: immobile, ranged if possible, faster regen
- Heavily mutilated: desperately aggressive or retreats

**Capture Priority:**
- Enemies prefer capture over kill
- Grab mechanics: 2+ enemies needed for capture attempt
- Single grab: slows player, deals damage, player can break free

### 2.4.3 Mini-Bosses

| Floor | Mini-Boss | Type | Mechanic |
|-------|-----------|------|----------|
| 1 | Head Chef | Enhanced | Cleaver sweep + charge, heavy armor |
| 2 | Madame | Unique | Mirror clones, teleport between reflections |
| 3 | The Gourmand | Unique | Eats corpses to heal, grows larger |
| 4 | The Accountant | Enhanced | Triggers vault traps, summons security |
| 5 | The Attendant Prime | Unique | Controls steam, invisibility in fog |
| 6 | The Champion | Unique | Arena boss, wave-based, gets stronger each wave |
| 7 | The Curator | Unique | Phases invisible, steals player weapons |
| 8 | The Consort | Unique | Coordinates 4 royal guards simultaneously |
| 9 | The Sister | Unique | Personal encounter, emotional + combat |
| 9 | Satan | Unique | Final boss, reality warping |

## 2.5 Progression System

### 2.5.1 Per-Run Upgrades

**Stat Upgrades (найти на этажах):**
- +25% HP
- +15% speed
- +20% melee damage
- +20% throw damage
- +10% fire rate
- Reduced grab vulnerability
- Faster interaction speed
- Extended dodge frames

**Cult Artifacts (trade-offs):**

| Artifact | Bonus | Cost |
|----------|-------|------|
| Demon Eye | +30% ranged damage | -20% melee damage |
| Blood Pact | +50% HP | Enemy regen +30% faster |
| Iron Will | Cannot be grabbed | -25% movement speed |
| Hunger Blade | Melee heals on hit | -1 max weapon slots |
| Shadow Step | +1 dash charge | -40% throw distance |
| Golden Hand | Double upgrade pickups | Halved ammo for all guns |
| Ring of Wrath | +50% damage to full-health enemies | -50% damage to damaged enemies |
| Pact of Flesh | Enemies drop limbs as weapons | Player HP drains slowly |
| Third Eye | See enemy aggro range | Screen occasionally glitches |
| Demon Heart | Second chance on death (once per run) | All enemies have +1 HP per limb |

**Weapon Upgrades:**
- Find better versions of weapons on higher floors
- Cult weapons: unique, powerful, found rarely

### 2.5.2 Player Stats

Base player stats:
- HP: 100
- Speed: base movement speed
- Weapon slots: 2 (can carry 2 weapons simultaneously)
- Throw speed: baseline
- Interaction speed: baseline

## 2.6 Floor Structure

### 2.6.1 Layout Logic

Каждый этаж:
- **HUB area** — центральная зона, несколько выходов
- **Branch rooms** — ветки от HUB, содержат loot, enemies, environmental storytelling
- **Critical path** — minimum rooms to reach mini-boss
- **Optional rooms** — extra loot/risk
- **Mini-boss arena** — финальная комната этажа

Route variation между runs:
- Gate system: двери в HUB открываются/закрываются per run seed
- Каждый run открывает 60-70% веток, остальные закрыты
- Forced exploration: key к mini-boss always в optional branch

### 2.6.2 Room Scale

- Большие комнаты, не помещаются на один экран
- Camera follow player, scrolling
- Multiple engagement zones per room
- Entry points: двери, проходы, лифты
- Environmental elements: укрытия, ловушки, destructibles

## 2.7 Basement Escape

### 2.7.1 Structure

- ONE layout для всех этажей
- Другие enemies на каждом этаже (floor-themed enemies)
- Начинаешь без оружия (или с 1 random melee)
- Цель: добраться до exit
- Exit ведёт обратно на текущий этаж (checkpoint: начало этажа)

### 2.7.2 Difficulty Escalation

- Floor 1-3: basement = manageable, few enemies
- Floor 4-6: basement = challenging, more enemies, environmental hazards
- Floor 7-9: basement = brutal, elite enemies, complex layout adaptation

### 2.7.3 Failure

- Не смог выбраться = run over
- Restart с Floor 1

## 2.8 Run Variation Systems

### 2.8.1 Random Enemy Spawning
- Каждый room имеет spawn point pool (8-12 точек)
- Run seed определяет: какие точки активны, какие типы врагов
- Difficulty scaling: больше/сильнее enemies на поздних этажах

### 2.8.2 Random Loot Placement
- Loot tables per floor
- Weapons, stat upgrades, cult artifacts
- Random positions within designated loot zones
- Guaranteed minimum loot per floor

### 2.8.3 Route Variation
- Hub gate system controlled by run seed
- Different branches accessible each run
- Forces different exploration paths
- Mini-boss key location varies

### 2.8.4 Boss Variation
- Mini-boss attack patterns drawn from pattern pool
- 3-5 pattern sets per boss
- Random selection per run
- Keeps bosses unpredictable across runs

---

# 3. PLAYER CHARACTER

## 3.1 Identity

- Жертва, пришедшая спасти сестру
- Знала что-то неладное, пришла подготовленной (мачете, обрез)
- Не бессмертна — при потере HP -> capture attempt
- Никакой supernatural силы — только skill и determination

## 3.2 Motivation

- Сестра пропала в отеле
- Главный герой подозревал культ
- Пришёл/пришла добровольно, knowing the risk
- Emotional driver: family, not heroism

## 3.3 Starting Loadout

- Мачете (melee, infinite use)
- Обрез (ranged, limited ammo: 4 shots)

---

# 4. WORLD & NARRATIVE

## 4.1 Setting

Отель — автономная карманная реальность:
- Закрытая экосистема
- Вертикальная иерархия
- Каждый этаж обслуживает верхние
- Кровь = валюта, насилие = ритуал, культ = социальный контракт

## 4.2 The Sister

- Пропала в отеле
- Была "приглашена" как гость или "набрана" как персонал
- Floor 9: reveal — она изменилась
  - Стала частью системы
  - Или стала чем-то большим/иным
  - Gameplay encounter: не просто кат-сцена
- Концовка зависит от решения игрока

## 4.3 Environmental Storytelling

- Без кат-сцен — всё через окружение
- Записки, diary entries, ritual notes
- Визуальные hints о природе культа
- Этажи рассказывают историю exploitation chain
- Подвал показывает "изнанку" каждого этажа

## 4.4 Demonic as Administrative

- Демоны — не мистические существа, а бюрократы
- Сатана — CEO, не мистический владыка
- Ритуалы — corporate procedures
- Бессмертие — subscription service за чужие жизни

---

# 5. ART DIRECTION

## 5.1 Technical Specs

- Pixel art, 32x32 tiles
- Viewport: ~640x360
- Characters: ~32x32 to 48x48 pixels
- Per-floor strict color palette (3-4 dominant colors)

## 5.2 Visual Style

- Violent baroque meets pixel art
- Satanic art deco
- Luxury vs. decay contrast
- Gold + blood, marble + meat
- Psychedelic neon horror elements
- Comic-book exaggeration

## 5.3 Gore System

- Per-limb damage визуализирован
- Animated regeneration (flesh growing back)
- Blood pools persistent in rooms
- Dismembered limbs as physical objects
- Readability priority: gore should be FUNCTIONAL (visual feedback on enemy state)

## 5.4 UI

- Minimal HUD: HP bar, weapon slots, ammo
- Floor indicator
- No minimap (exploration is intentional)
- Damage direction indicators
- Upgrade icons when active

---

# 6. AUDIO DIRECTION

## 6.1 Music

- Base: synthwave/industrial
- Per-floor unique genre/style
- Dynamic: intensifies during combat, ambient during exploration
- Elements: rap vocals, metal guitar riffs, synth layers
- Floor 9: all styles layered and colliding

## 6.2 Sound Design

- Weapon impacts: crunchy, satisfying, distinct per weapon
- Mutilation: wet, visceral but not gratuitous — functional audio cues
- Regeneration: unsettling organic sound (flesh knitting)
- Enemy audio cues: each type has distinct sound signature
- Environmental: building ambience (pipes, machinery, distant screams)

---

# 7. CONTROLS

| Action | Input |
|--------|-------|
| Move | WASD |
| Aim | Mouse |
| Melee attack | Left click (with melee equipped) |
| Shoot | Left click (with ranged equipped) |
| Throw weapon | Right click |
| Pick up weapon | E |
| Interact | E (context-sensitive) |
| Dodge/roll | Space (if upgrade) |
| Switch weapon | Q or scroll wheel |

---

# 8. TECHNICAL NOTES

## 8.1 Engine

- Godot 4.x
- GDScript primary
- Potential GDExtension for performance-critical systems (gore, particles)

## 8.2 Performance Targets

- 60 FPS stable
- Max 10 active enemies on screen
- Pixel art = low GPU load, CPU budget for AI + gore

## 8.3 Key Systems

- Finite State Machine (enemy AI)
- Damage zone system (per-limb tracking)
- Regeneration timer system
- Weapon pickup/throw system
- Room transition system
- Run state manager
- Seed-based randomization system
- Camera system (large rooms, scrolling)
- Destructible environment system
- Gore/particle system
- Save system (run state only — roguelike)

---

# 9. PRODUCTION SCOPE

## 9.1 MVP / Vertical Slice

**Floor 1 — Service Underground:**
- 3 enemy types (Staff, Guard, Handler)
- 5 weapons (Machete, Sawed-off, Knife, Bat, Pistol)
- Per-limb damage + real-time regen
- Throwable weapons
- 1 mini-boss (Head Chef)
- Basement escape
- 2-3 stat upgrades, 1 cult artifact
- Basic HUD
- Run start/end flow
- ~8-10 rooms

## 9.2 Milestones

1. **M1: Combat Prototype** — player, 1 enemy, melee + regen
2. **M2: Weapon System** — 5 weapons, throw mechanics
3. **M3: Floor 1 Alpha** — full floor, all enemies, mini-boss
4. **M4: Run Systems** — basement, run start/end, randomization
5. **M5: Vertical Slice** — Floor 1 polished, all systems working
6. **M6: Floor 2-3** — expand content, prove scalability
7. **M7: Full Game** — all 9 floors, all content
8. **M8: Polish** — audio, VFX, balance, performance
