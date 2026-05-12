# Баги проекта Godot (результаты статического анализа)

**Дата:** 2026-05-13
**Аудит охватил:** 108 GDScript файлов (core, combat, AI, world, UI, audio, effects)

---

## Критичные (CRITICAL)

### 1. [Файл: scripts/combat/melee_hit.gd, строки ~56-71]
**Проблема:** Null enemy добавляется в `_targets_hit` и эмитится через `hit.emit(enemy, zone)`.
**Почему это баг:** Если ни один предок hurtbox-а не в группе `"enemy"`, переменная `enemy` остаётся `null`. Код проверяет `null in _targets_hit` (проходит), добавляет `null` в массив и эмитит `null` как цель. Все downstream-обработчики (включая `weapon_manager._apply_damage_to_target`) крашатся при `target.has_method("receive_damage")` на `null`.
**Как исправить:** Добавить `if enemy == null: return` сразу после while-цикла поиска предка в группе `"enemy"`.

### 2. [Файл: scripts/core/game_manager.gd, строка ~130]
**Проблема:** `handle_player_death()` устанавливает `current_state = GameState.BASEMENT` как guard от повторного входа, но `BASEMENT` — легитимное состояние.
**Почему это баг:** Если `transition_to_basement()` упадёт (отсутствует файл сцены), игра застрянет в состоянии `BASEMENT` без восстановления. Любой код, проверяющий `current_state == GameState.BASEMENT`, получит false positive во время перехода смерти.
**Как исправить:** Заменить на выделенный `_handling_death: bool` флаг или отдельное состояние `GameState.DEATH_TRANSITION`.

### 3. [Файл: scripts/core/seed_manager.gd, строки ~63-71]
**Проблема:** `get_gate_config()` при `total_branches == 1` делает `open_branches = branches.slice(0, 0)` = `[]` (ноль открытых веток), а `closed_branch` = единственная ветка.
**Почему это баг:** Single-branch gate имеет 0 открытых путей — софтлок игрока. Нет ни одного пути для прохождения.
**Как исправить:** Добавить guard: если `total_branches <= 1`, вернуть все ветки как открытые без закрытых.

### 4. [Файл: scripts/core/run_state.gd, строки ~94-96 и ~121]
**Проблема:** `apply_stat_upgrade()` проверяет `_upgrade_stack_counts.get(stat_name, 0)` для diminishing returns, но `_upgrade_stack_counts` заполняется ключами `upg.id` (например `"s1_vitality_shard"`), а не `stat_name` (например `"max_hp"`).
**Почему это баг:** Diminishing returns **никогда не срабатывают**. `_upgrade_stack_counts.get(stat_name, 0)` всегда возвращает 0, потому что ключи — ID апгрейдов, а не имена статов. Игрок получает полную силу каждого stack-апгрейда без уменьшения.
**Как исправить:** Либо трекать stack counts по `stat_name` в `apply_stat_upgrade()`, либо передавать правильный ключ из вызывающего кода.

### 5. [Файл: scripts/ai/boss_consort.gd, строки ~494-495]
**Проблема:** `_complete_summon` проверяет `if _guards.size() >= 1: return` — то есть стражи призываются ТОЛЬКО когда хотя бы один жив. Когда все стражи мертвы (`_guards.size() == 0`), функция возвращает без призыва.
**Почему это баг:** Consort **никогда не может** призвать стражей-заменителей когда все мертвы — именно тогда, когда они нужнее всего. Фаза 3 зависит от наличия стражей.
**Как исправить:** Изменить на `if not _guards.is_empty(): return`.

### 6. [Файл: scripts/ai/boss_satan.gd, строки ~599-621]
**Проблема:** `_show_final_offer` вызывается из `_process_phase_behaviors` → `_physics_process` и использует `await` дважды (3с + ожидание сигнала).
**Почему это баг:** Весь `_physics_process` Сатаны замораживается на 3+ секунды. Босс не двигается, не атакует, не обрабатывает AI. Тем временем другие враги (демоны) продолжают атаковать игрока.
**Как исправить:** Заменить `await` на state machine подход — состояние `SHOWING_OFFER` с таймером и callback-ами.

### 7. [Файл: scripts/effects/screen_effects.gd, строки ~113-123]
**Проблема:** `hit_stop` устанавливает `Engine.time_scale = 0.01`, затем `await` на таймере. Если узел `ScreenEffects` освобождён или сцена изменится во время await, оставшийся код (`Engine.time_scale = 1.0`) **никогда не выполнится**.
**Почему это баг:** `Engine.time_scale` навсегда остаётся 0.01 — игра зависает на 1% скорости. Это происходит при смене сцены/этажа во время hit-stop.
**Как исправить:** Использовать signal-callback подход вместо `await`, или привязать очистку к `NOTIFICATION_PREDELETE` / `_exit_tree`.

