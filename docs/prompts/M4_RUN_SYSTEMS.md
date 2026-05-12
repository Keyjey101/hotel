M4 — Run Systems. Полный roguelike loop: basement escape, spawn/loot randomization через SeedManager, run start/end lifecycle. Один промпт, 7 шагов — все части связаны через run state и game flow.

## КОНТЕКСТ ЗАДАЧИ

Проект HOTEL — 2D top-down roguelike на Godot 4. Milestone M4 (Run Systems). Цель: замкнуть roguelike loop — полный цикл от start run до game over/victory. Создать basement escape (1 layout, floor-themed enemies, weapon stripping, time pressure), завершить SeedManager spawn/loot randomization, создать enemy_spawner и loot_spawner, настроить run lifecycle (new run → floor → boss → basement/game over → restart). Предыдущие M1-M3 завершены: combat pipeline, 8 оружий, Floor 1 с 10 комнатами и Head Chef boss.

## ПЕРЕД НАЧАЛОМ ОБЯЗАТЕЛЬНО ПРОЧИТАЙ

1. `/home/kj/hotel/docs/19_BASEMENT_DESIGN.md` — ВЕСЬ документ: layout (8×6 tiles), room structure, weapon stripping rules, enemy scaling per floor таблица, time pressure (60s), failure state, loot rules
2. `/home/kj/hotel/project/scripts/core/seed_manager.gd` — ПОЛНОСТЬЮ: какие методы реализованы, какие stub-ы, формат return values для get_enemy_spawn_config(), get_loot_config(), get_gate_config()
3. `/home/kj/hotel/project/scripts/core/game_manager.gd` — ПОЛНОСТЬЮ: GameState enum, transition методы (start_new_run, transition_to_basement, handle_basement_success/failure), current_run, seed_manager
4. `/home/kj/hotel/project/scripts/core/run_state.gd` — ПОЛНОСТЬЮ: какие data хранятся (current_floor, player_hp, weapons, upgrades), apply methods, _recalculate_stats()
5. `/home/kj/hotel/project/scripts/core/save_manager.gd` — save_run_state, load_run_state
6. `/home/kj/hotel/project/scripts/core/event_bus.gd` — player_captured, mini_boss_defeated, floor_completed, room_entered, room_cleared
7. `/home/kj/hotel/project/scripts/world/floor_manager.gd` — из M3.2: как загружается этаж, спавнятся враги, обрабатываются переходы
8. `/home/kj/hotel/project/scripts/world/floor_01_config.gd` — room configs, enemy/loot composition
9. `/home/kj/hotel/docs/13_FLOOR_DESIGN.md` — секция 1.2 (Route Variation), секция 1.3 (Room Types), loot table weights
10. `/home/kj/hotel/docs/12_WEAPON_DESIGN.md` — секция 7.1 (Weapon Availability Per Floor), секция 7.2 (Loot Table Weights)
11. `/home/kj/hotel/docs/11_ENEMY_DESIGN.md` — секция 4.3 (Group Compositions Per Floor), секция 5.1 (Per-Floor Scaling)

## ИСХОДНОЕ СОСТОЯНИЕ

- `/home/kj/hotel/project/scripts/core/seed_manager.gd` — ✅ но методы get_enemy_spawn_config/get_loot_config могут быть stub-ами
- `/home/kj/hotel/project/scripts/core/game_manager.gd` — ✅ GameState enum, transition методы
- `/home/kj/hotel/project/scripts/core/run_state.gd` — ✅ per-run state tracking
- `/home/kj/hotel/project/scripts/core/save_manager.gd` — ✅ save/load
- `/home/kj/hotel/project/scripts/core/event_bus.gd` — ✅ signals
- `/home/kj/hotel/project/scripts/world/floor_manager.gd` — ✅ из M3.2
- `/home/kj/hotel/project/scripts/world/floor_01_config.gd` — ✅ из M3.2
- `/home/kj/hotel/project/scripts/world/room_instance.gd` — ✅ из M3.1
- `/home/kj/hotel/project/scenes/core/game.tscn` — ✅ main scene
- `/home/kj/hotel/project/scenes/basement/basement.tscn` — ❌ отсутствует
- `/home/kj/hotel/project/scripts/world/basement_manager.gd` — ❌ отсутствует
- `/home/kj/hotel/project/scripts/world/enemy_spawner.gd` — ❌ отсутствует
- `/home/kj/hotel/project/scripts/world/loot_spawner.gd` — ❌ отсутствует
- `/home/kj/hotel/project/scenes/ui/title_screen.tscn` — ❌ отсутствует
- `/home/kj/hotel/project/scenes/ui/game_over.tscn` — ❌ отсутствует

