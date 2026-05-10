# HOTEL — ТЕКУЩИЙ ПРОГРЕСС
## Последнее обновление: 2026-05-11

---

# СТАТУС: PRE-PRODUCTION ЗАВЕРШЕНА, ПРОТОТИП В РАЗРАБОТКЕ

---

# 1. ЗАВЕРШЁННЫЕ ЭТАПЫ

## ✅ DISCOVERY (Фаза 1) — Завершён
Определены все ключевые решения:
- Структура: Roguelike, 9 этажей за run (~30-40 мин)
- Player: жертва спасающая сестру, мачете + обрез
- Combat: гибридный pacing, real-time регенерация, per-limb damage (5 зон)
- Оружие: 15 типов, все throwable, разный эффект броска
- Failure: capture → basement escape (1 layout, разные враги) → lose run
- Floors: HUB + branches (10-15 комнат), 9 этажей с уникальными темами
- Upgrades: статы + культовые артефакты с trade-offs + оружие
- Сестра: narrative + twist, gameplay element на 9 этаже, 4 концовки

## ✅ SYNTHESIS — Завершён
Сформированы pillars, vision, gameplay identity, scope.

## ✅ PRE-PRODUCTION — Все документы готовы
Полный набор production документов создан.

## ✅ ПРОЕКТНЫЙ СКЕЛЕТ + КОД — Частично
Создана архитектура Godot 4 проекта, core systems, тесты.

---

# 2. ДОКУМЕНТАЦИЯ

```
/home/kj/hotel/docs/
├── 00_PILLAR_DOCUMENT.md       # Vision, pillars, core loop, floor map
├── 01_GDD.md                   # Game Design Document (полный драфт)
├── 02_TDD.md                   # Technical Design Document (Godot 4)
├── 03_PRODUCTION_PLAN.md       # Milestones, task breakdown, risks
├── 10_ART_BIBLE.md             # Pixel specs, palettes, animation, gore
├── 11_ENEMY_DESIGN.md          # 21 enemy type, full stats + behaviors
├── 12_WEAPON_DESIGN.md         # 15 weapons, stats + throw effects
├── 13_FLOOR_DESIGN.md          # 9 floors, ~88 rooms, layouts + lore
├── 14_BOSS_DESIGN.md           # 10 bosses, phases, patterns, 4 endings
├── 15_UPGRADE_DESIGN.md        # 11 stats + 12 cult artifacts
├── 16_NARRATIVE_DESIGN.md      # Lore, sister arc, endings, environmental storytelling
├── 17_AUDIO_DIRECTION.md       # Per-floor music, SFX list, dynamic system
├── 18_UI_DESIGN.md             # HUD, menus, fonts
└── 19_BASEMENT_DESIGN.md       # Escape layout, scaling, failure state
```

---

# 3. КОД ПРОЕКТА

```
/home/kj/hotel/project/
├── project.godot                           # Godot 4 config (640x360, autoloads, inputs, layers)
│
├── scripts/core/
│   ├── game_manager.gd                     # ✅ Game state, run lifecycle, transitions
│   ├── event_bus.gd                        # ✅ Global event signals
│   ├── save_manager.gd                     # ✅ Run save, settings, records
│   ├── run_state.gd                        # ✅ Per-run state tracking
│   ├── seed_manager.gd                     # ✅ Deterministic per-run RNG
│   └── game_scene.gd                       # ✅ Main scene orchestrator
│
├── scripts/player/
│   └── player_controller.gd                # ✅ Movement, aim, combat, HP, capture
│
├── scripts/combat/
│   ├── damage_zones.gd                     # ✅ Zone enum + helpers
│   ├── weapon_manager.gd                   # ✅ Equip/switch/throw, damage calc, upgrades
│   ├── melee_hit.gd                        # ✅ Temporary melee hitbox
│   ├── projectile.gd                       # ✅ Bullet entity
│   ├── thrown_weapon.gd                    # ✅ Physics throw with unique effects
│   └── gore_system.gd                      # ✅ Blood, severed limbs, pools (placeholder visuals)
│
├── scripts/ai/
│   └── base_enemy.gd                       # ✅ State machine, per-limb HP, regen, alert chain
│
├── scenes/
│   ├── core/game.tscn                      # ✅ Main game scene
│   ├── player/player.tscn                  # ✅ Player with all nodes
│   ├── enemies/base_enemy.tscn             # ✅ Enemy with 5 hurtbox zones
│   └── weapons/                            # ✅ melee_hit, projectile, thrown_weapon scenes
│
├── resources/weapons/
│   ├── weapon_data.gd                      # ✅ Weapon data class
│   ├── melee_machete.tres                  # ✅ Starting weapon
│   ├── melee_knife.tres                    # ✅ Precision mutilation
│   ├── melee_bat.tres                      # ✅ Crowd control
│   ├── ranged_sawed_off.tres               # ✅ Starting ranged
│   └── ranged_pistol.tres                  # ✅ Workhorse ranged
│
├── scripts/tests/ (7 suites, ~70 tests)
│   ├── test_runner.gd                      # ✅ Lightweight test framework
│   ├── test_base.gd                        # ✅ Assertion library
│   ├── test_run_state.gd                   # ✅ 12 tests
│   ├── test_seed_manager.gd                # ✅ 12 tests
│   ├── test_damage_zone.gd                 # ✅ 9 tests
│   ├── test_enemy_health.gd                # ✅ 12 tests
│   ├── test_regen_system.gd                # ✅ 12 tests
│   ├── test_weapon_data.gd                 # ✅ 20 tests
│   └── test_combat_flow.gd                 # ✅ 14 tests
│
└── scenes/test/
    ├── test_runner.tscn                     # ✅ Scene для запуска тестов
    └── test_room.tscn                       # ✅ Combat prototype комната
```