### 8. [Файл: scripts/world/floor_08_config.gd, строки ~354 и ~365]
**Проблема:** `_destroy_chandelier` объявляет `var tree := room.get_tree()` дважды в одной области видимости.
**Почему это баг:** В GDScript 2.0 повторное `var` с тем же именем в одной функции — ошибка парсинга. Скрипт не загрузится, и вся Floor 08 будет неработоспособна.
**Как исправить:** Убрать второе `var`, переиспользовав существующую переменную `tree`.

### 9. [Файл: scripts/world/arena_room.gd, строки ~52-53]
**Проблема:** `is_arena_active()` возвращает `current_wave >= 0 and not doors_locked`. Во время арены `doors_locked = true`, поэтому `not true` = `false`, и метод **всегда возвращает false**.
**Почему это баг:** Ни одна система не может корректно определить, активна ли арена. Условие инвертировано.
**Как исправить:** Изменить на `return current_wave >= 0 and doors_locked`.

---

## Высокий приоритет (HIGH)

### 10. [Файл: scripts/player/player_controller.gd, строки ~258-259]
**Проблема:** Bloodlust устанавливает `bloodlust_stacks = mini(stacks, 3)` где `stacks = get_stack_count("s11_bloodlust")` — количество **копий реликвии**, а не текущий buff stack.
**Почему это баг:** Bloodlust **никогда не стакается**. При 1 копии реликвии `bloodlust_stacks` всегда = 1 на каждом убийстве. Механика стака с diminishing returns полностью неработоспособна.
**Как исправить:** Заменить на `GameManager.run_state.bloodlust_stacks = mini(GameManager.run_state.bloodlust_stacks + 1, 3)`.

### 11. [Файл: scripts/combat/thrown_weapon.gd, строка ~367]
**Проблема:** `_apply_reality_tear` вызывает `queue_free()` напрямую вместо `_return_to_pool()`.
**Почему это баг:** Object pool leak. Каждый бросок Cult Relic навсегда удаляет один экземпляр из пула. Со временем пул истощается.
**Как исправить:** Заменить `queue_free()` на `_return_to_pool()`.

### 12. [Файл: scripts/combat/thrown_weapon.gd, строки ~87, 112, 137-149]
**Проблема:** Множественные нескоординированные таймеры (`_return_to_pool` через 3с, 5с, 7с, 10с) могут быть созданы на одном объекте. `_apply_throw_effect` с эффектом `"shatter"` вызывает `_return_to_pool`, но код продолжает выполнение и ставит ещё один таймер.
**Почему это баг:** Double `_return_to_pool` на pooled объекте. При bounce-эффекте `_has_hit` сбрасывается в `false`, создавая неограниченный цикл создания таймеров.
**Как исправить:** После `_apply_throw_effect` делать `return`, если эффект уже вызвал `_return_to_pool`. Хранить ссылку на активный таймер и отменять предыдущий перед созданием нового.

### 13. [Файл: scripts/combat/weapon_manager.gd, строки ~100-108]
**Проблема:** Pooled melee hitbox репарентится через `call_deferred("add_child", hit)`, но `setup()` уже вызван, и lifespan таймер (0.15с) уже тикает.
**Почему это баг:** Hitbox невидим для физического движка 1 кадр. Короткий lifespan (0.15с) может частично истечь пока узел вне дерева — промахи ударов.
**Как исправить:** Использовать `add_child` напрямую (не deferred), или запускать lifespan таймер после добавления в дерево.

### 14. [Файл: scripts/combat/hazard_zone.gd, строки ~44-59]
**Проблема:** При повторном входе тела в hazard zone `apply_hazard_slow` вызывается повторно, стакая замедление. Но `remove_hazard_slow` вызывается только один раз при выходе/истечении.
**Почему это баг:** Скорость тела никогда не восстанавливается полностью после повторного входа в зону. Замедление стакается мультипликативно.
**Как исправить:** Трекать count применения slow на каждое тело, или сделать `apply_hazard_slow`/`remove_hazard_slow` идемпотентными.

### 15. [Файл: scripts/core/game_scene.gd, строка ~32]
**Проблема:** `gore_system` присваивается через `%GoreSystem` — unique node syntax работает только для узлов **внутри той же сцены**, не для autoload-ов.
**Почему это баг:** `%GoreSystem` не resolves — `gore_system` будет `null`. Вызов `gore_system.clear_room_effects()` крашится.
**Как исправить:** Использовать `GoreSystem` напрямую (autoload) или `get_node_or_null("/root/GoreSystem")`.

### 16. [Файл: scripts/combat/gore_system.gd, строка ~160]
**Проблема:** Создаётся `RigidBody2D` и подключается `body_entered`, но `contact_monitor` по умолчанию `false` в Godot 4.
**Почему это баг:** Сигнал `body_entered` **никогда не срабатывает**. Капли крови падают бесконечно (пока 5с lifetime таймер) вместо прилипания к поверхностям.
**Как исправить:** Добавить `drop.contact_monitor = true` перед подключением сигнала.