## ЦЕЛЕВОЕ СОСТОЯНИЕ

- `/home/kj/hotel/project/scenes/basement/basement.tscn` — basement escape сцена: 7 комнат (start, corridors, rooms, exit)
- `/home/kj/hotel/project/scripts/world/basement_manager.gd` — basement логика: weapon stripping, enemy spawning, time pressure, success/failure
- `/home/kj/hotel/project/scripts/world/enemy_spawner.gd` — seed-based enemy spawn system
- `/home/kj/hotel/project/scripts/world/loot_spawner.gd` — seed-based loot placement system
- `/home/kj/hotel/project/scripts/core/seed_manager.gd` — дописан: функциональные get_enemy_spawn_config, get_loot_config (если были stub-ами)
- `/home/kj/hotel/project/scenes/ui/title_screen.tscn` — placeholder title screen с "New Run" button
- `/home/kj/hotel/project/scenes/ui/game_over.tscn` — placeholder game over screen
- `/home/kj/hotel/project/scripts/core/game_manager.gd` — обновлён: полный run lifecycle wired

## ПОШАГОВЫЙ ПЛАН

Используй TodoWrite. Plan mode рекомендован — много взаимосвязанных систем.

**Шаг 1. Прочитать все референсы (параллельно через 3 subagent'а)**

Subagent A — Basement design:
- Прочитай `/home/kj/hotel/docs/19_BASEMENT_DESIGN.md` ПОЛНОСТЬЮ
- Выпиши: layout (7 rooms с размерами), weapon stripping rules, enemy scaling таблицу (Floor 1-9), time pressure (60s/90s), loot rules, failure state

Subagent B — Existing core systems:
- Прочитай `/home/kj/hotel/project/scripts/core/seed_manager.gd` ПОЛНОСТЬЮ
- Прочитай `/home/kj/hotel/project/scripts/core/game_manager.gd` ПОЛНОСТЬЮ
- Прочитай `/home/kj/hotel/project/scripts/core/run_state.gd` ПОЛНОСТЬЮ
- Прочитай `/home/kj/hotel/project/scripts/core/save_manager.gd` ПОЛНОСТЬЮ
- Выпиши: какие методы SeedManager stub-ы, какие transition методы GameManager готовы, что нужно дописать

Subagent C — Spawn/loot design:
- Прочитай `/home/kj/hotel/docs/13_FLOOR_DESIGN.md` секции 1.2, 1.3
- Прочитай `/home/kj/hotel/docs/12_WEAPON_DESIGN.md` секции 7.1, 7.2
- Прочитай `/home/kj/hotel/docs/11_ENEMY_DESIGN.md` секции 4.3, 5.1
- Выпиши: loot table weights, weapon availability per floor, enemy composition per floor, per-floor scaling multipliers

**Шаг 2. Дописать SeedManager — spawn/loot configs**

Если `/home/kj/hotel/project/scripts/core/seed_manager.gd` имеет stub-методы — допиши их. НЕ переписывай существующие методы.

**get_enemy_spawn_config(floor_number, room_index) -> Dictionary:**
Возвращает:
```
{
    "enemy_count": int,          # зависит от floor: F1=2-4, F2=3-5, etc.
    "enemy_types": Array[String], # ["staff", "guard", "handler"] — floor-specific pool
    "spawn_point_indices": Array[int], # какие spawn points активны
}
```
- Использует seeded RandomNumberGenerator (seed = get_room_seed(floor, room))
- Enemy count: baseline из 11_ENEMY_DESIGN.md секция 4.3 (Group Compositions)
- Enemy types: из floor-specific pool (Floor 1: staff, guard, handler)
- Spawn point selection: выбрать N из всех доступных spawn points

**get_loot_config(floor_number, room_index) -> Dictionary:**
Возвращает:
```
{
    "weapons": Array[Dictionary],  # [{"id": "knife", "weight": 10}]
    "upgrades": Array[Dictionary], # [{"type": "vitality_shard", "weight": 8}]
    "ammo_count": int,
}
```
- Weapon weights из 12_WEAPON_DESIGN.md секция 7.2: knife/pistol/bottle=10, machete/bat=5, axe/shotgun=3, cult=1
- Floor availability из секции 7.1 (какие оружия доступны на данном этаже)

**get_gate_config(floor_number) -> Dictionary:**
Возвращает:
```
{
    "open_branches": Array[String],  # ["b", "d"] — 2 из 3 открыты
    "closed_branch": String,          # "c" — закрытая ветка
    "key_room": String,               # "b2" или "d2" — где ключ
}
```
- 1 из 3 веток (B/C/D) закрыта, seed-based selection
- Key location: в одной из комнат открытых веток

**Шаг 3. Создать enemy_spawner.gd**

Создай `/home/kj/hotel/project/scripts/world/enemy_spawner.gd`:
- class_name EnemySpawner, extends Node
- Статический метод или utility class

**spawn_enemies(room: RoomInstance, floor_number: int, room_index: int, seed_mgr: SeedManager) -> Array[CharacterBody2D]:**
1. Получить config: seed_mgr.get_enemy_spawn_config(floor_number, room_index)
2. Получить spawn points: room.spawn_points (Marker2D array)
3. Выбрать активные spawn points: config.spawn_point_indices → rooms spawn points по этим индексам
4. Для каждого spawn:
   - Определить тип врага из config.enemy_types (weighted random из floor pool)
   - Загрузить PackedScene: "res://scenes/enemies/{type}.tscn"
   - Инстанцировать, позиция = spawn point position
   - Применить per-floor scaling из 11_ENEMY_DESIGN.md секция 5.1:
     - Floor 1: ×1.0 HP, ×1.0 Speed, ×1.0 Regen, ×1.0 Aggression
     - Floor 2: ×1.0, ×1.05, ×1.0, ×1.1
     - Floor 3: ×1.1, ×1.05, ×1.05, ×1.1
     - ... и т.д. до Floor 9: ×1.5, ×1.3, ×1.3, ×1.5
   - Добавить в room как child
   - Вернуть массив созданных врагов

Max enemies per room: 10 (performance budget из TDD).

Floor-specific enemy pools из 11_ENEMY_DESIGN.md секция 4.3:
- Floor 1: staff, guard, handler
- Floor 2: staff, guard, seductress, bodyguard
- Floor 3: staff, guard, chef, taster, butcher
- ... (для M4 достаточно Floor 1 pool, остальные определятся в M6+)

**Шаг 4. Создать loot_spawner.gd**

Создай `/home/kj/hotel/project/scripts/world/loot_spawner.gd`:
- class_name LootSpawner, extends Node

**spawn_loot(room: RoomInstance, floor_number: int, room_index: int, seed_mgr: SeedManager):**
1. Получить config: seed_mgr.get_loot_config(floor_number, room_index)
2. Получить loot zones: room loot_zone Marker2D array
3. Weapons: для каждого weapon в config.weapons:
   - Weighted selection (seeded random)
   - Создать weapon_pickup node (из M2) или placeholder Area2D
   - Установить weapon_data: load("res://resources/weapons/{id}.tres")
   - Позиция = loot zone position (seeded selection)
4. Upgrades: аналогично для stat upgrades
5. Ammo: spawn ammo pickup nodes
6. Key: если эта комната = key_room из gate config → spawn key pickup

Loot table logic:
- Guaranteed minimum: 1 item per room (weapon or upgrade)
- Chamber rooms: 1-2 items
- Storage rooms: 2-3 items
- Boss room: 1 cult artifact (random from 15_UPGRADE_DESIGN.md)
- Hub: 1 item
- Corridor: 0-1 items (ammo only)

**Шаг 5. Создать basement escape**

5a. Создай `/home/kj/hotel/project/scripts/world/basement_manager.gd`:
- class_name BasementManager, extends Node2D
- _vars:
  - var timer: float = 60.0 — time pressure (19_BASEMENT_DESIGN.md секция 3.3)
  - var reinforcements_spawned: bool = false
  - var critical_timer: float = 90.0 — second wave threshold
  - var source_floor: int = 1 — с какого этажа попал в basement
  - var player_weapons_backup: Array = [] — сохранённые оружия для возврата
  - var allowed_weapon: Resource — 1 random melee оставленный игроку
- Методы:
  - **enter_basement(floor_number: int):**
    1. source_floor = floor_number
    2. Backup player weapons (сохранить в player_weapons_backup)
    3. Strip weapons: оставить 1 random melee из инвентаря. Если нет melee — дать Knife
    4. Ammo = 0
    5. Upgrades KEEP (stats, artifacts persist — 19_BASEMENT_DESIGN.md секция 3.1)
    6. Timer = 60.0
    7. Spawn enemies based on floor_number scaling (таблица из секции 3.2):
       - Floor 1-2: 5-6 enemies (staff+guard), HP ×0.8, Speed ×0.9
       - Floor 3-4: 6-7 enemies (staff+guard+handler), HP ×1.0, Speed ×1.0
       - Floor 5-6: 7-8 enemies (+ floor type), HP ×1.1, Speed ×1.1
       - Floor 7-8: 8-9 enemies (+ elite), HP ×1.2, Speed ×1.15
       - Floor 9: 9-10 enemies (demon+elite), HP ×1.5, Speed ×1.3
    8. Position player at START room
  - **_process(delta):**
    1. timer -= delta
    2. Если timer ≤ 0 и !reinforcements_spawned: spawn 2 extra enemies, reinforcements_spawned = true
    3. Если timer ≤ -30 (90s total): spawn 4 more enemies
    4. Audio cue: timer-based (footsteps getting louder — placeholder: print warning)
  - **_on_exit_reached(body):**
    1. Если body == player: success
    2. Восстановить player weapons из backup
    3. GameManager.handle_basement_success()
    4. Transition обратно на source_floor, start of floor
    5. Если cleared < 30s → bonus: 1 random cult artifact
  - **_on_player_died():**
    1. GameManager.handle_basement_failure()
    2. Transition to game over

5b. Создай директорию и сцену `/home/kj/hotel/project/scenes/basement/basement.tscn`:
Layout из 19_BASEMENT_DESIGN.md секция 2.1 (7 rooms):

Start room (3×3 = 96×96 px):
- Player spawn marker
- 1 random melee weapon on ground (восстановление после strip)
- 0 enemies

Corridor A (6×2 = 192×64 px):
- Narrow, 1-2 enemies (floor-scaled)

Room A (5×4 = 160×128 px):
- 2-3 enemies (floor-scaled)
- Область с укрытиями (placeholder ColorRect obstacles)

Corridor B (4×2 = 128×64 px):
- Pipes visual (ColorRect #7A3A1A rust)
- 1 enemy

Room B (5×4 = 160×128 px):
- 2-3 enemies (floor-scaled)
- Область с укрытиями

Corridor C (4×2 = 128×64 px):
- Final stretch
- 1-2 enemies

Exit room (2×3 = 64×96 px):
- Exit stairs (Area2D trigger)
- 1 enemy guard

Каждая комната — Node2D с:
- Floor ColorRect: #3A3A3A (dark grey)
- Wall StaticBody2D: #1A1A1A (near-black), collision layer 7
- NavigationRegion2D
- Spawn points для врагов
- Дверные триггеры (Area2D) между комнатами

Palette из 19_BASEMENT_DESIGN.md секция 2.2:
- Walls: #1A1A1A
- Floor: #3A3A3A
- Pipes: #7A3A1A
- Light: #AA2222 dim red

Scene structure:
```
Basement (Node2D, script: basement_manager.gd)
├── Rooms (Node2D)
│   ├── StartRoom (Node2D, 96×96)
│   ├── CorridorA (Node2D, 192×64)
│   ├── RoomA (Node2D, 160×128)
│   ├── CorridorB (Node2D, 128×64)
│   ├── RoomB (Node2D, 160×128)
│   ├── CorridorC (Node2D, 128×64)
│   └── ExitRoom (Node2D, 64×96)
├── PlayerSpawn (Marker2D, position: 48, 48)
├── ExitTrigger (Area2D + CollisionShape2D) — в ExitRoom
└── TimerLabel (Label) — debug display, optional
```

**Шаг 6. Создать run lifecycle flow**

6a. Обнови `/home/kj/hotel/project/scripts/core/game_manager.gd` — допиши lifecycle:
Full flow:
```
MENU → (new run) → PLAYING → (HP=0) → BASEMENT → (escape) → PLAYING
                                    → (fail) → GAME_OVER → (restart) → MENU
                                    → (boss killed F9) → VICTORY → (restart) → MENU
```

Дописать/проверить:
- **start_new_run():** Создать RunState, SeedManager(randi()), set state=PLAYING, load Floor 1 scene, position player, give starting loadout (Machete + Sawed-off из 01_GDD.md секция 3.3)
- **transition_to_basement():** Save player weapons, set state=BASEMENT, load basement.tscn, call basement_manager.enter_basement(current_floor)
- **handle_basement_success():** Restore state=PLAYING, restore weapons, reload current floor (start position), SaveManager.save_run_state()
- **handle_basement_failure():** Set state=GAME_OVER, load game_over scene
- **handle_floor_completed(floor_num):** Если floor_num < 9 → load next floor. Если floor_num == 9 → set state=VICTORY
- **restart_run():** Clear RunState, set state=MENU, load title screen

6b. Создай `/home/kj/hotel/project/scenes/ui/title_screen.tscn` (placeholder):
- Node2D root
- Background ColorRect: #0A0A0A (black)
- Label "HOTEL" centered, font size large
- Button "NEW RUN" centered below title — подключить к GameManager.start_new_run()
- Script: title_screen.gd (inline or separate) — button press → GameManager.start_new_run()

6c. Создай `/home/kj/hotel/project/scenes/ui/game_over.tscn` (placeholder):
- Node2D root
- Background ColorRect: #0A0A0A
- Label "CONSUMED" centered (из 19_BASEMENT_DESIGN.md секция 4.1)
- Optional: run stats display (floor reached, enemies killed — из RunState если доступно)
- Button "RESTART" — → GameManager.restart_run()
- Button "QUIT" — → get_tree().quit()

6d. Обнови `/home/kj/hotel/project/scenes/core/game.tscn`:
- Начальная сцена: title_screen.tscn (или game_manager управляет scene switching)
- Убедись что game_manager.gd как autoload управляет scene transitions через get_tree().change_scene_to_file()

**Шаг 7. Верификация**

```bash
cd /home/kj/hotel/project && godot --headless --script res://scripts/tests/test_runner.gd
```
Критерий: exit code 0, все тесты pass.

```bash
cd /home/kj/hotel/project && godot --headless --scene res://scenes/basement/basement.tscn --quit-after 2
cd /home/kj/hotel/project && godot --headless --scene res://scenes/ui/title_screen.tscn --quit-after 2
cd /home/kj/hotel/project && godot --headless --scene res://scenes/ui/game_over.tscn --quit-after 2
```
Критерий: нет fatal errors.

Выведи таблицу basement enemy scaling:
| Floor | Enemies | Types | HP Mult | Speed Mult | Source (19_BASEMENT line) |

## ОГРАНИЧЕНИЯ И ANTI-PATTERNS

- НЕ придумывай basement layout — ТОЧНО по 19_BASEMENT_DESIGN.md секция 2.1 (7 rooms, конкретные размеры)
- НЕ придумывай enemy scaling numbers — таблица из секции 3.2 (Floor 1-2: ×0.8 HP, Floor 9: ×1.5 HP)
- Timer: 60s (reinforcements), 90s (heavy reinforcements) — ТОЧНО по секции 3.3
- Weapon stripping rules — ТОЧНО по секции 3.1 (keep 1 random melee, if no melee → give Knife)
- Upgrades KEEP при basement entry (секция 3.1) — это design intent
- НЕ переписывай seed_manager.gd — только дописывай stub-методы
- НЕ переписывай game_manager.gd — только добавляй/дополняй lifecycle методы
- НЕ создавай .md/.txt файлов
- НЕ используй Godot 3 API
- Title/Game Over screens — PLACEHOLDER (минимальный UI, polish в M5)
- Basement layout ОДИН на все этажи (19_BASEMENT Design секция 6.1: scope control)
- Enemy types в basement = из pool текущего этажа (Floor 3 basement → Chef enemies, etc.)
- Для M4 достаточно Floor 1 enemy pool (staff, guard, handler) в basement
- Starting loadout: Machete (slot 1) + Sawed-off (slot 2, 4 shots) — из 01_GDD.md секция 3.3
- Game over text: "CONSUMED" — из 19_BASEMENT_DESIGN.md секция 4.1
- NO second basement chance (failing basement = run over) — секция 4.2

## ВЕРИФИКАЦИЯ

Тесты:
```bash
cd /home/kj/hotel/project && godot --headless --script res://scripts/tests/test_runner.gd
```
Критерий: exit code 0, все тесты pass.

Scenes load:
```bash
cd /home/kj/hotel/project && godot --headless --scene res://scenes/basement/basement.tscn --quit-after 2
cd /home/kj/hotel/project && godot --headless --scene res://scenes/ui/title_screen.tscn --quit-after 2
cd /home/kj/hotel/project && godot --headless --scene res://scenes/ui/game_over.tscn --quit-after 2
```
Критерий: нет fatal errors для каждой сцены.

Data integrity:
Выведи таблицы:
- Basement enemy scaling vs 19_BASEMENT_DESIGN.md
- Loot table weights vs 12_WEAPON_DESIGN.md секция 7.2
- Per-floor enemy scaling vs 11_ENEMY_DESIGN.md секция 5.1

## ОТЧЁТНОСТЬ

В конце работы выведи:
✓ Реализовано согласно спеке: [basement, spawners, lifecycle, seed manager]
✗ Расхождения / открытые вопросы: [если есть]
📂 Изменённые файлы: [git status стиль]
🧪 Результат тестов: N passed / M failed
🔄 Run lifecycle: New Run ✓ → Floor ✓ → Boss ✓ → Basement ✓ → Game Over ✓ → Restart ✓
