# Баги проекта Godot (результаты статического анализа)

---

## Критичные (CRITICAL)

### 1. [Файл: scripts/ai/base_enemy.gd, строки ~221-227 + scripts/combat/damage_zones.gd, строка 39]
**Проблема**: Механика полного расчленения (dismemberment-disable) **никогда не сработает**. `DamageZone.all_limbs()` возвращает `[HEAD, LEFT_ARM, RIGHT_ARM, LEFT_LEG, RIGHT_LEG]` — HEAD включён. Но `is_limb(HEAD)` возвращает `false`, поэтому голова **никогда не отрезается** → `severed_limbs[HEAD]` всегда `false` → `all_severed` всегда `false` → враг **никогда не disable'ится** через полную потерю конечностей.

**Почему это баг**: Ключевая игровая механика расчленения полностью сломана на уровне данных. Враг с отрезанными всеми конечностями + торс < 30% HP остаётся «живым» бесконечно, пока торс не убьют.

**Как исправить**: Либо убрать HEAD из `all_limbs()` и проверять только 4 конечности, либо добавить HEAD в `is_limb()` (если голова должна отрезаться). Рекомендация — первый вариант:
```gdscript
# damage_zones.gd:38 — убрать HEAD из all_limbs
static func all_limbs() -> Array[int]:
    return [Zone.LEFT_ARM, Zone.RIGHT_ARM, Zone.LEFT_LEG, Zone.RIGHT_LEG]
```

---

### 2. [Файл: scripts/combat/gore_system.gd, строки ~34]
**Проблема**: Безусловный `return` на строке 34 делает **весь код создания полноценных отрезанных конечностей через `limb_scene` недостижимым**. Даже когда `limb_scene` загружен (строки 36-55), код никогда не выполнится.

```gdscript
# Строка 32-34:
if not limb_scene:
    _create_placeholder_limb(position, limb_type, owner)
    return    # <-- этот return выполняется и когда limb_scene != null? НЕТ
return         # <-- СТРОКА 34: ЭТОТ RETURN ДЕЛАЕТ СТРОКИ 36+ НЕДОСТИЖИМЫМИ
var limb = limb_scene.instantiate()  # UNREACHABLE CODE
```

**Почему это баг**: Отрезанные конечности всегда создаются через placeholder (ColorRect), даже если подготовлены нормальные сцены. Визуально это будет выглядеть как цветные прямоугольники вместо полноценных спрайтов.

**Как исправить**: Удалить строку `return` (строка 34). Код должен провалиться в `instantiate()` когда `limb_scene` не null.

---

### 3. [Файл: scripts/combat/weapon_manager.gd + scripts/core/game_manager.gd + scripts/player/player_controller.gd]
**Проблема**: **Полный разрыв синхронизации оружия** между тремя системами:
- `run_state.weapon_slots` (сохранение/загрузка)
- `weapon_manager.equipped` (реальное использование)
- `HUD` читает `run_state.weapon_slots` (отображение)

`GameManager.start_new_run()` вызывает `LootSpawner.give_starting_loadout(run_state)` который пишет в `run_state.weapon_slots[0/1]`. Но `WeaponManager._ready()` инициализирует `equipped = [null, null]` и **никогда не читает из `run_state.weapon_slots`**. Итог: игрок начинает без оружия.

**Почему это баг**: При старте забега игрок не может атаковать. При загрузке сохранения — то же самое. HUD показывает оружие, но реально его нет.

**Как исправить**: В `WeaponManager._ready()` добавить синхронизацию из run_state:
```gdscript
func _ready() -> void:
    # ... existing code ...
    # Sync from run_state
    if GameManager.run_state:
        for i in range(mini(GameManager.run_state.weapon_slots.size(), max_slots)):
            equipped[i] = GameManager.run_state.weapon_slots[i]
            if equipped[i] != null and equipped[i].ammo > 0:
                var ammo_bonus := 1.0 + float(GameManager.run_state.stat_upgrades.get("ammo_bonus", 0.0))
                _ammo[i] = ceili(equipped[i].ammo * ammo_bonus)
            else:
                _ammo[i] = -1
        active_slot = GameManager.run_state.active_slot
```

