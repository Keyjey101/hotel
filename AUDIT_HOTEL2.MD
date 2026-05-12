# Баги проекта Godot (результаты статического анализа)

---

## Критичные (CRITICAL)

### 1. [Файл: scripts/ui/game_over_screen.gd, строки 115-117]
**Проблема**: Кнопка "MAIN MENU" вызывает `GameManager.restart_run()` вместо `GameManager.go_to_title()`. Обе кнопки ("TRY AGAIN" и "MAIN MENU") выполняют одно и то же действие — перезапуск ранна. Игрок **никогда не может вернуться в главное меню** с экрана Game Over.
**Почему это баг**: `_on_quit_pressed` (строка 115) и `_on_restart_pressed` (строка 110) идентичны — оба вызывают `GameManager.restart_run()`.
**Как исправить**: В `_on_quit_pressed()` заменить `GameManager.restart_run()` на `GameManager.go_to_title()`.

### 2. [Файл: scripts/ui/dialog_choice.gd, строки 14-25]
**Проблема**: Каждый вызов `setup()` подключает сигналы `pressed` к кнопкам `_option1` и `_option2` **без предварительного отключения** предыдущих подключений. При повторном вызове `setup()` (повторное использование диалога) сигналы стекаются — одно нажатие вызывает N обработчиков (где N — количество вызовов `setup()`).
**Почему это баг**: Накопленные лямбды вызовут множественные `EventBus.dialog_choice_made.emit()` и `queue_free()`, приводя к двойной/тройной обработке выбора и ошибкам при повторном `queue_free()`.
**Как исправить**: В начале `setup()` отключить все предыдущие подключения:
```gdscript
for conn in _option1.pressed.get_connections():
    _option1.pressed.disconnect(conn.callable)
for conn in _option2.pressed.get_connections():
    _option2.pressed.disconnect(conn.callable)
```

### 3. [Файл: scripts/ai/enemy_guard.gd, строка ~69]
**Проблема**: `_partner.has_method("_target")` — `_target` это **переменная**, а не метод. `has_method("_target")` **всегда возвращает false**. Вся логика фланкирования (if-блок на строке 69) **никогда не выполняется**.
**Почему это баг**: Guard-ы никогда не фланкируют игрока, а всегда атакуют в лоб. Партнёрство Guard-ов нефункционально.
**Как исправить**: Заменить `_partner.has_method("_target")` на `_partner.get("_target") != null` или просто `_partner._target != null` (после проверки `is_instance_valid`).

### 4. [Файл: scripts/ai/enemy_chef.gd, строки ~286-288]
**Проблема**: Удаление элементов массива `_pan_projectiles` по индексам из `to_remove` **в прямом порядке**. После удаления элемента `i` все последующие индексы сдвигаются, и удаляются не те элементы. Классический off-by-one при удалении из массива.
**Почему это баг**: Приводит к тому, что некоторые pan-снаряды остаются в массиве как freed-узлы. При следующей итерации `_process_pan_projectiles` — crash при обращении к freed-узлу.
**Как исправить**: Итерировать `to_remove` в **обратном порядке** (`for i in range(to_remove.size() - 1, -1, -1)`) или использовать `erase()` вместо удаления по индексу.

### 5. [Файл: scripts/ai/boss_curator.gd, строка ~483]
**Проблема**: `_create_shadow_clone` загружает `boss_curator.tscn` и инстанцирует完整的 босса. Клон проходит через `_ready()`, который создаёт fog patches, визуалы, и потенциально спавнит spy-врагов. Это **рекурсивная инициация** — клон ведёт себя как полный босс, а не урезанный клон.
**Почему это баг**: Установка метаданных/статистики после `_ready()` не предотвращает побочные эффекты инициализации. Клон создаст собственные fog patches, визуальные элементы и может заспавнить дополнительных врагов.
**Как исправить**: Создать отдельную упрощённую сцену `curator_clone.tscn` без `_ready()` логики босса, или установить флаг `is_clone = true` **перед** `add_child()`, и проверять его в `_ready()`.

### 6. [Файл: scripts/world/basement_manager.gd, строки 59-77]
**Проблема**: `_process(delta)` декрементирует таймер **сразу при загрузке сцены**, ещё до вызова `enter_basement()`. Через ~60 секунд после загрузки сцены подвала (даже если игрок не вошёл), `reinforcements_spawned` становится true и вызывается `_spawn_reinforcements(2)` — враги спавнятся в невидимом подвале. Также `print` на строке 77 спамит каждый кадр когда `timer <= 10.0`.
**Почему это баг**: Спавн врагов в невидимой сцене + консольный спам. При реальном входе в подвал враги уже заспавнены, и повторный спавн может превысить лимит.
**Как исправить**: Добавить флаг `_basement_active: bool = false`, устанавливать в `true` в `enter_basement()`, и проверять в `_process()`: `if not _basement_active: return`.

