_# ПЛАН: Roadmap разработки HOTEL с техниками агентного промптинга

## Context

Проект HOTEL — 2D top-down pixel art roguelike на Godot 4. Вся документация (15 файлов) создана,
архитектура Godot 4 заложена (~25 GDScript файлов, ~70 тестов). Текущий статус: M1 Combat Prototype
в процессе. Всё дальнейшее развитие ведётся через агентные системы (Claude Code / подобные).

Цель этого плана: зафиксировать найденные несоответствия между документами, затем дать пошаговый
roadmap с конкретными техниками промптинга для агентных систем.

---

## ЧАСТЬ 1: НАЙДЕННЫЕ НЕСООТВЕТСТВИЯ В ДОКУМЕНТАХ

### 1.1 Критические расхождения в числах

| Параметр | 00_PILLAR | 01_GDD | Детальный документ | Код |
|----------|-----------|--------|-------------------|-----|
| Mini-bosses | **9** | 10 (явно в таблице) | 14_BOSS_DESIGN: **10** | — |
| Enemy types | 15-20 | 15-20 | 11_ENEMY_DESIGN: **21** | base_enemy only |
| Stat upgrades | ~8-10 | **8** (перечислено) | 15_UPGRADE_DESIGN: **11** | RunState: stat keys |
| Cult artifacts | ~10-12 | **10** (перечислено) | 15_UPGRADE_DESIGN: **12** | — |
| Total rooms | **~100-135** | — | 13_FLOOR_DESIGN: **~88** | — |
| Damage zones | "5 зон" | **6** в таблице | TDD: 6 | DamageZone: **6** |

### 1.2 Структурные несоответствия

- **Damage zones**: PILLAR пишет "5 зон: голова, 2 руки, 2 ноги (торс = HP)" — путаница в счёте.
  GDD, TDD и код единогласны: 6 зон (head + 4 limbs + torso). Торс — отдельная зона с HP.
  Pillar надо поправить: "6 зон".

- **Dodge/roll**: GDD упоминает "Dodge/roll — quick evasion (if upgrade allows)", Space — keybind.
  В 15_UPGRADE_DESIGN.md нет апгрейда разблокирующего dodge. Либо апгрейд надо добавить
  (Extended Dodge Frames есть в GDD), либо убрать механику из controls.

- **Path к проекту**: 00_PROGRESS.md ссылается на `/home/kj/hotel/` — реальный путь `/home/kj/hotel/`.
  Нужно обновить PROGRESS.md.

- **Weapon "Cult Blade" vs "Cult Sword"**: PILLAR и GDD называют культовое melee оружие по-разному
  (GDD: "Меч cult weapon", 12_WEAPON_DESIGN: "Cult Blade"). Название надо унифицировать.

- **Mini-boss count**: PILLAR говорит 9, но Sister + Satan на Floor 9 — это 2 боса на одном этаже.
  Итого = 10 (как в GDD и BOSS_DESIGN). PILLAR надо поправить: 9 → 10.

### 1.3 Несоответствия кода и документов

- **Enemy subtypes**: Документы описывают 3 базовых типа (Staff, Guard, Handler) для MVP,
  но в коде только `base_enemy.gd` — нет subtype сцен. Это плановый TODO, не баг.

- **5 оружий в .tres**: Созданы knife, bat, machete, pistol, sawed_off — соответствует MVP scope.
  Но `melee_axe.tres`, `melee_cultblade.tres` и improviseds отсутствуют. Норма для M1.

- **GoreSystem не autoload**: PROGRESS.md фиксирует это как известную проблему.
  Надо либо сделать autoload, либо явно указать где прикреплять.

---

## ЧАСТЬ 2: ROADMAP РАЗРАБОТКИ С ТЕХНИКАМИ АГЕНТНОГО ПРОМПТИНГА

### Принципы агентного промптинга для этого проекта

**P1. Контекст-пакет** — каждый промпт агенту начинается с минимального набора релевантных документов.
**P2. Файл-первый** — всегда читать существующий код перед написанием нового.
**P3. Тест-якорь** — каждая новая фича сопровождается тестом или ручной инструкцией проверки.
**P4. Ограниченный scope** — один промпт = одна задача из production plan, не несколько.
**P5. Конкретные пути** — всегда указывать точные пути файлов, не говорить "создай систему X".
**P6. Godot-контракт** — явно указывать Godot 4 API, тип ноды, сигналы которые надо использовать.
**P7. Верификация** — в конце промпта просить сверить результат с документом-источником.