---

### 4. [Файл: scripts/core/seed_manager.gd, строки 57 и 64]
**Проблема**: `get_room_loot_config()` и `get_gate_config()` **мутируют seed закэшированных RNG**, что навсегда ломает детерминизм:
```gdscript
# Строка 57: мутирует кэшированный RNG комнаты
rng.seed += 999

# Строка 64: мутирует кэшированный RNG этажа
rng.seed += 777
```

**Почему это баг**: Повторный запуск с тем же seed'ом даёт другие результаты, если вызовы происходят в другом порядке или повторяются. Это ломает основное назначение SeedManager — воспроизводимость забегов.

**Как исправить**: Не мутировать кэшированный RNG. Создавать копию:
```gdscript
func get_room_loot_config(...) -> Dictionary:
    var rng := get_room_rng(floor_number, room_index)
    var loot_rng := RandomNumberGenerator.new()
    loot_rng.seed = rng.seed + 999  # Offset без мутации оригинала
    # ... use loot_rng instead of rng ...
```
Аналогично для `get_gate_config`.

---

### 5. [Файл: scripts/world/floor_manager.gd, строки 408-435]
**Проблема**: `_on_pickup_collected()` **не выдаёт игроку подобранные предметы**. При подборе оружия/апгрейда/артефакта только печатается лог, но нет вызова `weapon_manager.equip_weapon()` или `run_state.apply_upgrade()`. Сигналы `upgrade_collected` и `artifact_collected` эмитятся с `null` вместо ресурса.

**Почему это баг**: Подбор лута в комнатах полностью косметический — игрок не получает оружие, апгрейды или артефакты.

**Как исправить**: Добавить реальную логику подбора в `_on_pickup_collected`:
```gdscript
func _on_pickup_collected(body: Node2D, pickup: Area2D) -> void:
    if not body.is_in_group("player"): return
    var loot_type: String = pickup.get_meta("loot_type", "")
    var loot_id: String = pickup.get_meta("loot_id", "")
    match loot_type:
        "weapon":
            var path := "res://resources/weapons/%s.tres" % loot_id
            if ResourceLoader.exists(path):
                var weapon: WeaponData = load(path)
                # Find player's weapon manager and equip
                var player := get_tree().get_first_node_in_group("player")
                if player and player.has_node("WeaponManager"):
                    player.get_node("WeaponManager").equip_weapon(weapon)
        "stat_upgrade":
            if UpgradeRegistry:
                var upg := UpgradeRegistry.get_upgrade(loot_id)
                if upg and GameManager.run_state:
                    GameManager.run_state.apply_upgrade(upg)
                    EventBus.upgrade_collected.emit(upg)
        "cult_artifact":
            if ArtifactRegistry and loot_id == "random":
                var rng := RandomNumberGenerator.new()
                var art := ArtifactRegistry.get_random_artifact({1:0.3,2:0.5,3:0.2}, rng)
                if art and GameManager.run_state:
                    GameManager.run_state.apply_artifact(art)
                    EventBus.artifact_collected.emit(art)
            elif ArtifactRegistry:
                var art := ArtifactRegistry.get_artifact(loot_id)
                if art and GameManager.run_state:
                    GameManager.run_state.apply_artifact(art)
                    EventBus.artifact_collected.emit(art)
        "ammo":
            # Refill active weapon ammo
            var player := get_tree().get_first_node_in_group("player")
            if player and player.has_node("WeaponManager"):
                var wm: Node2D = player.get_node("WeaponManager")
                # Access _ammo and refill
                pass  # Requires adding a refill_ammo method to WeaponManager
    pickup.queue_free()
```

---