---

## Высокий приоритет (HIGH)

### 7. [Файл: scripts/ai/boss_madame.gd, строки 653-680]
**Проблема**: `_continue_shard` создаёт рекурсивную цепочку таймеров. При отключении (строки 852-856) попытка `t.timeout.is_connected(_continue_shard)` **не сработает**, потому что реальный callback — `_continue_shard.bind(node, dir, speed, damage, elapsed, max_time)`, а не `_continue_shard`. Отключение проходит молча, но таймеры продолжают стрелять.
**Почему это баг**: После освобождения Madame orphaned-таймеры вызывают `_continue_shard` на freed-ноде — crash.
**Как исправить**: Вместо `is_connected(_continue_shard)` использовать `is_connected(callable)` с той же bind-сигнатурой, или хранить массив Callable-ов, или использовать `t.timeout.disconnect_all()`.

### 8. [Файл: scripts/ai/enemy_handler.gd, строки 43 и 47]
**Проблема**: `player_captured.emit()` вызывается **дважды** в одной функции (строка 43 при наличии союзника, и строка 47 безусловно в конце). Сигнал `player_captured` обрабатывается `GameManager.handle_player_death()`, что приводит к двойной обработке захвата.
**Почему это баг**: Двойной захват — player получает двойной stun/slow или дважды переходит в basement-сцену.
**Как исправить**: Убрать `player_captured.emit()` со строки 43 (дубликат), оставить только на строке 47, или добавить `return` после первого emit.

### 9. [Файл: scripts/ai/enemy_bodyguard.gd, строка 43]
**Проблема**: `EventBus.enemy_damaged.connect(_on_any_enemy_damaged)` подключён в `_ready()`, но **никогда не отключается**. Нет `_exit_tree()` override. При освобождении Bodyguard или смене сцены, обработчик сигнала продолжает вызываться на freed-ноде.
**Почему это баг**: Crash при следующем `enemy_damaged` сигнале после освобождения Bodyguard.
**Как исправить**: Добавить `_exit_tree()` с `EventBus.enemy_damaged.disconnect(_on_any_enemy_damaged)`.

### 10. [Файл: scripts/world/floor_08_config.gd, строка ~353]
**Проблема**: `hazard.get_overlapping_bodies()` вызывается **в том же кадре**, когда hazard добавлен в дерево через `room.add_child(hazard)`. В Godot 4 Area2D требует минимум один physics frame для обнаружения overlapping тел.
**Почему это баг**: AoE-урон от chandeliers **всегда наносит 0 попаданий**. Механика chandelier полностью сломана.
**Как исправить**: Использовать `call_deferred()` или `await get_tree().physics_frame` перед вызовом `get_overlapping_bodies()`, или применить урон в следующем `_physics_process`.

### 11. [Файл: scripts/ai/base_enemy.gd — _on_detection_exited]
**Проблема**: Когда игрок покидает detection_area, `_target` немедленно устанавливается в `null` и враг переходит в patrol. Это происходит даже если игрок всё ещё видим и находится в пределах chase-диапазона — просто вышел за границы detection circle.
**Почему это баг**: Враги "забывают" игрока, когда тот временно выходит за радиус обнаружения, даже если игрок прямо перед ними. Особенно заметно с быстрыми игроками и маленьким detection_radius.
**Как исправить**: Не сбрасывать `_target` в `_on_detection_exited`, если `_target` ещё в поле зрения (raycast проверка) или в пределах chase-расстояния. Сбрасывать только после таймаута потери цели.

### 12. [Файл: scripts/ai/enemy_banker.gd, строки 191-199]
**Проблема**: `_activate_lockdown` захватывает `room` в лямбде таймера (4-секундный таймер). Если room освобождена до срабатывания таймера — crash. В отличие от `boss_accountant.gd`, Banker **не проверяет** `is_instance_valid(room)`.
**Почему это баг**: Crash при смене комнаты/этажа в течение 4 секунд после активации lockdown.
**Как исправить**: Добавить `if not is_instance_valid(room): return` в начало лямбды таймера.