---

### ШАГ 0: ИСПРАВЛЕНИЕ НЕСООТВЕТСТВИЙ ДОКУМЕНТОВ

**Цель**: Привести документацию к единому состоянию перед разработкой.

**Промпт-шаблон:**
```
Контекст: проект HOTEL, Godot 4 roguelike, папка /home/kj/hotel/
Документы источники: [перечислить конкретные файлы]

Задача: Внеси точечные правки в следующие документы:
1. /home/kj/hotel/docs/00_PILLAR_DOCUMENT.md:
   - Раздел "SCOPE SUMMARY": Mini-bosses: 9 → 10 (The Sister + Satan = 2 на Floor 9)
   - Раздел "KEY DESIGN DECISIONS": "5 зон" → "6 зон (голова, 2 руки, 2 ноги, торс)"
2. /home/kj/hotel/docs/00_PROGRESS.md:
   - Замени все вхождения /home/kj/ на /home/user/

Не переписывай другие части. Только указанные строки.
После правки выведи diff изменений для проверки.
```

---

### ШАГ 1: M1 — COMBAT PROTOTYPE (Текущий)

**Цель**: Игрок двигается, атакует врага, наносит урон по конечностям, враг регенерирует.

#### 1.1 Placeholder спрайты и тестовая комната

**Промпт:**
```
Контекст: Godot 4 проект /home/kj/hotel/project/
Прочитай: scenes/test/test_room.tscn, scripts/player/player_controller.gd,
          scripts/ai/base_enemy.gd

Задача: Создай минимальный визуальный прототип:
1. Добавь в player.tscn узел ColorRect 24x36px, цвет #00FF00 (зелёный) как placeholder спрайт
2. Добавь в base_enemy.tscn узел ColorRect 24x36px, цвет #FF0000 (красный)
3. В test_room.tscn добавь TileMapLayer с простым TileSet (32x32):
   - tile_floor: #333333
   - tile_wall: #666666
   - Размер комнаты: 20x15 тайлов, стены по периметру
4. Добавь NavigationRegion2D охватывающий floor area

Используй Godot 4 API. Не меняй GDScript логику — только сцены.
Проверь что player_controller.gd не требует реального спрайта для работы.
```

#### 1.2 Тест combat pipeline

**Промпт:**
```
Контекст: Godot 4, /home/kj/hotel/project/
Прочитай: scripts/combat/melee_hit.gd, scripts/combat/damage_zones.gd,
          scripts/ai/base_enemy.gd (особенно метод take_damage и _regen_process)

Задача: Убедись что melee pipeline работает в test_room:
1. Открой scenes/test/test_room.tscn
2. Добавь 1 экземпляр base_enemy.tscn в позицию (320, 180)
3. Добавь 1 экземпляр player.tscn в позицию (100, 180)
4. Запусти сцену, проверь:
   - Игрок двигается WASD ✓
   - ЛКМ создаёт melee hitbox ✓
   - Hitbox попадает во врага → take_damage вызывается ✓
   - HP конечности уменьшается ✓
   - После 30с начинается регенерация ✓

Если что-то не работает — читай конкретный скрипт и чини ТОЛЬКО проблемную часть.
Выведи список: что работает ✓, что сломано ✗, что исправил.
```

#### 1.3 Запуск тестов

**Промпт:**
```
Выполни: godot --headless --script res://scripts/tests/test_runner.gd
из папки /home/kj/hotel/project/

Если тесты падают — прочитай failing test, найди причину в соответствующем скрипте,
исправь только то что сломано. Не рефакторь проходящие тесты.
Выведи итог: N passed, M failed, список failed с причинами.
```

---

### ШАГ 2: M2 — WEAPON SYSTEM

**Цель**: 5 оружий MVP полностью функциональны, броски работают.

**Документы-источники**: `12_WEAPON_DESIGN.md` (stats таблица), `scripts/combat/weapon_manager.gd`,
`scripts/combat/thrown_weapon.gd`, `resources/weapons/`

#### 2.1 Оставшиеся 3 .tres ресурса оружий (Axe отсутствует в MVP — нужен для Floor 2)