### 6. [Файл: scripts/ui/hud.gd, строки 142-163]
**Проблема**: `_connect_events()` подключает сигналы через **лямбды** (`func(_a): _update_hp_bar()`), а `_exit_tree()` пытается отключить их через **прямые ссылки на методы** (`_update_hp_bar`). Это разные callable-объекты — disconnect **всегда падает** с ошибкой.

**Почему это баг**: При каждой смене сцены, где HUD уничтожается, в лог сыплется `disconnect()` failed. Также возможны утечки соединений — HUD-обработчики продолжают вызываться для уничтоженного узла.

**Как исправить**: Сохранять лямбды в переменные и использовать их для disconnect:
```gdscript
var _conn_damaged: Callable
var _conn_healed: Callable
# и т.д.

func _connect_events() -> void:
    _conn_damaged = func(_a): _update_hp_bar()
    EventBus.player_damaged.connect(_conn_damaged)
    # ...

func _exit_tree() -> void:
    if EventBus.player_damaged.is_connected(_conn_damaged):
        EventBus.player_damaged.disconnect(_conn_damaged)
    # ...
```

---

## Высокий приоритет (HIGH)

### 7. [Файл: scripts/ai/base_enemy.gd, строки ~230-237]
**Проблема**: `_on_limb_lost()` **мультипликативно уменьшает скорость** при каждой потере конечности, вместо установки абсолютного значения. Если потеряна левая нога: `speed *= 0.5`. Затем правая: `speed *= 0.15` → итог `original * 0.075` вместо `original * 0.15`.

**Почему это баг**: Скорость врага после потери двух ног = 7.5% от оригинала вместо 15%, что делает практически неподвижного врага ещё медленнее. Регенерация при этом использует абсолютные значения, создавая несогласованность.

**Как исправить**: Использовать абсолютные значения, как в `_regenerate_limb`:
```gdscript
func _on_limb_lost(zone: int) -> void:
    var lost_legs := int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + int(severed_limbs[DamageZone.Zone.RIGHT_LEG])
    match lost_legs:
        1: move_speed = _initial_move_speed * 0.5
        2: move_speed = _initial_move_speed * 0.15
    # ...
```

---

### 8. [Файл: scripts/ai/base_enemy.gd, строки 133 + 408]
**Проблема**: `_state_timer` декрементируется **дважды** за кадр в состоянии "alert" — один раз в `_physics_process` (строка 133: `_state_timer -= delta`) и один раз в `_state_alert` (строка 408: `_state_timer -= delta`). Длительность alert (1.0s) **фактически = 0.5s**.

**Почему это баг**: Враги переходят из alert в chase/патруль в два раза быстрее, чем задумано. Это влияет на баланс — игрок получает меньше времени на реакцию.

**Как исправить**: Убрать декремент из `_state_alert()` (строка 408), оставив только общий в `_physics_process`.

---

### 9. [Файл: scripts/effects/object_pool.gd, строки 44-48]
**Проблема**: Когда instance из пула невалиден и `_active.size() < _max_size`, код вызывает `_expand()` (который создаёт новый instance и добавляет в `_pool`), а **затем** создаёт ещё один instance через `_scene.instantiate()` и `add_child` **без добавления в `_pool`**. Этот «осиротевший» instance не отслеживается.

**Почему это баг**: Утечка памяти — каждый раз при невалидном instance в пуле создаётся один лишний узел, который никогда не будет возвращён в пул или очищен.

**Как исправить**: Убрать дублирующий instantiate:
```gdscript
if not is_instance_valid(instance):
    if _active.size() < _max_size:
        _expand()
        instance = _pool.pop_back()  # Берём только что созданный
    else:
        return null
```

---

### 10. [Файл: scripts/core/game_scene.gd, строки 105-108]
**Проблема**: Tween для пульсации виньетки создаётся с `set_loops()` (бесконечный цикл) и **никогда не убивается** при восстановлении HP. Если HP поднимется выше 30%, бесконечный tween продолжает выполняться, что приведёт к утечке и визуальным артефактам.