### 17. [Файл: scripts/combat/gore_system.gd, строка ~26]
**Проблема:** `_on_room_entered` вызывает `_active_pools.clear()`, но не освобождает фактические StaticBody2D узлы пулов.
**Почему это баг:** Memory leak. Визуализации луж крови сохраняются в scene tree как orphan-узлы при каждой смене комнаты.
**Как исправить:** Итерировать и `queue_free()` все пулы перед `clear()`.

### 18. [Файл: scripts/core/game_manager.gd, строки ~380-382]
**Проблема:** `_show_unlock_toast()` добавляет CanvasLayer к `tree.current_scene`. Если сцена сменится до завершения tween-анимации тоста, `queue_free()` на уже освобождённом узле генерирует ошибки.
**Как исправить:** Null-check `tree.current_scene`. Добавлять тост к persistent CanvasLayer (autoload) вместо transient current scene.

### 19. [Файл: scripts/core/seed_manager.gd, строка ~56]
**Проблема:** `get_room_enemy_config()` и `get_room_loot_config()` обе вызывают `get_room_rng()`, который возвращает **один и тот же cached RNG**. Enemy config мутирует состояние RNG, потом loot config использует мутированное состояние.
**Почему это баг:** Loot генерация зависит от enemy конфигурации. Изменение спавна врагов тихо меняет loot. Детерминизм нарушен.
**Как исправить:** Создать отдельный RNG кэш для loot, или использовать seed-значение до мутации enemy RNG.

### 20. [Файл: scripts/effects/object_pool.gd, строки ~33-36]
**Проблема:** Когда пул исчерпан, `_active.pop_front()` забирает старейший экземпляр. Но внешний код всё ещё держит ссылку на этот "украденный" объект и может вернуть его в пул повторно.
**Почему это баг:** Double insertion в `_pool`. Объект появляется в пуле дважды. При следующем `get_instance` два вызывающих получат одну и ту же ссылку.
**Как исправить:** При принудительном возврате — помечать объект флагом `_reclaimed`, проверять его при `_return`.

### 21. [Файл: scripts/world/enemy_spawner.gd, строка ~87]
**Проблема:** `rng.seed += 42` мутирует seed RNG, возвращённого `seed_mgr.get_room_rng()`. Если SeedManager кэширует объект — seed изменён для всех последующих потребителей.
**Почему это баг:** Нарушение детерминизма seeded runs.
**Как исправить:** Создать локальную копию RNG или использовать отдельный offset.

### 22. [Файл: scripts/world/arena_room.gd, строки ~135-144]
**Проблема:** Оба `_on_enemy_disabled` и `_on_enemy_tree_exited` могут сработать для одного врага. `_check_wave_cleared` строит `alive` список, но **никогда не записывает** его обратно в `active_enemies`.
**Почему это баг:** `active_enemies` растёт с dead-ссылками. Wave-completion может срабатывать повторно или никогда.
**Как исправить:** Заменять `active_enemies` на отфильтрованный `alive` список внутри `_check_wave_cleared`.

### 23. [Файл: scripts/ai/boss_accountant.gd, строки ~211-214]
**Проблема:** В `_state_engage` Phase 3 barrage проверяет `_gold_throw_timer <= 0.0`, но прямо перед этим Phase 2+ throw (строки 206-208) уже сбросил таймер в 3.0/6.0. Оба блока выполняются в одном кадре.
**Почему это баг:** Phase 3 gold bar barrage — **мёртвый код**. Никогда не срабатывает, потому что Phase 2 throw всегда опережает.
**Как исправить:** Использовать `elif` для Phase 3 блока, или проверять Phase 3 первым.

### 24. [Файл: scripts/ai/boss_champion.gd, строки ~216-227]
**Проблема:** `_on_wave_enemy_died` использует `tree_exited` — срабатывает при ЛЮБОМ удалении из дерева, включая смену сцены.
**Почему это баг:** Wave count декрементируется некорректно, что может преждевременно вызвать следующую волну или descent phase.
**Как исправить:** Использовать кастомный `enemy_died` сигнал вместо `tree_exited`.

### 25. [Файл: scripts/ai/boss_sister.gd, строки ~281-294 vs 328-339]
**Проблема:** Spare-проверка в `_process_combat` требует `hp_pct < 0.1` и `_player_attack_pause_timer >= 3.0`. Но `receive_damage` при `hp_after <= 0.0` немедленно убивает Sister.
**Почему это баг:** Killing blow обходит spare-механику. Игрок, остановивший атаки на 3с, но случайно задевший Sister — убивает её без шанса spare.
**Как исправить:** Капить урон на 10% HP пороге, позволяя spare-механике сработать.

### 26. [Файл: scripts/ai/base_enemy.gd, строки ~567-572]
**Проблема:** `_on_detection_exited` создаёт новый `SceneTreeTimer` с lambda при каждом выходе цели из зоны обнаружения. Нет механизма отмены.
**Почему это баг:** При 5 входах/выходах — 5 lambda scheduled. Поздние могут занулить `_target` даже когда игрок вернулся и активно преследуется.
**Как исправить:** Хранить ссылку на таймер и disconnect при повторном входе цели.