### 13. [Файл: scripts/world/loot_spawner.gd, строки 282-293]
**Проблема**: `_create_pickup_node` подключает `body_entered` к лямбде, которая делегирует `_on_pickup_collected` через `fm._on_pickup_collected(body, pickup)`. Но поиск `fm` идёт через `body.get_tree().current_scene as Node`, что может не быть FloorManager (например, при вложенных сценах). Если `fm` не найден или не имеет метода, pickup просто `queue_free()` без обработки лута.
**Почему это баг**: В некоторых конфигурациях сцены pickup-ы исчезают при касании, не давая лут игроку.
**Как исправить**: Искать FloorManager через tree-walk (как `_find_floor_manager()` в RoomInstance), а не через `current_scene`.

### 14. [Файл: scripts/ai/boss_gourmand.gd, строки 122-123]
**Проблема**: `_physics_process` содержит `if _disabled: return`, что полностью пропускает обработку. При этом не вызывается `super._physics_process()`, где происходит декремент `_disabled_timer` и `_process_regen()`. **Gourmand никогда не оживает после disable.**
**Почему это баг**: Босс с regeneration-механикой не может регенерировать, потому что `_process_regen` никогда не вызывается в disabled-состоянии. Это убивает дизайн-концепцию босса.
**Как исправить**: В блоке `if _disabled:` добавить вызовы `_disabled_timer -= delta` и `_process_regen(delta)`, либо вызвать `super._physics_process(delta)` перед `return`.

### 15. [Файл: scripts/ai/boss_satan.gd, строки 631]
**Проблема**: Фаза 3 диалога использует `_p1_dialogue` вместо собственного пула: `_p1_dialogue if _phase == 1 else _p2_dialogue if _phase == 2 else _p1_dialogue`. Фразы фазы 3 идентичны фазе 1.
**Почему это баг**: В финальной фазе последнего босса используются неуместные реплики из фазы 1.
**Как исправить**: Создать `_p3_dialogue` массив и использовать его для `_phase == 3`.

---

## Средний приоритет (MEDIUM)

### 16. [Файл: scripts/ai/enemy_drowned_one.gd, строки 64-79]
**Проблема**: `_on_water_changed` перезаписывает `move_speed` напрямую. Если Drowned One потерял ногу (move_speed = 0.15x), вход в воду устанавливает speed = 180, а выход — speed = 60. Модификатор mutilation **теряется безвозвратно**.
**Как исправить**: Вместо прямой установки `move_speed`, хранить water_mult и применять его к `_initial_move_speed * mutilation_mult * water_mult`.

### 17. [Файл: scripts/ai/enemy_spy.gd, строка 236]
**Проблема**: Smoke bomb телепорт: `global_position += random_dir * 200.0` — без проверки коллизий. Spy может телепортироваться **в стены** или за пределы комнаты.
**Как исправить**: Использовать `move_and_slide()` или raycast для проверки целевой позиции перед телепортом.

### 18. [Файл: scripts/ai/enemy_gladiator.gd, строки ~259, enemy_champion.gd строки ~92]
**Проблема**: Проверка `limb_health[DamageZone.Zone.TORSO]` при all-limbs-lost. Если `_init_health` был переопределён и не содержит `TORSO` как ключ — crash.
**Как исправить**: Использовать `limb_health.get(DamageZone.Zone.TORSO, torso_hp)` с fallback.

### 19. [Файл: scripts/ai/enemy_cultist.gd / boss_accountant.gd / boss_curator.gd]
**Проблема**: `_move_projectile` использует `await get_tree().process_frame` в while-цикле. Если враг освобождён во время полёта снаряда, цикл продолжается. Проверки `is_instance_valid(self)` есть не везде.
**Как исправить**: Добавить `if not is_instance_valid(self): return` в начало каждой итерации цикла.

### 20. [Файл: scripts/world/floor_01_config.gd, строки 66-68]
**Проблема**: `fmod(float(hash(...)), size_px.x - 2.0 * margin)` — `hash()` может вернуть отрицательное значение, и `fmod` от отрицательного числа возвращает отрицательный результат. Spawn point может оказаться с координатой < margin — враг внутри стены.
**Как исправить**: Использовать `absf()` или `fposmod()` вместо `fmod()`.

### 21. [Файл: scripts/world/floor_06_manager.gd, строка 59]
**Проблема**: `_get_hazard_positions` использует `randf_range()` (глобальный RNG), а не seeded `_rng`. Это **нарушает детерминированность** seeded-ранов.
**Как исправить**: Заменить `randf_range()` на `_rng.randf_range()`.