**Почему это баг**: Накопление «зомби»-tween'ов при многократных падениях/восстановлениях HP. Виньетка может мигать даже когда HP уже высокий.

**Как исправить**: Хранить tween в переменной и убивать перед созданием нового:
```gdscript
var _vignette_pulse_tween: Tween = null

# В _show_low_hp_vignette:
if _vignette_pulse_tween and _vignette_pulse_tween.is_valid():
    _vignette_pulse_tween.kill()
_vignette_pulse_tween = vignette.create_tween()
# ...
```

---

### 11. [Файл: scripts/core/game_scene.gd, строка 75]
**Проблема**: `vignette_layer.layer = -1` — CanvasLayer с layer=-1 рендерится **за** всем контентом, а не поверх. Виньетка низкого HP не будет видна.

**Почему это баг**: Визуальная обратная связь при низком HP полностью невидима.

**Как исправить**: Изменить на layer > 0, например `layer = 50` (но меньше чем у ScreenEffects на 100).

---

### 12. [Файл: scripts/player/player_controller.gd, строки 194-197]
**Проблема**: `apply_slow()` восстанавливает `_current_speed = base_speed` после окончания замедления, **игнорируя апгрейды скорости** из `run_state`.

**Почему это баг**: После любого замедления (масло, яд и т.д.) скорость игрока сбрасывается до базовой 200, теряя все накопленные бонусы скорости.

**Как исправить**: Восстанавливать из run_state:
```gdscript
func apply_slow(mult: float, duration: float) -> void:
    _current_speed = base_speed * mult
    get_tree().create_timer(duration).timeout.connect(func() -> void:
        if is_instance_valid(self):
            _current_speed = GameManager.run_state.player_speed if GameManager.run_state else base_speed
    )
```

---

### 13. [Файл: scripts/combat/thrown_weapon.gd, строки 222-229 и 279-283]
**Проблема**: `_apply_embed()` и `_apply_tangle()` используют мультипликативное замедление `move_speed *= 0.6` / `*= 0.5` с последующим делением для восстановления. Если два оружия одновременно замедляют врага, восстановление одного даёт некорректную скорость.

**Почему это баг**: Два встроенных топора: speed = orig * 0.6 * 0.6 = 0.36x. Первый таймер: 0.36/0.6 = 0.6x (вместо 0.6x от оригинала). Накопление/восстановление несогласовано.

**Как исправить**: Хранить оригинальную скорость и устанавливать абсолютное значение:
```gdscript
func _apply_embed(target: Node2D) -> void:
    if target is CharacterBody2D and "move_speed" in target:
        if not target.has_meta("_original_speed"):
            target.set_meta("_original_speed", target.move_speed)
        target.move_speed = target.get_meta("_original_speed") * 0.6
        get_tree().create_timer(7.0).timeout.connect(func():
            if is_instance_valid(target) and target.has_meta("_original_speed"):
                target.move_speed = target.get_meta("_original_speed")
                target.remove_meta("_original_speed")
            # ...
        )
```

---

### 14. [Файл: scripts/core/run_state.gd, строки 40-49 + 196-243]
**Проблема**: `RunState._init()` подключается к EventBus. `from_dict()` вызывает `script.new()`, что снова вызывает `_init()` → подключает сигналы. Если старый RunState не прошёл `cleanup()`, оба экземпляра реагируют на события → двойной счётчик, двойные статы.

**Почему это баг**: При загрузке сохранения или любом сценарии с двумя RunState — счётчики achivement'ов удваиваются. В худшем случае — ещё большие утечки соединений.

**Как исправить**: В `from_dict()` не использовать `script.new()` (который вызывает `_init`), а создавать через `RunState.new()` напрямую и вручную устанавливать поля. Или гарантировать `cleanup()` перед созданием нового RunState.

---