### 27. [Файл: scripts/ai/boss_attendant_prime.gd / boss_curator.gd / boss_satan.gd]
**Проблема:** Множественные боссы используют `await get_tree().create_timer(...)` внутри функций, вызываемых из state machine / `_physics_process`.
**Почему это баг:** State machine не приостанавливается во время await. Босс может ре-войти в ту же или другую стейт, вызывая double-attacks или некорректное состояние.
**Как исправить:** Использовать guard-флаги (напр. `_steam_blasting = true`) для предотвращения ре-входа, или timer-based подход вместо await.

### 28. [Файл: scripts/combat/projectile.gd, строки ~48-68]
**Проблема:** Dual lifetime tracking: `Lifetime` Timer node И ручной `_lifetime -= delta` в `_physics_process`. Оба независимо вызывают `_return_to_pool`. У `_return_to_pool` в projectile.gd **нет guard** против double-call.
**Почему это баг:** Double `_return_to_pool` — projectile возвращается в пул дважды.
**Как исправить:** Убрать один из двух механизмов lifetime, или добавить guard-флаг в `_return_to_pool`.

### 29. [Файл: scripts/world/room_instance.gd, строка ~42]
**Проблема:** Каждый `RoomInstance` подключается к `EventBus.enemy_disabled` в `_ready()`, но никогда не disconnect-ится в `_exit_tree()`.
**Почему это баг:** Для этажа с 10 комнатами — 10 callback-ов на каждое убийство врага в игре, даже для деактивированных комнат. O(n) waste per enemy death.
**Как исправить:** Добавить `EventBus.enemy_disabled.disconnect(_on_enemy_disabled)` в `_exit_tree()`.

### 30. [Файл: scripts/ui/unlock_toast.gd, строка ~45]
**Проблема:** Tween callback вызывает `queue_free()` на самом CanvasLayer. Если `show_toast` вызван повторно до завершения анимации, узел уже в процессе удаления.
**Почему это баг:** Повторное использование toast-узла для нескольких уведомлений вызывает free во время работы первого.
**Как исправить:** `queue_free` должен целить `panel`, а не `self`. Или создавать новый instance на каждое уведомление.

---

## Средний приоритет (MEDIUM)

### 31. [Файл: scripts/core/game_manager.gd, строки ~127-133]
**Проблема:** `handle_player_death()` не null-check-ит `run_state`. `handle_basement_failure()` (строка 158) тоже вызывает `run_state.get_run_time()` без проверки.
**Как исправить:** Добавить `if run_state == null: return` в начале обоих методов.

### 32. [Файл: scripts/core/game_manager.gd, строка ~76]
**Проблема:** `_loot_spawner_script` загружается через lazy-load. Если `load()` не найдёт файл, следующий вызов `.give_starting_loadout()` крашится.
**Как исправить:** Добавить `if _loot_spawner_script:` перед вызовом.

### 33. [Файл: scripts/core/run_state.gd, строки ~196-201]
**Проблема:** Static метод `from_dict()` вызывает `GameManager.run_state.cleanup()` — side effect в функции десериализации. + `load().new()` вместо `RunState.new()`.
**Почему это баг:** Circular dependency (RunState ↔ GameManager). `from_dict()` нельзя безопасно вызвать для не-активного run state.
**Как исправить:** Убрать cleanup из `from_dict()`, перенести в вызывающий код. Использовать `RunState.new()` напрямую.

### 34. [Файл: scripts/core/run_state.gd, строка ~155]
**Проблема:** `get_run_time()` использует `Time.get_ticks_msec()` (wall-clock). Время паузы засчитывается в run time.
**Почему это баг:** Для roguelike с tracked fastest_time — пауза ухудшает время.
**Как исправить:** Трекать суммарную длительность паузы и вычитать, или аккумулятор в `_process` с проверкой `get_tree().paused`.

### 35. [Файл: scripts/core/save_manager.gd, строка ~113]
**Проблема:** `get_settings()` использует `_current_settings.is_empty()` как sentinel "не загружено". Пустой dict при ошибке парсинга JSON (строка 66) вызывает reload каждый вызов.
**Как исправить:** Использовать `_settings_loaded: bool` флаг. Возвращать `_default_settings()` при ошибке парсинга.

### 36. [Файл: scripts/core/artifact_registry.gd, строка ~28; upgrade_registry.gd, строка ~28]
**Проблема:** Проверка `res is Resource` пропускает любой `.tres` файл. Если файл не CultArtifact/StatUpgrade, `res.id` может быть `null`.
**Как исправить:** Проверять `res is CultArtifact` / `res is StatUpgrade`.

### 37. [Файл: scripts/combat/weapon_manager.gd, строка ~44]
**Проблема:** `active_slot = GameManager.run_state.active_slot` без clamp. Если в сохранении `active_slot = 2` но `max_slots = 2` (без Crown of Thorns) — array index out of bounds.
**Как исправить:** `active_slot = mini(GameManager.run_state.active_slot, max_slots - 1)`.