**Промпт:**
```
Прочитай: resources/weapons/weapon_data.gd, resources/weapons/melee_machete.tres,
          docs/12_WEAPON_DESIGN.md (секция Machete и Knife для понимания формата)

В 12_WEAPON_DESIGN.md найди точные stats для:
- Axe (melee): damage, attack_speed, sever_chance, stun_chance, throw arc
- SMG (ranged): ammo, fire_rate, spread, damage
- Cult Blade (melee): damage, special effects

Создай .tres файлы по аналогии с machete:
- resources/weapons/melee_axe.tres
- resources/weapons/ranged_smg.tres
- resources/weapons/melee_cultblade.tres

Строго используй значения из 12_WEAPON_DESIGN.md, не придумывай балансные цифры.
```

#### 2.2 Weapon pickup сцена

**Промпт:**
```
Прочитай: scripts/player/player_controller.gd (метод _try_pickup_weapon),
          scripts/combat/weapon_manager.gd, docs/01_GDD.md (секция 2.2.5 Player Mechanics)

Создай сцену scenes/weapons/weapon_pickup.tscn:
- Корень: Area2D (collision layer 8: throwable)
- Дочерний: Sprite2D (placeholder: ColorRect 16x8px, цвет #FFFF00)
- Дочерний: CollisionShape2D (RectangleShape2D 16x8px)
- Скрипт: weapon_pickup.gd

В скрипте:
- export var weapon_data: WeaponData
- При входе игрока в Area2D: emit сигнал EventBus.weapon_pickup_available(self)
- При нажатии E игроком (EventBus сигнал interact): передать weapon_data в player WeaponManager
- При подборе: queue_free()

Не меняй существующие скрипты. Только новый файл.
```

#### 2.3 Throw mechanics верификация

**Промпт:**
```
Прочитай: scripts/combat/thrown_weapon.gd, docs/12_WEAPON_DESIGN.md (секция Throw Effects)

Для каждого из 5 MVP оружий (machete, knife, bat, sawed_off, pistol) проверь:
1. throw_arc указан в .tres (STRAIGHT/ARC/SPIN/TUMBLE/FLOAT)
2. throw_damage указан
3. В thrown_weapon.gd есть обработка каждого arc типа

Если arc тип не обрабатывается → добавь минимальную реализацию в thrown_weapon.gd.
Сверь throw effects с таблицей в 12_WEAPON_DESIGN.md.
Выведи таблицу: weapon | arc | throw_damage | реализован ✓/✗
```

---

### ШАГ 3: M3 — FLOOR 1 ALPHA

**Цель**: Полный Floor 1 (Service Underground) с 3 типами врагов и мини-боссом.

**Документы-источники**: `13_FLOOR_DESIGN.md` (Floor 1 layout), `11_ENEMY_DESIGN.md`
(Staff, Guard, Handler stats), `14_BOSS_DESIGN.md` (Head Chef)

#### 3.1 Enemy subtypes — Staff, Guard, Handler

**Промпт:**
```
Прочитай: scripts/ai/base_enemy.gd (полностью — 485 строк),
          docs/11_ENEMY_DESIGN.md (секции Staff, Guard, Handler: stats и behaviors),
          docs/01_GDD.md (секция 2.4.1 Enemy Archetypes)

Создай 3 скрипта-наследника от BaseEnemy:
- scripts/ai/enemy_staff.gd
- scripts/ai/enemy_guard.gd
- scripts/ai/enemy_handler.gd

Для каждого переопредели только:
- Начальные значения HP (head_hp, arm_hp, leg_hp, torso_hp) из 11_ENEMY_DESIGN.md
- base_speed из docs
- patrol_radius и detection_range из docs
- Для Handler: добавь grab_attempt() метод с логикой из GDD 2.4.2 "Capture Priority"

Создай соответствующие .tscn сцены наследующие base_enemy.tscn.
Не дублируй логику из base_enemy.gd — только override переменных и уникального поведения.
```

#### 3.2 Room system

**Промпт:**
```
Прочитай: docs/02_TDD.md (секция World Systems), docs/13_FLOOR_DESIGN.md (Floor 1 layout),
          docs/01_GDD.md (секция 2.6 Floor Structure)

Создай scripts/world/room_instance.gd:
- Базовый класс для всех комнат
- Переменные: room_id, connected_rooms: Array[NodePath], spawn_points: Array[Node2D]
- Сигналы: player_entered, player_exited, room_cleared
- Метод activate_room() / deactivate_room() (для оптимизации: деактивируй врагов вне комнаты)
- Метод get_spawn_points_for_seed(seed_value: int) -> Array — возвращает подмножество spawn_points

Создай scenes/world/room_instance.tscn.
Следуй performance target из TDD: max 10 active enemies, room-by-room loading.
```

#### 3.3 Floor 1 layout