### 15. [Файл: scripts/ui/hud.gd, строки 235-238]
**Проблема**: Код обращается к `weapon.max_ammo` и `weapon.current_ammo`, но `WeaponData` имеет только `ammo` (int). Свойств `max_ammo` и `current_ammo` **не существует**. Это вызовет ошибку во время выполнения.

**Почему это баг**: HUD крашится при попытке отобразить боеприпасы для оружия. В лучшем случае — exception в логе, в худшем — визуальный баг.

**Как исправить**: Использовать `weapon.ammo` вместо `weapon.max_ammo`. Для текущего количества боеприпасов читать из WeaponManager (потребует добавить публичный метод).

---

## Средний приоритет (MEDIUM)

### 16. [Файл: scripts/combat/projectile.gd, строка 90]
**Проблема**: `_pick_random_limb()` использует глобальный `randi()` вместо seed-основанного RNG. Это ломает детерминизм забегов.

**Как исправить**: Передавать RNG извне или создать локальный seeded RNG в `setup()`.

---

### 17. [Файл: scripts/world/floor_manager.gd, строки 468-483]
**Проблема**: На Floor 9 при победе над Sister (boss1) эмитится `mini_boss_defeated`, но при победе над Satan (boss2) эмитится `floor_completed`. Однако код на строке 468 проверяет `rid == "boss1"` — если boss1 был побеждён, а boss2 ещё нет, `mini_boss_defeated` эмитится корректно. Но строка 475: `if rid == "boss" or (rid == "boss2")` — скобки избыточны, но не баг. Реальная проблема: при `rid == "boss"` на этажах 1-8, `floor_completed` эмитится и `mini_boss_defeated` НЕТ — это правильно. Но если на Floor 9 boss1 уже убит, а игрок возвращается — `_check_clear_progress` может эмитить `floor_completed` повторно при повторном входе.

**Как исправить**: Добавить флаг `_floor_completed_emitted: bool` и проверять его перед эмитом.

---

### 18. [Файл: scripts/core/game_manager.gd, строка 387]
**Проблема**: `_is_unlocked()` проверяет и `_pending_artifact_unlocks.has(id)`, и `_pending_stat_unlocks.has(id)` для ЛЮБОГО id. Если artifact и stat имеют одинаковый id (маловероятно, но возможно), проверка даст ложноположительный результат.

**Как исправить**: Разделить проверки:
```gdscript
func _is_unlocked(unlocked_list: Array, id: String) -> bool:
    return unlocked_list.has(id)
```
И передавать нужный pending-список отдельно в местах вызова.

---

### 19. [Файл: scripts/combat/weapon_manager.gd, строки 100-104 и 137-141]
**Проблема**: При повторном использовании объекта из пула, старые лямбды отключаются через `disconnect(conn.callable)`. Но если предыдущий `hit`-сигнал уже был обработан и лямбда удалена, массив `get_connections()` может быть пуст, что OK. Проблема в том, что при _return_to_pool в MeleeHit/Projectile **сигнал hit не отключается**, только area_entered/body_entered. Старые hit-соединения накапливаются.

**Как исправить**: В `_return_to_pool()` MeleeHit и Projectile также отключать все соединения сигнала `hit`.

---

### 20. [Файл: scripts/world/loot_spawner.gd, строки 244-280]
**Проблема**: `_create_pickup_node()` создаёт Area2D, но **не подключает `body_entered`** для подбора. Pickup'ы созданные через LootSpawner (в отличие от FloorManager._create_pickup) не имеют обработчика подбора — они визуальные.

**Как исправить**: Добавить `pickup.body_entered.connect(...)` с логикой подбора, или делегировать в FloorManager через сигнал.

---

### 21. [Файл: scripts/world/room_instance.gd, строки 131 и 151]
**Проблема**: `check_cleared()` и `_check_wave_cleared()` обращаются к приватному полю `enemy._disabled` напрямую. Это хрупкая связь — если поле будет переименовано или инкапсулировано, код сломается.

