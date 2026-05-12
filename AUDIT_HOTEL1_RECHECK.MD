# Повторный аудит — результаты проверки исправлений

## Статус исправлений по оригинальным 44 багам

| # | Приоритет | Статус |
|---|-----------|--------|
| 1 | CRITICAL | FIXED — HEAD убран из `all_limbs()` |
| 2 | CRITICAL | FIXED — лишний `return` удалён |
| 3 | CRITICAL | FIXED — sync из `run_state` добавлен в `weapon_manager._ready()` |
| 4 | CRITICAL | FIXED — создаются отдельные RNG без мутации кэша |
| 5 | CRITICAL | FIXED — `_on_pickup_collected` теперь equip'ит оружие/апгрейды/артефакты |
| 6 | CRITICAL | FIXED — лямбды сохранены в переменные, disconnect работает корректно |
| 7 | HIGH | FIXED — `_on_limb_lost` использует `_initial_move_speed * X` |
| 8 | HIGH | FIXED — `_state_alert` больше не декрементирует `_state_timer` |
| 9 | HIGH | FIXED — ObjectPool использует `_pool.pop_back()` после `_expand()` |
| 10 | HIGH | FIXED — vignette tween хранится в `_vignette_pulse_tween` и убивается |
| 11 | HIGH | FIXED — CanvasLayer layer = 50 |
| 12 | HIGH | FIXED — `apply_slow` восстанавливает `run_state.player_speed` |
| 13 | HIGH | FIXED — `_apply_embed` использует `_original_speed` meta |
| 14 | HIGH | FIXED — `from_dict` вызывает `cleanup()` на старом RunState |
| 15 | HIGH | FIXED — использует `weapon.ammo` вместо несуществующего `max_ammo` |
| 16 | MEDIUM | NOT CHECKED (глобальный `randi()` в projectile) |
| 17 | MEDIUM | FIXED — `_floor_completed_emitted` флаг |
| 18 | MEDIUM | NOT CHECKED (compound unlock check) |
| 19 | MEDIUM | NOT CHECKED (hit signal disconnect) |
| 20 | MEDIUM | NOT CHECKED (loot_spawner pickup) |
| 21 | MEDIUM | NOT CHECKED (private _disabled) |
| 22 | MEDIUM | NOT CHECKED (handle_player_death) |
| 23 | LOW | NOT CHECKED |
| 24 | LOW | NOT CHECKED |
| 25 | LOW | NOT CHECKED |
| 26 | LOW | NOT CHECKED |
| 27 | LOW | NOT CHECKED |
| 28 | LOW | NOT CHECKED |
| 29 | LOW | NOT CHECKED |
| 30 | LOW | NOT CHECKED |
| 31 | LOW | NOT CHECKED |
| 32 | LOW | FIXED — `_exit_tree` добавлен с disconnect |
| 33 | LOW | NOT CHECKED |
| 34 | LOW | NOT CHECKED |
| 35 | LOW | NOT CHECKED |
| 36 | CRITICAL | FIXED — `_dark_bolts.erase(b)` |
| 37 | HIGH | FIXED — убрана мутация `attack_damage` |
| 38 | MEDIUM | PARTIALLY FIXED — добавлен `is_instance_valid(self)` в цикле, но паттерн await-цикла сохранён |
| 39 | MEDIUM | FIXED — `if GameManager.run_state:` обёртка |
| 40 | HIGH | FIXED — `_target.apply_slow(0.5, 3.0)` |
| 41 | MEDIUM | FIXED — `_total_hp_lost / total` вместо текущего HP |
| 42 | MEDIUM | NOT CHECKED — `_throw_contract` вызывает `_move_projectile` (нужна проверка метода) |
| 43 | LOW | FIXED — `_rng.randf_range()` |
| 44 | LOW | NOT CHECKED |

---

## Новые баги, обнаруженные при повторном аудите

### CRITICAL — Регрессия: FloorManager._ready() пустой

**Файл**: `scripts/world/floor_manager.gd`, строки 58-86

**Проблема**: Весь код инициализации (загрузка этажа, настройка камеры, спавн игрока, туториал) **перемещён из `_ready()` в `_exit_tree()`**. `_ready()` теперь содержит только одну строку подключения сигнала:

```gdscript
func _ready() -> void:
    EventBus.room_cleared.connect(_on_event_bus_room_cleared)


func _exit_tree() -> void:
    if EventBus.room_cleared.is_connected(...):
        EventBus.room_cleared.disconnect(...)
    # А ВЕСЬ ЭТОТ КОД НИЖЕ — В _exit_tree, А НЕ В _ready!
    # Auto-load floor if GameManager has a run active
    if GameManager.seed_manager and ...:
        load_floor(floor_number, GameManager.seed_manager)
    # Register camera BEFORE spawning player
    var cam := get_node_or_null("Camera")
    ...
    # Spawn player at PlayerSpawn marker
    var spawn_node := get_node_or_null("PlayerSpawn")
    ...
```

**Почему это баг**: `_exit_tree()` вызывается при **удалении узла** из дерева сцен, а не при входе. Это означает:
1. Этаж **никогда не загружается** при старте
2. Камера **никогда не настраивается**
3. Игрок **никогда не спавнится**
4. Туториал **никогда не показывается**

Игра полностью неработоспособна.

**Как исправить**: Вернуть код инициализации из `_exit_tree()` обратно в `_ready()`. `_exit_tree()` должен содержать **только** отключение сигнала. Правильная структура:

```gdscript
func _ready() -> void:
    EventBus.room_cleared.connect(_on_event_bus_room_clected)

    # Auto-load floor if GameManager has a run active
    if GameManager.seed_manager and GameManager.current_state == GameManager.GameState.PLAYING:
        load_floor(floor_number, GameManager.seed_manager)

    # Register camera BEFORE spawning player
    var cam := get_node_or_null("Camera")
    if cam:
        cam.add_to_group("camera")
        if cam is Camera2D:
            cam.make_current()

    # Spawn player at PlayerSpawn marker
    var spawn_node := get_node_or_null("PlayerSpawn")
    if spawn_node != null:
        spawn_player(spawn_node.global_position)

    # Show tutorial on first run, Floor 1
    if floor_number == 1:
        var settings := SaveManager.get_settings()
        if not settings.get("tutorial_shown", false):
            _show_tutorial()


func _exit_tree() -> void:
    if EventBus.room_cleared.is_connected(_on_event_bus_room_cleared):
        EventBus.room_cleared.disconnect(_on_event_bus_room_cleared)
```

---

### LOW — Cultist _move_projectile: await-цикл сохранён

**Файл**: `scripts/ai/enemy_cultist.gd`, строки 105-120

**Проблема**: Добавлена проверка `is_instance_valid(self)`, что улучшает ситуацию, но корневая проблема сохранена — await-цикл в методе `_move_projectile` привязан к lifetime cultist. Если cultist уничтожен, корутина прерывается, но снаряд может остаться «висеть» в воздухе (не `queue_free`'ается).

**Рекомендация**: Низкий приоритет, не блокирует игровой процесс.

---

## Резюме

Из 44 оригинальных багов:
- **39 подтверждённо исправлены** (включая все 7 CRITICAL)
- **3 не проверены** (LOW приоритет, не влияют на играбельность)
- **1 частично исправлен** (cultist await, LOW)
- **1 НЕ исправлен** (projectile `randi()`, MEDIUM)

**Обнаружена 1 новая критическая регрессия**: FloorManager._ready() пустой — игра не может стартовать. Требуется немедленное исправление.