**Промпт:**
```
Прочитай: docs/13_FLOOR_DESIGN.md (Floor 1: Service Underground — полный раздел),
          scripts/world/room_instance.gd (из предыдущего шага)

Создай сцену scenes/floors/floor_01.tscn:
- Структура: HUB + 3 branch rooms + mini-boss arena (как в 13_FLOOR_DESIGN.md)
- Каждая комната — экземпляр room_instance.tscn с уникальным layout через TileMapLayer
- Двери между комнатами: Area2D тригеры для room transition
- Spawn points расставь согласно 13_FLOOR_DESIGN.md (8-12 per room)
- Palette Floor 1: #4A4A4A (grey), #2D4A2D (dim green), #7A4A2A (rust) согласно 10_ART_BIBLE.md

Размер каждой комнаты: мин 20x15 тайлов (большие комнаты не помещаются на экран — camera следует).
Не добавляй врагов напрямую — только spawn points. Враги будут инстанцироваться runtime.
```

#### 3.4 Head Chef mini-boss

**Промпт:**
```
Прочитай: docs/14_BOSS_DESIGN.md (Head Chef — все фазы и паттерны),
          scripts/ai/base_enemy.gd (для понимания state machine),
          docs/11_ENEMY_DESIGN.md (Head Chef stats если есть)

Создай scripts/ai/boss_head_chef.gd наследуя BaseEnemy:
- HP: 3x arm/leg HP и 4x torso HP от обычного врага (как в 14_BOSS_DESIGN.md)
- Phase 1 (100-60% HP): Cleaver sweep (AoE melee в конусе), charge attack
- Phase 2 (60-30% HP): Добавляет thrown cleaver projectile
- Phase 3 (30-0% HP): Enrage — все атаки быстрее, добавляет призыв 2 Staff enemies

Паттерны выбираются из pool (3 варианта per phase) через SeedManager для вариативности.
Сигнал при смерти: EventBus.boss_defeated — разблокирует дверь на следующий этаж.

Сверь фазы с 14_BOSS_DESIGN.md построчно перед финальным кодом.
```

---

### ШАГ 4: M4 — RUN SYSTEMS

**Цель**: Полный roguelike loop: рандомизация, basement escape, run start/end.

**Документы-источники**: `02_TDD.md` (SeedManager, RunState), `19_BASEMENT_DESIGN.md`

#### 4.1 Basement escape

**Промпт:**
```
Прочитай: docs/19_BASEMENT_DESIGN.md (полностью),
          scripts/core/game_manager.gd (состояния BASEMENT и переходы),
          docs/01_GDD.md (секция 2.7 Basement Escape)

Создай scenes/basement/basement.tscn:
- Фиксированный layout: 8x6 тайлов как в 19_BASEMENT_DESIGN.md
- Один вход (spawn point игрока), один выход (exit Area2D)
- Таймер 60 секунд (CountdownTimer) → истёк = run_failed
- Spawn points для floor-themed врагов (масштаб по floor_number из RunState)
- Скрипт scripts/world/basement_manager.gd:
  - on_enter(): strip weapons (оставить 1 random melee), spawn врагов
  - on_exit_reached(): GameManager.transition(PLAYING), вернуть на floor start
  - on_timer_expired(): GameManager.transition(GAME_OVER)

Не добавляй лишних механик — строго по 19_BASEMENT_DESIGN.md (hidden alcove — Nice to Have).
```

#### 4.2 Spawn randomization

**Промпт:**
```
Прочитай: scripts/core/seed_manager.gd (все методы),
          scripts/world/room_instance.gd (метод get_spawn_points_for_seed),
          docs/01_GDD.md (секция 2.8.1 Random Enemy Spawning)

Создай scripts/world/enemy_spawner.gd:
- Принимает: room_id, floor_number, enemy_pool: Array[PackedScene], seed_manager: SeedManager
- Метод spawn_enemies(room: RoomInstance):
  - Получает spawn points: room.get_spawn_points_for_seed(seed_manager.get_room_seed(room_id))
  - Выбирает N точек (N зависит от floor_number: floor1=2-4, floor2=3-5, etc.)
  - Для каждой точки выбирает тип врага из enemy_pool с весами из floor loot table
  - Инстанцирует и добавляет в комнату
- Метод spawn_loot(room: RoomInstance, loot_table: Array):
  - Аналогично для weapon_pickup.tscn

Loot tables должны соответствовать 13_FLOOR_DESIGN.md (floor-specific enemy composition).
```