**Как исправить**: Добавить публичный метод в base_enemy.gd:
```gdscript
func is_disabled() -> bool:
    return _disabled
```

---

### 22. [Файл: scripts/core/game_manager.gd, строки 127-133]
**Проблема**: `handle_player_death()` устанавливает `current_state = GameState.BASEMENT` (строка 130) как защиту от повторного входа, но затем вызывает `transition_to_basement()` который **снова** устанавливает `current_state = GameState.BASEMENT` (строка 137). Это не баг, но при определённых условиях race condition (например, если игрок умирает во время transition) состояние может быть некорректным. Кроме того, `player_died.emit()` и `player_captured.emit()` эмитятся до фактического перехода в basement.

**Как исправить**: Добавить ранний return в `handle_player_death()` если state уже BASEMENT или GAME_OVER.

---

## Низкий приоритет (LOW) / Улучшения, предотвращающие будущие баги

### 23. [Файл: scripts/world/floor_01_config.gd, строки 62-68]
**Проблема**: `_gen_spawn_points()` использует `randf_range()` для дополнительных точек, что **ломает детерминизм**. При одинаковом seed результат будет разный в зависимости от состояния глобального RNG.

**Как исправить**: Передавать seeded RNG как параметр или убрать рандомизацию из статического генератора.

---

### 24. [Файл: scripts/ai/base_enemy.gd, строка 534]
**Проблема**: `_alert_nearby()` читает приватное поле `body._current_state` другого объекта. В GDScript это работает, но нарушает инкапсуляцию и хрупко к рефакторингу.

**Как исправить**: Использовать публичный метод `body.is_in_state("patrol")` или `body.is_patrolling()`.

---

### 25. [Файл: scripts/combat/thrown_weapon.gd, строки 87 + 112]
**Проблема**: При попадании врага создаётся timer `get_tree().create_timer(3.0).timeout.connect(_return_to_pool)`, а при попадании в стену — `get_tree().create_timer(5.0).timeout.connect(_return_to_pool)`. Если оба таймера сработают (например, после bounce), `_return_to_pool` вызовется дважды.

**Как исправить**: Проверять `visible` в начале `_return_to_pool` или использовать `_has_hit` флаг.

---

### 26. [Файл: scripts/effects/screen_effects.gd, строка 117]
**Проблема**: `hit_stop()` использует `await`, что делает метод асинхронным. Если `hit_stop()` вызывается из `_physics_process`, это может привести к неожиданному поведению, так как вызывающая функция тоже становится асинхронной. В текущем коде вызывается из `base_enemy.receive_damage` (не из _physics_process), так что это OK, но при будущих изменениях может стать проблемой.

**Как исправить**: Использовать callback вместо await, или задокументировать, что метод должен вызываться только из не-physics контекста.

---

### 27. [Файл: scripts/combat/hazard_zone.gd, строки 17-23]
**Проблема**: `_ready()` создаёт **новый** CollisionShape2D программно. Если HazardZone используется из .tscn сцены с уже привязанным CollisionShape2D, будет дублирование коллизий.

**Как исправить**: Проверять наличие существующего CollisionShape2D перед созданием нового.

---

### 28. [Файл: scripts/world/basement_manager.gd, строки 92-105]
**Проблема**: `_on_exit_reached` вызывает `GameManager.handle_basement_success()`, затем `GameManager.transition_to_floor(source_floor)`, а затем делает `get_tree().change_scene_to_file()`. Но `transition_to_floor()` уже делает `change_scene_to_file()`. Итого — **двойная смена сцены** в одном кадре.

**Как исправить**: Убрать один из `change_scene_to_file` вызовов. `handle_basement_success()` только эмитит сигналы и сохраняет, `transition_to_floor()` уже переключает сцену.

---

### 29. [Файл: scripts/world/basement_manager.gd, строки 98-100]
**Проблема**: `_random_bonus_artifact()` при fast clear пытается дать случайный артефакт через `ArtifactRegistry.get_random_artifact()`. Но возвращаемый артефакт может быть уже имеющимся у игрока. `run_state.add_artifact()` добавит дубликат.