### 22. [Файл: scripts/ui/run_summary.gd, строки 109-111]
**Проблема**: `show_summary()` создаёт таймер на 3 секунды, который эмитит `continue_pressed`. Если игрок нажимает CONTINUE вручную до истечения таймера, сцена меняется, но таймер стреляет в freed-нод и эмитит `continue_pressed` повторно — потенциально вызывая вторую смену сцены.
**Как исправить**: Сохранить ссылку на таймер и останавливать его при ручном продолжении. Добавить флаг `_continued: bool = false`.

### 23. [Файл: scripts/ui/settings_menu.gd, строки 149-155]
**Проблема**: `_on_reset_defaults()` итерирует детей, освобождает все кроме "Background", затем вызывает `_build_ui()`, который создаёт **новый** "Background". После каждого reset-а накапливается +1 Background-узел.
**Как исправить**: Освобождать ВСЕХ детей перед `_build_ui()`, или не создавать Background заново в `_build_ui()`.

### 24. [Файл: scripts/ui/tutorial_overlay.gd, строки 18/93]
**Проблема**: Background `ColorRect` имеет `MOUSE_FILTER_STOP` (дефолт), что перехватывает mouse clicks. При этом `_unhandled_input` проверяет `InputEventMouseButton` для dismiss по клику. Клик поглощается ColorRect и **никогда не доходит** до `_unhandled_input`.
**Как исправить**: Установить `bg.mouse_filter = Control.MOUSE_FILTER_IGNORE` или использовать `_input()` / `_gui_input()`.

### 25. [Файл: scripts/world/corpse_entity.gd, строки 29-57]
**Проблема**: `consume()` и `_destroy_corpse()` обе проверяют `is_consumed`, но в одном кадре обе могут пройти проверку (флаг устанавливается после проверки). Результат: два competing tween-а и двойной `queue_free()`.
**Как исправить**: Использовать `if is_consumed: return` как первую строку в обеих функциях (уже есть, но проверить что флаг установлен **до** создания tween-а).

### 26. [Файл: scripts/ai/boss_attendant_prime.gd, строки 149-152]
**Проблема**: В Phase 3 босс должен становиться видимым на 0.5с при атаке, но обе ветки (attack_cooldown > 0.5 и <= 0.5) устанавливают `sprite.modulate.a = 0.1`. Босс **всегда невидим** в тумане фазы 3, даже когда атакует.
**Как исправить**: При `attack_cooldown > 0.5` установить `sprite.modulate.a = 1.0` (видим во время атаки).

### 27. [Файл: scripts/ai/enemy_berserker.gd / enemy_gladiator.gd]
**Проблема**: `super._on_limb_lost(zone)` уже устанавливает `severed_limbs[zone] = true`, но подкласс делает это **повторно**. Не crash, но избыточно и маскирует реальную логику.
**Как исправить**: Убрать дублирующую строку `severed_limbs[zone] = true` из override.

### 28. [Файл: scripts/ai/enemy_royal_guard.gd / enemy_champion.gd]
**Проблема**: Charge/combo атаки планируют урон через `get_tree().create_timer(windup).timeout.connect()`. Если враг disabled/freed во время windup, урон всё равно наносится. Нет проверки `_disabled` в callback.
**Как исправить**: Добавить `if _disabled or not is_instance_valid(self): return` в начало callback-а.

### 29. [Файл: scripts/ui/unlock_toast.gd, строка 45]
**Проблема**: `queue_free()` освобождает весь CanvasLayer. Если `show_toast()` вызван повторно на том же экземпляре, первый toast-анимация освободит ноду, и последующие вызовы ничего не покажут. Один экземпляр = один toast за всё время жизни.
**Как исправить**: Создавать новый экземпляр UnlockToast для каждого сообщения, а не переиспользовать.

### 30. [Файл: scripts/effects/screen_effects.gd, строки 112-118]
**Проблема**: `hit_stop()` использует `await get_tree().create_timer(duration, true, false, true).timeout`. Если `hit_stop()` вызван повторно до завершения первого, `Engine.time_scale = 1.0` первого await-а восстановит нормальную скорость **до** истечения второго hit_stop. Эффект hit_stop прерывается.
**Как исправить**: Добавить флаг `_in_hit_stop: bool = true` и пропускать повторные вызовы (строка 113 уже делает `if Engine.time_scale < 1.0: return`, что частично решает проблему, но await-ы могут перемешаться).