### 38. [Файл: scripts/combat/weapon_manager.gd, строки ~147-149]
**Проблема:** Ranged attack: `get_tree().current_scene.add_child(proj)` без null-check на `current_scene`. Melee версия имеет проверку, ranged — нет.
**Как исправить:** Добавить `if is_instance_valid(get_tree().current_scene)` guard.

### 39. [Файл: scripts/combat/weapon_manager.gd, строка ~215]
**Проблема:** Knockback direction вычисляется от `global_position` WeaponManager, а не игрока. Если WeaponManager имеет offset — направление неправильное.
**Как исправить:** Использовать `get_parent().global_position.direction_to(target.global_position)`.

### 40. [Файл: scripts/player/player_controller.gd, строки ~357-358]
**Проблема:** `_is_attacking` всегда устанавливает `_current_anim = AnimRow.THROW`. `AnimRow.ATTACK` определён, но никогда не используется.
**Почему это баг:** Melee атаки визуально выглядят как бросок.
**Как исправить:** Использовать `AnimRow.ATTACK` для melee/ranged, `AnimRow.THROW` только для броска.

### 41. [Файл: scripts/combat/thrown_weapon.gd, строка ~106]
**Проблема:** `_weapon.name == "Bottle"` — hardcoded string против mutable display name.
**Почему это баг:** При переименовании/локализации "Bottle" → "Wine Bottle" проверка молча ломается.
**Как исправить:** Добавить `weapon_id` поле в `WeaponData`.

### 42. [Файл: scripts/combat/gore_system.gd, строки ~10-11]
**Проблема:** `_active_pools` и `_active_limbs` содержат dead references после `queue_free`. Массивы растут без очистки.
**Как исправить:** Периодически prune dead references через `is_instance_valid`.

### 43. [Файл: scripts/core/game_scene.gd, строки ~85-92]
**Проблема:** Дублирующая vignette система в `game_scene.gd` конфликтует с `ScreenEffects` autoload. Плюс infinite tween (`set_loops()` без лимита) никогда не останавливается при смене сцены.
**Как исправить:** Удалить duplicate vignette из `game_scene.gd`, использовать `ScreenEffects.update_vignette()`. Добавить cleanup в `_exit_tree`.

### 44. [Файл: scripts/core/game_manager.gd, строка ~108]
**Проблема:** `floor_entered.emit.call_deferred()` — deferred, но `floor_exited.emit()` на строке 102 — синхронный. Несогласованный порядок.
**Как исправить:** Оба синхронные или оба deferred.

### 45. [Файл: scripts/ai/boss_gourmand.gd, строки ~123-142]
**Проблема:** `_process_regen(delta)` вызывается дважды: явно на строке 126 и через `super._physics_process(delta)` на строке 142.
**Почему это баг:** Gourmand регенерирует в 2x скорость.
**Как исправить:** Убрать явный вызов `_process_regen` на строке 126.

### 46. [Файл: scripts/ai/boss_gourmand.gd, строка ~173; enemy_berserker.gd:134; enemy_guard.gd:101; enemy_head_chef.gd:155]
**Проблема:** `_state_chase` вызывает `move_and_slide()` напрямую, затем `super._physics_process` вызывает его повторно.
**Почему это баг:** Double `move_and_slide()` ≈ 2x скорость движения + физические глюки.
**Как исправить:** Убрать `move_and_slide()` из `_state_chase`, оставить базовому `_physics_process`.

### 47. [Файл: scripts/ai/boss_madame.gd, строки ~64-67]
**Проблема:** `_shard_count` инкрементируется при создании shard, но **никогда не декрементируется** при истечении (5с таймер).
**Почему это баг:** После 20 shards — attack молча не создаёт hazard zones до конца боя.
**Как исправить:** Декрементировать `_shard_count` в callback-е cleanup shard.

### 48. [Файл: scripts/ai/boss_satan.gd, строки ~178-187]
**Проблема:** Фазовые переходы на `_total_hp_lost` (cumulative damage), но реген может восстановить HP. `_max_phase_hp` обновляется, создавая несоответствие.
**Почему это баг:** Босс может регенерировать выше phase HP pool, удлиняя Phase 2 и 3.
**Как исправить:** Базировать фазовые переходы на current HP percentage или запретить реген.

### 49. [Файл: scripts/ai/boss_curator.gd, строки ~315-323]
**Проблема:** `_steal_both` ворует оба оружия, но `_stolen_weapon` хранит только одну ссылку. Второе оружие теряется навсегда.
**Как исправить:** Drop второе оружие через `EventBus.weapon_dropped.emit()` или хранить в массиве.

### 50. [Файл: scripts/ai/enemy_demon.gd, строки ~298-317]
**Проблема:** `_disable_enemy` не вызывает `super._disable_enemy()`. Пропущены: death SFX, screen flash, velocity reset.
**Как исправить:** Вызвать `super._disable_enemy()`.