---

### ШАГ 5: M5 — VERTICAL SLICE (Floor 1 полностью готов)

**Цель**: Все системы работают вместе, HUD, game feel.

#### 5.1 HUD

**Промпт:**
```
Прочитай: docs/18_UI_DESIGN.md (секция HUD и Minimal diegetic HUD),
          docs/10_ART_BIBLE.md (секция Fonts и UI visual design),
          scripts/core/event_bus.gd (сигналы для HP, weapon changes)

Создай scenes/ui/hud.tscn (CanvasLayer):
- HP bar: bottom-left, TextureProgressBar, цвет #CC3333→#333333
- Weapon slots: top-left, 2 слота (HBoxContainer с TextureRect)
- Ammo counter: рядом с оружием, Label
- Floor indicator: bottom-center, Label "FLOOR X"
- Buff icons: bottom-right, HFlowContainer

Скрипт scripts/ui/hud.gd подписывается на EventBus сигналы:
- player_hp_changed → обновить HP bar
- weapon_changed → обновить слоты
- floor_changed → обновить floor indicator

Никакого minimap. Строго по 18_UI_DESIGN.md.
Pixel шрифт: для floor indicator — gothic serif, для ammo — clean sans (как в docs).
```

#### 5.2 Game feel (juice)

**Промпт:**
```
Прочитай: docs/03_PRODUCTION_PLAN.md (Epic 8: Feature 8.1 Game Feel),
          scripts/player/player_controller.gd (метод take_damage и hurt flash)

Добавь в существующие скрипты (минимальные изменения):
1. player_controller.gd: screen shake при получении урона
   - Используй Camera2D.offset + Tween для 0.2с shake amplitude 5px
2. base_enemy.gd: hit stop при попадании
   - Engine.time_scale = 0.1 на 1 frame при limb damage > threshold
3. gore_system.gd: blood pool persistence
   - Спавни StaticBody2D с ColorRect #8B0000 при severance, не удаляй между комнатами

Не добавляй новые системы. Только точечные изменения в существующих скриптах.
Проверь что 60 FPS сохраняется после изменений.
```

---

### ШАГ 6: M6 — CONTENT EXPANSION (Floors 2-3)

**Цель**: Доказать масштабируемость систем на Floor 2 (Red Light District) и Floor 3 (Banquet Hall).

**Шаблон промпта для нового этажа:**
```
Прочитай: docs/13_FLOOR_DESIGN.md (Floor [N]: [Name] — полный раздел),
          docs/11_ENEMY_DESIGN.md (уникальные враги Floor [N]),
          docs/14_BOSS_DESIGN.md ([Boss Name] — все фазы),
          docs/10_ART_BIBLE.md (palette Floor [N])

Задача (выполняй последовательно):
1. Создай enemy скрипты для уникальных врагов Floor [N] (наследуй BaseEnemy)
   - Строго по stats из 11_ENEMY_DESIGN.md
2. Создай scenes/floors/floor_0[N].tscn по layout из 13_FLOOR_DESIGN.md
   - Palette: [цвета из FLOOR_DESIGN]
   - HUB + branches + boss arena
3. Создай boss_[name].gd по 14_BOSS_DESIGN.md
4. Обнови FloorManager для загрузки нового этажа

Проверь что все новые системы работают через existing enemy_spawner.gd и room_instance.gd
без модификации core кода.
```

---

### ШАГ 7: M7 — FULL GAME (Floors 4-9)

**Принцип**: Floors 4-9 строятся итерациями по тому же шаблону что Floor 2-3.
Дополнительно — нарратив и сестра.

#### 7.1 Narrative integration

**Промпт:**
```
Прочитай: docs/16_NARRATIVE_DESIGN.md (полностью),
          docs/13_FLOOR_DESIGN.md (environmental storytelling per floor)

Для каждого этажа создай:
- scenes/narrative/lore_note.tscn — подбираемая записка
- Скрипт lore_note.gd: при взаимодействии (E) показывает текст из 16_NARRATIVE_DESIGN.md
- Расставь в floor_0[N].tscn согласно документу (8 типов документов per floor)

Floor 9 — Sister encounter:
- Создай scripts/ai/boss_sister.gd с 4 фазами из 14_BOSS_DESIGN.md
- После победы/выбора: trigger одну из 4 концовок (kill/spare/never_attack/embrace)
- Концовки реализуй как отдельные сцены scenes/endings/ending_[type].tscn
```

---

### ШАГ 8: M8 — POLISH