**Как исправить**: Проверять `run_state.has_artifact()` перед добавлением, или фильтровать уже собранные.

---

### 30. [Файл: scripts/ui/pause_menu.gd, строки 63-65]
**Проблема**: `_on_resume()` вызывает `GameManager.unpause_game()` и затем `queue_free()`. Но `unpause_game()` возобновляет `_physics_process`, и если пауза была вызвана не из PLAYING-состояния (edge case), unpause не сработает, а меню всё равно закроется.

**Как исправить**: Добавить проверку `current_state == PAUSED` перед unpause.

---

### 31. [Файл: scripts/core/save_manager.gd, строки 150-154]
**Проблема**: `_apply_settings()` обращается к `ScreenEffects` как глобальному имени. Если autoload ScreenEffects ещё не загружен при вызове (зависит от порядка загрузки), будет runtime error. Аналогично с `GoreSystem` и `AudioManager` в других местах.

**Как исправить**: Использовать `get_node_or_null("/root/ScreenEffects")` или `Engine.get_singleton("ScreenEffects")` вместо прямого имени. Либо убедиться, что autoload order корректен в project.godot.

---

### 32. [Файл: scripts/world/floor_manager.gd, строки 57-62]
**Проблема**: `_ready()` подключает `EventBus.room_cleared`, но не отключает при выходе. При смене этажа старый FloorManager может остаться в памяти (если не freed), и его обработчик продолжит вызываться.

**Как исправить**: Добавить `_exit_tree()` с disconnect.

---

### 33. [Файл: scripts/combat/gore_system.gd, строки 160-163]
**Проблема**: Бlood droplet RigidBody2D подключает `body_entered` сигнал **до** добавления в дерево (`add_child`). В Godot 4 сигналы физики не работают пока узел не в дереве, но если `add_child` происходит в том же кадре — это OK. Однако при определённых условиях (если `add_child` отложен) сигнал может не сработать.

**Как исправить**: Переместить `add_child` перед подключением сигнала `body_entered`, или использовать `call_deferred` для подключения.

---

### 34. [Файл: scripts/combat/weapon_manager.gd, строки 88-104]
**Проблема**: `melee_attack()` перемещает hit-объект из пула в `current_scene` через `remove_child/add_child`. При частых атаках это может приводить к фрагментации дерева сцены и потенциальным проблемам с z-order.

**Как исправить**: Рассмотреть альтернативный подход — оставлять pooled объекты в контейнере пула и только менять их global_position.

---

### 35. [Файл: scripts/core/run_state.gd, строки 90-97]
**Проблема**: `apply_stat_upgrade()` вычисляет `stack_count` как `current / _base_value(stat_name)`. Но при нестандартных значениях (например, если первое сложение дало не кратное base_value число из-за diminishing returns), вычисление `stack_count` будет неточным.

**Как исправить**: Использовать явный счётчик стаков (который уже есть: `_upgrade_stack_counts`) вместо вычисления через деление.

---

### 36. [Файл: scripts/ai/enemy_demon.gd, строка ~340]
**Проблема**: **Опечатка в названии метода**: `_dark_bolts.er(b)` вместо `_dark_bolts.erase(b)`. Метод `.er()` не существует — это вызовет **runtime crash** каждый раз когда тёмный снаряд демона попадает в цель или истекает.

**Почему это баг**: Любой демон на Floor 9 крашит игру при первом удалении снаряда.

**Как исправить**: Заменить `_dark_bolts.er(b)` на `_dark_bolts.erase(b)`.

---

### 37. [Файл: scripts/ai/enemy_cultist.gd, строки ~70-73]
**Проблема**: `_perform_attack()` временно устанавливает `attack_damage = 12.0` при ranged атаке, но **никогда не восстанавливает** оригинальное значение (18.0). После первого ranged броска все последующие melee-атаки используют 12.0 урона навсегда.