### 51. [Файл: scripts/ai/enemy_demon.gd, строки ~324-361]
**Проблема:** Custom `_physics_process` не вызывает `_process_regen(delta)` в основном (active) пути. `regen_speed_mult = 1.5` не имеет эффекта.
**Как исправить:** Добавить `_process_regen(delta)` после строки 353.

### 52. [Файл: scripts/ai/enemy_drowned_one.gd, строки ~234-241]
**Проблема:** `_on_limb_lost` напрямую устанавливает `move_speed = _move_speed_land * 0.3`. Но `_on_water_changed` → `_recalc_move_speed()` перезаписывает `move_speed`, стирая leg-loss penalty.
**Почему это баг:** Drowned One плывёт на полной скорости без ног.
**Как исправить:** Учитывать потерю конечностей при пересчёте water movement speed.

### 53. [Файл: scripts/ai/enemy_seductress.gd, строка ~215]
**Проблема:** `_find_nearest_bodyguard` ищет группу `"bodyguards"`, но Bodyguard **не добавляет себя** ни в какую группу в `_ready`.
**Почему это баг:** Seductress никогда не находит bodyguard для отступления. Механика Guard/Seductress pairing полностью сломана.
**Как исправить:** Добавить `add_to_group("bodyguards")` в `enemy_bodyguard.gd._ready()`.

### 54. [Файл: scripts/ai/enemy_vault_drone.gd, строки ~138-166]
**Проблема:** `receive_damage` полностью переопределяет базовый класс без `super`. Нет hurt flash, нет SFX, нет screen effect.
**Почему это баг:** Vault Drone не даёт никакой визуальной/аудио обратной связи при получении урона.
**Как исправить:** Вызвать `_flash_hurt()` и воспроизвести hurt SFX.

### 55. [Файл: scripts/ai/enemy_head_chef.gd, строка ~638]
**Проблема:** DOT tick через `int(_grab_elapsed) > int(_grab_elapsed - delta)` — flat damage per tick, не scaled by delta.
**Почему это баг:** Frame-rate dependent damage. При lag spike (delta > 1.0) tick пропускается.
**Как исправить:** Применять `_grab_dot_damage * delta` каждый кадр.

### 56. [Файл: scripts/ai/enemy_champion.gd, строки ~356-362]
**Проблема:** Combo hits доставляются через async timer. Если combo сброшен (stun), pending timer-ы всё равно deliver-ят хиты от отменённого combo.
**Как исправить:** Добавить combo generation counter для валидации.

### 57. [Файл: scripts/ai/enemy_demon.gd, строки ~26, 298-317]
**Проблема:** Dark bolts в `_dark_bolts` не освобождаются при disable. Болты продолжают homing на игрока после отключения демона.
**Как исправить:** Free все активные dark bolts в `_disable_enemy`.

### 58. [Файл: scripts/world/basement_manager.gd, строка ~86]
**Проблема:** `_on_exit_reached(_body)` вызывает `_body.is_in_group("player")` без null-check.
**Как исправить:** Добавить `if _body == null: return`.

### 59. [Файл: scripts/world/room_instance.gd, строки ~66-69]
**Проблема:** `activate()` делает `call_deferred("activate")` если камера не найдена. Нет retry counter.
**Почему это баг:** Infinite deferred loop если Camera node отсутствует.
**Как исправить:** Добавить retry counter с fallback.

### 60. [Файл: scripts/world/loot_spawner.gd, строки ~300-309]
**Проблема:** `_find_floor_manager` делает O(n) DFS по всему scene tree, проверяя `has_method` на каждом узле.
**Почему это баг:** Performance bottleneck на больших сценах для каждого pickup.
**Как исправить:** Использовать `get_tree().get_first_node_in_group("floor_manager")`.

### 61. [Файл: scripts/world/corpse_entity.gd, строки ~50-59]
**Проблема:** `_destroy_corpse` устанавливает `is_consumed = true`, но **не эмитит** `corpse_consumed`. `consume()` эмитит. Зависимые системы не уведомляются.
**Как исправить:** Эмитить `corpse_consumed` (или отдельный `corpse_destroyed`) из `_destroy_corpse`.

### 62. [Файл: scripts/world/floor_manager.gd, строка ~466]
**Проблема:** `_on_pickup_collected` может быть вызван дважды на одном pickup (два body_entered в одном кадре). `queue_free` deferred, metadata читаются успешно оба раза.
**Как исправить:** Guard: `if pickup.get_meta("collected", false): return; pickup.set_meta("collected", true)`.

### 63. [Файл: scripts/audio/sfx_player.gd, строки ~95-104]
**Проблема:** `play_sfx_with_pitch` устанавливает `pitch_scale`, но `play_sfx` не сбрасывает его в 1.0.
**Почему это баг:** Все последующие SFX на том же pool player играют с неправильным pitch.
**Как исправить:** Reset `pitch_scale = 1.0` в начале `play_sfx` и `play_sfx_2d`.