---

# 4. КЛЮЧЕВЫЕ ТЕХНИЧЕСКИЕ РЕШЕНИЯ

| Решение | Выбор |
|---------|-------|
| Движок | Godot 4.x, GDScript |
| Viewport | 640×360, масштаб ×2/3/4 |
| Стилиль пиксель-арта | 32×32 tiles, 24×36 персонажи, 3/4 view |
| Collision layers | 8: player_hurt/hit, enemy_hurt/hit, weapon, projectile, env, throwable |
| Autoloads | GameManager, EventBus, SaveManager |
| Ввод | WASD + mouse (attack=ЛКМ, throw=ПКМ, interact=E, switch=Q) |
| Тестирование | Собственный lightweight фреймворк, ~70 тестов |

---

# 5. ЧТО НЕ СДЕЛАНО (ПРИОРИТЕТ ДАЛЬШЕ)

## Ближайшие задачи (Combat Prototype — M1/M2)

| # | Задача | Статус |
|---|--------|--------|
| 1 | Открыть проект в Godot Editor, исправить ошибки загрузки | ❌ |
| 2 | Добавить placeholder спрайты (цветные прямоугольники) для player/enemy | ❌ |
| 3 | Создать TileSet для тестовой комнаты (пол + стены) | ❌ |
| 4 | Настроить NavigationRegion2D в тестовой комнате | ❌ |
| 5 | Weapon pickup scene (оружие на полу) | ❌ |
| 6 | Протестировать melee attack → enemy damage pipeline | ❌ |
| 7 | Протестировать ranged attack → projectile → damage | ❌ |
| 8 | Протестировать throw → thrown weapon → effect | ❌ |
| 9 | Протестировать enemy regen в реальном времени | ❌ |
| 10 | HUD: weapon slots, ammo display | ❌ |

## Следующие milestone'ы

| Milestone | Описание | Статус |
|-----------|----------|--------|
| M1: Combat Prototype | Player + 1 enemy + melee + regen | 🔄 В процессе |
| M2: Weapon System | 5 weapons + throw mechanics | ❌ |
| M3: Floor 1 Alpha | Full floor + 3 enemy types + mini-boss | ❌ |
| M4: Run Systems | Basement + run start/end + randomization | ❌ |
| M5: Vertical Slice | Floor 1 polished, all systems | ❌ |

---

# 6. ИЗВЕСТНЫЕ ПРОБЛЕМЫ / TODO

- .tscn файлы содержат SubResource ссылки которые Godot Editor создаст при первом открытии
- Placeholder visuals для gore (нужны реальные спрайты)
- MeleeHit scene нуждается в прикреплении скрипта через Godot Editor
- Projectile scene нуждается в прикреплении скрипта через Godot Editor
- ThrownWeapon scene нуждается в прикреплении скрипта через Godot Editor
- GoreSystem — не autoload, нужно прикрепить вручную к game scene
- Enemy subtypes (Staff, Guard, Handler) — пока только base_enemy
- Нет tileset для тестовой комнаты
- Нет weapon pickup scene
- Нет звука (SFX/music)

---

# 7. КАК ПРОДОЛЖИТЬ

1. Открыть `/home/kj/hotel/project/` в Godot 4 Editor
2. Проверить что проект загружается без ошибок
3. Исправить любые проблемы с .tscn файлами
4. Запустить тесты: `godot --headless --scene scenes/test/test_runner.tscn`
5. Запустить тестовую комнату: `godot --scene scenes/test/test_room.tscn`
6. Начать с placeholder спрайтов → проверить combat pipeline
7. Итерировать по production plan milestones