**Как исправить**: Не модифицировать `attack_damage` напрямую. Использовать отдельную переменную для ranged урона, или восстановить после атаки.

---

### 38. [Файл: scripts/ai/enemy_cultist.gd, строки ~114-133]
**Проблема**: `_move_projectile()` использует `await get_tree().process_frame` в while-цикле. Если Cultist будет уничтожен (queue_free) пока снаряд ещё летит, корутина продолжит выполнение и крашнется при обращении к freed узлу. Проверка `is_instance_valid(bolt)` есть, но self (cultist) уже невалиден.

**Как исправить**: Сделать `_move_projectile` независимым — проверить `is_instance_valid(self)` в цикле, или перенести движение снаряда в его собственный `_process`.

---

### 39. [Файл: scripts/ai/boss_sister.gd, строки 288-289]
**Проблема**: Строка 288 обращается к `GameManager.run_state.mini_boss_defeated[9]` без null-check, а строка 289 делает `true if GameManager.run_state else null` — но если `run_state` == null, краш произойдёт на строке 288 ДО выполнения строки 289. Троичный оператор бесполезен.

**Как исправить**: Обернуть обе строки в `if GameManager.run_state:`.

---

### 40. [Файл: scripts/ai/boss_satan.gd, строки 364-374]
**Проблема**: `_fiscal_year()` проверяет `"move_speed" in _target` для замедления игрока. Но `player_controller.gd` использует `_current_speed`, а не `move_speed`. Проверка возвращает `false`, и замедление **никогда не применяется** к игроку.

**Как исправить**: Заменить на вызов публичного метода `apply_slow()` на игроке:
```gdscript
func _fiscal_year() -> void:
    if _target and _target.has_method("apply_slow"):
        _target.apply_slow(0.5, 3.0)
```

---

### 41. [Файл: scripts/ai/boss_satan.gd, строки 168-181]
**Проблема**: `_update_phase()` вычисляет фазу на основе `limb_health[TORSO]`, который может **восстанавливаться** через регенерацию. Это позволяет Сатане **откатываться из Phase 2/3 обратно в Phase 1**, если торс регенерирует. Это нарушает дизайн «прогрессивного усиления» босса.

**Как исправить**: Использовать `_total_hp_lost` для определения фазы (отслеживать совокупный урон), либо запретить регенерацию торса у Сатаны.

---

### 42. [Файл: scripts/ai/boss_satan.gd, строки 270-294]
**Проблема**: `_throw_contract()` создаёт Area2D и добавляет в сцену, но **не настраивает обнаружение коллизий**. Снаряд визуально летит (`_move_projectile`), но не имеет `body_entered` подключения или `area_entered` — он никогда не нанесёт урон.

**Как исправить**: Добавить подключение сигнала `area_entered` или `body_entered` к снаряду для обработки попадания.

---

### 43. [Файл: scripts/ai/boss_satan.gd, строки 314, 360]
**Проблема**: `_summon_demon()` и `_reality_warp()` используют глобальный `randf_range()` вместо seeded `_rng`. Это ломает детерминизм забегов при одних и тех же seed'ах.

**Как исправить**: Использовать `_rng.randf_range()` вместо глобального `randf_range()`.

---

### 44. [Файл: scripts/ai/boss_sister.gd, строки 214-219]
**Праблема**: Выбор пути использует `Input.is_key_pressed(KEY_1/2/3)` — это **непрерывная** проверка (каждый кадр пока удерживается), а не `is_physical_key_pressed` или action-проверка. Если игрок удерживает «1» ещё до входа в фазу Confrontation, выбор сработает мгновенно на первом кадре фазы 2.

**Как исправить**: Использовать `Input.is_physical_key_pressed(KEY_1)` с однократным флагом, или определить Input Actions для выбора.

---

*Аудит проведён по результатам статического анализа всех ~100+ GDScript файлов проекта. Дата: 2026-05-12*