### 64. [Файл: scripts/audio/audio_manager.gd, строки ~122-125]
**Проблема:** `create_timer(2.0)` для music transition — untracked timer, срабатывает после смены сцены.
**Как исправить:** Хранить ссылку и cancel в `_on_player_died` / `_on_run_ended`.

### 65. [Файл: scripts/ui/hud.gd, строка ~248]
**Проблема:** Ammo display показывает literal string `"ammo"` вместо значения.
**Почему это баг:** Ammo counter всегда отображает текст "ammo" для ranged оружия — бесполезен.
**Как исправить:** Заменить на `str(weapon.ammo)`.

### 66. [Файл: scripts/ui/dialog_choice.gd, строки ~6-7]
**Проблема:** `@onready` vars с `%` syntax — null если узлы отсутствуют в сцене. `setup()` крашится на `_label.text = text`.
**Как исправить:** Добавить null checks.

### 67. [Файл: scripts/ui/settings_menu.gd, строка ~150]
**Проблема:** Вызов `SaveManager._default_settings()` — private method, не part of public API.
**Как исправить:** Использовать публичный метод `SaveManager.get_default_settings()`.

### 68. [Файл: scripts/ui/pause_menu.gd, строки ~88-90]
**Проблема:** Кнопка "Quit to Title" вызывает `GameManager.restart_run()` вместо `go_to_title()`.
**Почему это баг:** UI label не соответствует действию. Игрок ожидает переход к титульному экрану.
**Как исправить:** Заменить на `GameManager.go_to_title()`.

### 69. [Файл: scripts/ai/boss_consort.gd, строка ~254]
**Проблема:** `_cleanup_guards` читает `g._disabled` напрямую — private field другого скрипта.
**Как исправить:** Использовать `g.has_method("is_disabled") and g.is_disabled()`.

### 70. [Файл: scripts/ai/enemy_spy.gd, строка ~314]
**Проблема:** `_try_smoke_bomb` вызывается каждый кадр без state checks. Может сработать во время stun/attack.
**Как исправить:** Добавить `if _stunned or _disabled: return`.

### 71. [Файл: scripts/ai/enemy_bodyguard.gd, строки ~43, 46-48]
**Проблема:** `_exit_tree` проверяет `EventBus.enemy_damaged.is_connected` без null-check на EventBus.
**Как исправить:** Добавить `if EventBus:` guard.

### 72. [Файл: scripts/ai/boss_accountant.gd, строки ~476-485]
**Проблема:** `_process_phase3_trap_decay` определена, но **нигде не вызывается**. Phase 3 trap decay — мёртвый код.
**Как исправить:** Вызывать в `_physics_process` при `_phase >= 3`.

### 73. [Файл: scripts/ai/boss_madame.gd, строки ~452-457]
**Проблема:** `_clear_all_clones` итерирует `clones` и вызывает `_shatter_clone`, который делает `clones.erase(clone)` — модификация массива при итерации.
**Как исправить:** Итерировать копию массива.

### 74. [Файл: scripts/ai/boss_satan.gd, строка ~687]
**Проблема:** `ally.set("_target", self)` — Sister атакует Satan, но `receive_damage` Satan-а не отличает ally damage от player damage. Satan может потерять украденное оружие от удара Sister.
**Как исправить:** Добавить `attacker` параметр в `receive_damage`.

### 75. [Файл: scripts/effects/object_pool.gd, строка ~77]
**Проблема:** `_expand()` вызывает `add_child(instance)`. Если pool ещё не в дереве — warning/crash.
**Как исправить:** Guard: `if is_inside_tree()`.

### 76. [Файл: scripts/core/save_manager.gd, строки ~134-148]
**Проблема:** Audio bus creation: `add_bus()` без проверки на уже существующие в проекте шины. Возможны дубликаты.
**Как исправить:** Проверять default bus layout.

### 77. [Файл: scripts/core/save_manager.gd, строка ~219]
**Проблема:** Boss defeated count может задвоиться при повторном сигнале (счётчик + полный run count добавляется к meta).
**Как исправить:** Использовать set вместо counter для отслеживания killed bosses.

### 78. [Файл: scripts/world/floor_07_config.gd, строки ~392-398]
**Проблема:** `body.get("_revealed") != null` возвращает `false` и для легитимного null-valued property.
**Как исправить:** Использовать `body.has_method("reveal")` или `"reveal" in body`.

### 79. [Файл: scripts/world/floor_06_manager.gd, строки ~177-226]
**Проблема:** `wave_configs` typed `Array[Dictionary]`, но значения из metadata — untyped `Variant`.
**Как исправить:** Cast в `Dictionary` при append.

---

## Низкий приоритет (LOW) / Улучшения, предотвращающие будущие баги

### 80. [Файл: scripts/core/seed_manager.gd, строки ~26-28]
**Проблема:** `hash(_seed + floor_number * 65536 + room_index * 256)` — возможны коллизии при определённых комбинациях floor/room.
**Как исправить:** Использовать `hash(str(_seed) + "_" + str(floor) + "_" + str(room))`.