### 31. [Файл: все четыре ending_a/b/c/d.gd]
**Проблема**: Ни один ending-скрипт не вызывает метод сохранения факта просмотра ending-а в SaveManager. `stats_screen.gd` читает `meta.get("secret_endings_seen", [])`, но никто не пишет в этот список. Счётчик "Endings Seen" всегда 0/4.
**Как исправить**: В каждом ending-скрипте добавить `SaveManager.commit_pending_unlocks(...)` с `ending_id`, или обновить meta напрямую: `var meta := SaveManager.get_meta(); var endings = meta.get("secret_endings_seen", []); if not endings.has(ending_id): endings.append(ending_id); meta["secret_endings_seen"] = endings; SaveManager.save_meta(meta)`.

### 32. [Файл: scripts/ai/enemy_attendant.gd, строка 143]
**Проблема**: `HazardZone.new()` создаёт узел напрямую из скрипта, а не из `.tscn` сцены. Если HazardZone требует дочерних узлов (CollisionShape2D и т.д.), они будут отсутствовать — hazard не работает.
**Как исправить**: Использовать `preload("res://scenes/combat/hazard_zone.tscn").instantiate()` вместо `HazardZone.new()`.

---

## Низкий приоритет (LOW) / Улучшения, предотвращающие будущие баги

### 33. [Файл: scripts/ai/base_enemy.gd]
**Проблема**: Нет `_exit_tree()` для отключения сигналов `detection_area.body_entered/exited`. При освобождении врага orphaned-сигналы могут вызвать ошибки.
**Как исправить**: Добавить `_exit_tree()` с `if detection_area.body_entered.is_connected(_on_detection_entered): detection_area.body_entered.disconnect(_on_detection_entered)` (и аналогично для `body_exited`).

### 34. [Файл: scripts/ai/enemy_vault_drone.gd, строка 49]
**Проблема**: `_ready()` НЕ вызывает `super._ready()`. Вместо этого вручную вызывает `_init_health_drone()`, `_connect_signals()`, `_create_glowing_eye()`. Если в базовый `_ready()` добавят новую логику, Vault Drone её не получит.
**Как исправить**: Вызвать `super._ready()` и переопределить только `_init_health` через override метода.

### 35. [Файл: scripts/ai/enemy_shadow_stalker.gd, строка 22]
**Проблема**: `_phase_collision_mask: int = 7` — захардкоженное значение, предполагающее что оригинальная маска 71 (binary 1000111). Если collision mask изменится в редакторе, фазинг будет убирать неправильные слои.
**Как исправить**: Сохранять оригинальную маску в `_original_collision_mask` в `_ready()` и вычислять phase-маску динамически.

### 36. [Файл: scripts/ai/enemy_staff.gd, строки 118-124]
**Проблема**: Dead code — проверка "all limbs severed" никогда не выполняется, потому что обе ветки (arm/leg) содержат `return`. Поведение "lie down, act as alert beacon" недостижимо.
**Как исправить**: Переструктурировать: сначала проверить all-severed, потом отдельные конечности.

### 37. [Файл: scripts/core/run_state.gd, строки 100-114]
**Проблема**: `add_artifact()` и `apply_artifact()` оба добавляют артефакт в `cult_artifacts`. Если вызваны последовательно для одного артефакта — он добавится дважды.
**Как исправить**: В `apply_artifact()` убрать `cult_artifacts.append(art)` (уже добавлено в `add_artifact`), или объединить методы. Убедиться что вызывается только один из них.

### 38. [Файл: scripts/core/seed_manager.gd, строки 27, 37]
**Проблема**: Формула seed для floor/room RNG (`_seed * floor_number + floor_number * 7`) может создавать коллизии для разных комбинаций seed+floor. Не уникально, но детерминировано — приемлемо для большинства случаев.
**Как исправить**: Использовать хеш-функцию: `hash(_seed + floor_number * 65536)` для лучшего распределения.

### 39. [Файл: scripts/player/player_controller.gd, строки 296-299]
**Проблема**: `_attack()` создаёт одноразовый таймер для сброса `_is_attacking`. Если игрок атакует быстро (switch weapon + attack), таймеры могут накапливаться. Нет cancel-механизма предыдущего таймера.
**Как исправить**: Сохранять ссылку на Tween/Timer и отменять перед созданием нового.