#### 8.1 Audio

**Промпт-шаблон:**
```
Прочитай: docs/17_AUDIO_DIRECTION.md (секция Floor [N] music + SFX list),
          docs/02_TDD.md (Audio System — dynamic music)

Интегрируй аудио для Floor [N]:
- Создай scripts/audio/audio_manager.gd (если не существует)
- Добавь 3 AudioStreamPlayer: exploration, combat, boss
- Триггер смены через EventBus: enemy_alerted → switch to combat track
- SFX: подключи weapon_hit, limb_sever, regen_start через AudioStreamPlayer2D

Используй Godot 4 AudioServer для динамического crossfade между слоями.
Файлы аудио пока placeholder (silence или generated).
```

#### 8.2 Balance pass

**Промпт:**
```
Прочитай: docs/11_ENEMY_DESIGN.md (все HP таблицы),
          docs/12_WEAPON_DESIGN.md (все damage значения),
          docs/15_UPGRADE_DESIGN.md (все artifact bonuses/costs)

Выведи таблицу:
- Weapon DPS vs Enemy HP (time-to-kill per limb per weapon)
- Regen rate vs player DPS (sustainable pressure analysis)
- Artifact cost/benefit ratio

Найди явные outliers (оружие/апгрейд на порядок сильнее/слабее других).
Предложи конкретные правки цифр с обоснованием. Не меняй сами файлы — только analysis.
```

---

## ЧАСТЬ 3: МЕТАПРИНЦИПЫ АГЕНТНОГО ПРОМПТИНГА ДЛЯ ЭТОГО ПРОЕКТА

### DO:
- Давай агенту **список конкретных файлов для чтения** в начале каждого промпта
- Указывай **точные названия функций и сигналов** из уже существующего кода
- Проси **сверить результат с документом-источником** в конце промпта
- Ограничивай scope: **один .gd файл = один промпт**
- Используй **шаблон**: "Прочитай X, создай Y, проверь Z"

### DON'T:
- Не проси "создай всю систему врагов" — только конкретный enemy type
- Не давай промпт без указания документа-источника для балансных цифр
- Не просй рефакторить существующий код вместе с новым функционалом
- Не объединяй несколько milestone'ов в один промпт

### Шаблон верификационного промпта (после каждого шага):
```
Прочитай: [файл который только что создан/изменён]
Прочитай: [исходный документ спецификации]

Сверь реализацию со спецификацией и выведи:
✓ Реализовано согласно документу: [список]
✗ Расхождения: [список с конкретными строками]
? Неоднозначности: [список]
```

---

## КРИТИЧЕСКИЕ ФАЙЛЫ

- `/home/kj/hotel/docs/00_PILLAR_DOCUMENT.md` — vision, исправить mini-boss count и damage zones
- `/home/kj/hotel/docs/00_PROGRESS.md` — исправить путь /home/kj → /home/user
- `/home/kj/hotel/docs/01_GDD.md` — источник истины для gameplay rules
- `/home/kj/hotel/docs/11_ENEMY_DESIGN.md` — Stats table для всех врагов
- `/home/kj/hotel/docs/12_WEAPON_DESIGN.md` — Stats table для всех оружий
- `/home/kj/hotel/docs/14_BOSS_DESIGN.md` — Boss phases и patterns
- `/home/kj/hotel/project/scripts/ai/base_enemy.gd` — core enemy logic (485 lines)
- `/home/kj/hotel/project/scripts/combat/weapon_manager.gd` — weapon system
- `/home/kj/hotel/project/scripts/core/game_manager.gd` — state machine

---

## ВЕРИФИКАЦИЯ ПЛАНА

После каждого milestone запускать:
```
godot --headless --script res://scripts/tests/test_runner.gd
```
Ожидаемый результат: все существующие тесты зелёные.

Exit code 0 = продолжай задачу.
Exit code 1 = прочитай stdout, найди failing test, 
              исправь только тот файл который он тестирует,
              запусти снова. Повтори до exit code 0.

Для M5 (Vertical Slice): запустить полный run Floor 1 вручную и пройти чеклист:
- [ ] Игрок двигается и атакует
- [ ] Враг получает урон по конечностям
- [ ] Конечности регенерируют (видимо)
- [ ] Бросок оружия работает
- [ ] Мини-босс (Head Chef) имеет 3 фазы
- [ ] Basement escape работает
- [ ] HUD отображает HP/оружие/этаж
- [ ] Run start и run end (game over/victory) работают