### 81. [Файл: scripts/core/run_state.gd, строки ~134-146]
**Проблема:** `has_artifact()` — три перекрывающихся проверки. Неясно, какое поле canonical ID (`resource_name`, `id`, `display_name`).
**Как исправить:** Консолидировать к одному canonical check через `id` field.

### 82. [Файл: scripts/core/event_bus.gd, строки ~50-51]
**Проблема:** Lambda signal bridges никогда не disconnect-ятся. При hot-reload — `_bridges_connected` блокирует переподключение.
**Как исправить:** Документировать, что EventBus не должен реинстанцироваться.

### 83. [Файл: scripts/combat/hazard_zone.gd, строки ~19-26]
**Проблема:** Signal connections не disconnect-ятся перед `queue_free()`. Body может enter/exit между `queue_free` и actual free.
**Как исправить:** Disconnect signals перед `queue_free()`.

### 84. [Файл: scripts/world/breakable_mirror.gd, строка ~20]
**Проблема:** `crack_node.color.a` — crash если CrackOverlay не ColorRect.
**Как исправить:** Cast к ColorRect или check `crack_node is ColorRect`.

### 85. [Файл: scripts/world/basement_manager.gd, строки ~79-81]
**Проблема:** Print warning каждый кадр последние 10 секунд — 600 print calls.
**Как исправить:** Трекать last warned second, print максимум раз в секунду.

### 86. [Файл: scripts/audio/sfx_player.gd, строки ~107-112]
**Проблема:** Stealing busy player без `stop()` — audible pop/click.
**Как исправить:** Вызывать `player.stop()` перед реassign stream.

### 87. [Файл: scripts/audio/music_player.gd, строки ~120-131]
**Проблема:** Crossfade tween не хранится. `stop_all` не убивает активный crossfade.
**Как исправить:** Хранить tween reference, kill в `stop_all`.

### 88. [Файл: scripts/audio/audio_manager.gd, строки ~173-178]
**Проблема:** `_tension_timer` тикает во время паузы — music transition при паузе.
**Как исправить:** Проверять `get_tree().paused` перед обработкой tension timer.

### 89. [Файл: scripts/effects/screen_effects.gd, строка ~83]
**Проблема:** `_shake_tween.set_speed_scale(Engine.time_scale)` — shake при hit-stop (time_scale 0.01) играет на 1% скорости.
**Как исправить:** Убрать `set_speed_scale` или установить `1.0 / Engine.time_scale`.

### 90. [Файл: scripts/ui/settings_menu.gd, строки ~152-153]
**Проблема:** `queue_free` детей + немедленный `_build_ui()` — старые и новые дети сосуществуют 1 кадр.
**Как исправить:** Использовать `call_deferred("_build_ui")`.

### 91. [Файл: scripts/ai/enemy_shadow_stalker.gd, строки ~189-190]
**Проблема:** `_dissolving` flag — чисто визуальный. Enemy продолжает драться при полной дисмембрации.
**Как исправить:** Вызывать `_disable_enemy()` или добавить dissolve timer.

### 92. [Файл: scripts/ai/boss_accountant.gd, строки ~401-416]
**Проблема:** `_move_projectile` — busy loop с `get_process_delta_time()` + potential bolt leak при смерти босса.
**Как исправить:** Track elapsed time явно. Free bolt во всех exit paths.

### 93. [Файл: scripts/ai/boss_champion.gd, строки ~82-83]
**Проблема:** `_disabled_timer = 999999.0` вместо proper flag для "вечной" дисабленности.
**Как исправить:** Использовать отдельный `_immune` флаг.

### 94. [Файл: scripts/ai/boss_madame.gd, строка ~286]
**Проблема:** `Array.shuffle()` использует global random вместо `_rng` — ломает determinism seeded runs.
**Как исправить:** Использовать `_rng` консистентно.

### 95. [Файл: scripts/ai/boss_curator.gd, строки ~496-503]
**Проблема:** Clone создаётся без patrol points — сидит idle.
**Как исправить:** Установить clone в chase state с player target.

### 96. [Файл: scripts/test_room/test_room_scene.gd, строка ~52]
**Проблема:** "T" key маппится на `ui_pause` — конфликт с нормальным pause.
**Как исправить:** Использовать dedicated debug action или `KEY_T` напрямую.

### 97. [Файл: scripts/ai/boss_gourmand.gd, строка ~541]
**Проблема:** `collision_mask = 7` — hardcoded magic number. Оригинальное значение не сохраняется.
**Как исправить:** Store оригинальный collision mask и restore его.

### 98. [Файл: scripts/ai/boss_attendant_prime.gd, строки ~126-131]
**Проблема:** Fog healing работает даже когда boss disabled/stunned.
**Как исправить:** Добавить `if _disabled: return` перед fog healing.

---

**Итого:** 9 CRITICAL, 21 HIGH, 49 MEDIUM, 19 LOW = **98 уникальных багов**