### 40. [Файл: scripts/world/arena_room.gd, строка 151]
**Проблема**: `_check_wave_cleared` проверяет `not enemy._disabled`. `_disabled` — внутренняя переменная базового класса. Если враг не имеет `_disabled` (не является BaseEnemy), это вызовет ошибку.
**Как исправить**: Использовать `enemy.get("_disabled") != true` или `enemy.has_method("is_disabled") and enemy.is_disabled()`.

### 41. [Файл: scripts/combat/weapon_manager.gd, строка 103]
**Проблема**: При `melee_attack` hitbox переподключается от пула к `current_scene`. Если `current_scene` в этот момент меняется (floor transition), `add_child` может fail.
**Как исправить**: Использовать `call_deferred("add_child", hit)` или проверять валидность `current_scene`.

### 42. [Файл: scripts/core/game_manager.gd, строки 130, 137]
**Проблема**: `handle_player_death()` устанавливает `current_state = GameState.BASEMENT` на строке 130. Затем `transition_to_basement()` на строке 137 **снова** устанавливает `current_state = GameState.BASEMENT`. Избыточно, но не вредно.
**Как исправить**: Убрать дублирующую установку в одном из методов.

### 43. [Файл: scripts/ai/enemy_seductress.gd — decoys]
**Проблема**: Decoys создаются как `ColorRect` — дочерние узлы врага. При `_on_decoy_hit` создаётся tween для fadeout + queue_free. Если родительский враг уже freed, tween на уже-freed ColorRect вызывает ошибку.
**Как исправить**: В `_on_decoy_hit` проверять `is_instance_valid(self)` перед созданием tween.

### 44. [Файл: scripts/world/floor_07_config.gd, строки 393-396]
**Проблема**: `_on_light_body_entered` обращается к `body._revealed` и `body._reveal_timer` напрямую по имени. Если враг не определяет эти переменные, GDScript создаст их как orphan values (no crash, но поведение непредсказуемо).
**Как исправить**: Использовать `body.get("_revealed")` с null-check или определить формальный интерфейс через метод `is_revealed()` / `reveal()`.

### 45. [Файл: scripts/ai/enemy_guard.gd, строка ~39-44]
**Проблема**: `_find_partner()` назначает первого найденного Guard как партнёра. При 3+ Guard-ах в комнате, все могут выбрать одного и того же партнёра, вместо формирования пар.
**Как исправить**: Реализовать pairing algorithm — назначать партнёра ближайшего незанятого.

### 46. [Файл: scripts/world/floor_07_config.gd, строка 262]
**Проблема**: ColorRect (Control) добавляется как дочерний узел Node2D (RoomInstance). В Godot 4 Control внутри Node2D не наследуют transform родителя, что может привести к неправильному позиционированию overlay.
**Как исправить**: Обернуть в CanvasLayer или использовать Node2D-совместимый визуал (Sprite2D с ColorRect-текстурой).

### 47. [Файл: scripts/ai/enemy_champion.gd, строка 342]
**Проблема**: `_attack_cooldown = windup + (1.0 / attack_speed)` где `attack_speed = 0.5`. Это даёт cooldown = windup + 2.0 секунды. Скорее всего `attack_speed` используется инвертированно — должно быть `windup + attack_speed`, а не `1.0 / attack_speed`.
**Как исправить**: Проверить дизайн-документ. Если attack_speed = 0.5 означает "полсекунды между атаками", формула должна быть `windup + attack_speed`.

### 48. [Файл: scripts/core/event_bus.gd, строки 48-49]
**Проблема**: Bridge-лямбды `func(_e, _z): limb_severed.emit()` и `func(_w, _o, _d): weapon_was_thrown.emit()` не защищены от fail. Если сигнал `limb_severed` emit-ится когда нет подписчиков — не crash (Godot 4 позволяет), но если EventBus был пересоздан — bridge-connections теряются.
**Как исправить**: Нет немедленного фикса, но стоит документировать что EventBus должен быть singleton.

### 49. [Файл: scripts/world/basement_manager.gd, строка 413]
**Проблема**: `PointLight2D` с `texture = null` не рендерится. Свет не виден.
**Как исправить**: Загрузить текстуру для PointLight2D или создать процедурную.

### 50. [Файл: scripts/ai/enemy_bodyguard.gd, строки 194-198]
**Проблема**: Shield bash наносит урон И вызывает `player_captured.emit()` И вызывает `apply_stun()`. Тройной эффект: damage + capture-signal + direct stun. `player_captured` обрабатывается как capture (смерть), что делает shield bash летальным.
**Как исправить**: Разделить: shield bash = damage + knockback (без capture). Capture только при grab-атаке.
