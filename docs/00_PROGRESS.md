# HOTEL — ТЕКУЩИЙ ПРОГРЕСС
## Последнее обновление: 2026-05-12

---

# СТАТУС: M8 POLISH — ФИНАЛЬНАЯ ВЕРИФИКАЦИЯ

---

# 1. MILESTONE ТАБЛИЦА

| Milestone | Описание | Статус |
|-----------|----------|--------|
| M1: Combat Prototype | Player + base enemy + melee + regen | ✅ Завершён |
| M2: Weapon System | 15 weapons + throw mechanics + .tres | ✅ Завершён |
| M3: Floor 1 Alpha | Full floor + 3 enemy types + Head Chef boss | ✅ Завершён |
| M4: Run Systems | Basement + run start/end + randomization | ✅ Завершён |
| M5: Vertical Slice | Floor 1 polished, all systems integrated | ✅ Завершён |
| M6: Content (Floor 2-3) | Floor 2 (Lust) + Floor 3 (Gluttony) enemies + bosses | ✅ Завершён |
| M7: Full Game (Floor 4-9) | All 9 floors, 18 enemy types, 10 bosses, endings | ✅ Завершён |
| M8: Polish | Audio, SFX, VFX, balance, final verification | 🔄 В процессе (M8.4 — финальный аудит) |

---

# 2. КОД ПРОЕКТА

```
/home/kj/hotel/project/
├── project.godot                           # Godot 4 config (640×360, autoloads, inputs, layers)
│
├── scripts/core/
│   ├── game_manager.gd                     # ✅ Game state, run lifecycle, transitions
│   ├── event_bus.gd                        # ✅ Global event signals
│   ├── save_manager.gd                     # ✅ Run save, settings, records
│   ├── run_state.gd                        # ✅ Per-run state tracking + stat upgrades
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
│   └── gore_system.gd                      # ✅ Blood, severed limbs, pools
│
├── scripts/ai/
│   ├── base_enemy.gd                       # ✅ State machine, per-limb HP, regen, alert chain
│   ├── enemy_staff.gd                      # ✅ Floor 1-5, group courage
│   ├── enemy_guard.gd                      # ✅ Floor 1-7, partner system, radio alerts
│   ├── enemy_handler.gd                    # ✅ Floor 1-6, persistent grabber
│   ├── enemy_berserker.gd                  # ✅ Floor 6, rage-scaling
│   ├── enemy_bodyguard.gd                  # ✅ Floor 2, shield + protect VIP
│   ├── enemy_champion.gd                   # ✅ Floor 8, greatsword combo + parry
│   ├── enemy_chef.gd                       # ✅ Floor 3, oil slick + pan toss
│   ├── enemy_taster.gd                     # ✅ Floor 3, poison blood
│   ├── enemy_seductress.gd                 # ✅ Floor 2, mirror decoys
│   ├── enemy_gladiator.gd                  # ✅ Floor 6, 1v1 duelist + parry
│   ├── enemy_spy.gd                        # ✅ Floor 7, stealth + backstab
│   ├── enemy_shadow_stalker.gd             # ✅ Floor 7, phase-walker
│   ├── enemy_royal_guard.gd                # ✅ Floor 8, formation fighter
│   ├── enemy_demon.gd                      # ✅ Floor 9, no-limb entity
│   ├── enemy_attendant.gd                  # ✅ Floor 5, fog + slow
│   ├── enemy_drowned_one.gd                # ✅ Floor 5, ambush in water
│   ├── enemy_banker.gd                     # ✅ Floor 4, trap activator
│   ├── enemy_vault_drone.gd                # ✅ Floor 4, mechanical no-limb
│   ├── enemy_head_chef.gd                  # ✅ Floor 1 boss (mini-boss)
│   ├── boss_accountant.gd                  # ✅ Floor 4 boss
│   ├── boss_attendant_prime.gd             # ✅ Floor 5 boss
│   ├── boss_champion.gd                    # ✅ Floor 6 boss
│   ├── boss_consort.gd                     # ✅ Floor 8 boss
│   ├── boss_curator.gd                     # ✅ Floor 7 boss
│   ├── boss_gourmand.gd                    # ✅ Floor 3 boss
│   ├── boss_madame.gd                      # ✅ Floor 2 boss
│   ├── boss_satan.gd                       # ✅ Floor 9 final boss (3 phases)
│   └── boss_sister.gd                      # ✅ Floor 9 narrative encounter
│
├── scripts/audio/
│   ├── audio_manager.gd                    # ✅ SFX + music system
│   └── sfx_player.gd                       # ✅ One-shot SFX playback
│
├── scripts/world/
│   ├── room_instance.gd                    # ✅ Room lifecycle + doors
│   ├── loot_spawner.gd                     # ✅ Weapon weights + floor availability
│   └── floor_*.gd / *_config.gd            # ✅ Per-floor configurations
│
├── resources/weapons/
│   ├── weapon_data.gd                      # ✅ Weapon data class
│   ├── melee_machete.tres                  # ✅ Starting weapon
│   ├── melee_knife.tres                    # ✅ Precision mutilation
│   ├── melee_axe.tres                      # ✅ Heavy sever
│   ├── melee_bat.tres                      # ✅ Crowd control
│   ├── melee_cultblade.tres                # ✅ Blood syphon
│   ├── ranged_sawed_off.tres               # ✅ Starting ranged
│   ├── ranged_pistol.tres                  # ✅ Workhorse ranged
│   ├── ranged_smg.tres                     # ✅ Spray and pray
│   ├── ranged_shotgun.tres                 # ✅ Room clearer
│   ├── ranged_cult_pistol.tres             # ✅ Piercing + soul rip
│   ├── improvised_bottle.tres              # ✅ Shatter AoE stun
│   ├── improvised_chair.tres               # ✅ Barricade throw
│   ├── improvised_severed_limb.tres        # ✅ Demoralize throw
│   ├── improvised_wire.tres                # ✅ Garrote + tangle
│   └── improvised_cult_relic.tres           # ✅ Single-use nuke
│
├── scripts/tests/ (22 suites, ~566 tests)
│   ├── test_runner.gd                      # ✅ Lightweight test framework
│   ├── test_base.gd                        # ✅ Assertion library
│   ├── test_run_state.gd                   # ✅ Run state + upgrades
│   ├── test_seed_manager.gd                # ✅ Deterministic RNG
│   ├── test_damage_zone.gd                 # ✅ Zone system
│   ├── test_enemy_health.gd                # ✅ Enemy HP system
│   ├── test_regen_system.gd                # ✅ Limb regeneration
│   ├── test_weapon_data.gd                 # ✅ Weapon definitions
│   ├── test_combat_flow.gd                 # ✅ Combat pipeline
│   ├── test_royal_guard.gd                 # ✅ Floor 8 elite
│   ├── test_champion.gd                    # ✅ Floor 8 duelist
│   ├── test_consort.gd                     # ✅ Floor 8 boss
│   ├── test_floor08.gd                     # ✅ Floor 8 integration
│   ├── test_demon.gd                       # ✅ Floor 9 entity
│   ├── test_sister.gd                      # ✅ Floor 9 narrative
│   ├── test_satan.gd                       # ✅ Final boss
│   ├── test_floor09.gd                     # ✅ Floor 9 integration
│   ├── test_endings.gd                     # ✅ 4 endings
│   ├── test_object_pool.gd                 # ✅ VFX pooling
│   ├── test_screen_effects.gd              # ✅ Screen effects
│   ├── test_m81_integration.gd             # ✅ M8.1 integration
│   ├── test_audio_manager.gd               # ✅ Audio system
│   ├── test_sfx_integration.gd             # ✅ SFX hooks
│   ├── test_stubs_completion.gd            # ✅ Stub verification
│   └── test_balance_audit.gd               # ✅ M8.4: Balance code vs docs audit
│
└── scenes/
    ├── core/game.tscn                      # ✅ Main game scene
    ├── player/player.tscn                  # ✅ Player with all nodes
    ├── enemies/base_enemy.tscn             # ✅ Enemy with 5 hurtbox zones
    ├── weapons/                            # ✅ melee_hit, projectile, thrown_weapon scenes
    └── test/test_runner.tscn               # ✅ Test runner scene
```

---

# 3. КЛЮЧЕВЫЕ ТЕХНИЧЕСКИЕ РЕШЕНИЯ

| Решение | Выбор |
|---------|-------|
| Движок | Godot 4.x, GDScript |
| Viewport | 640×360, масштаб ×2/3/4 |
| Стилиль пиксель-арта | 32×32 tiles, 24×36 персонажи, 3/4 view |
| Collision layers | 8: player_hurt/hit, enemy_hurt/hit, weapon, projectile, env, throwable |
| Autoloads | GameManager, EventBus, SaveManager, AudioManager, GoreSystem, ScreenEffects |
| Ввод | WASD + mouse (attack=ЛКМ, throw=ПКМ, interact=E, switch=Q) |
| Тестирование | Собственный lightweight фреймворк, 22 suites, ~566 тестов |

---

# 4. БАЛАНС-ВЕРИФИКАЦИЯ (M8.4)

## Enemy Audit: 18 types + 10 bosses — 0 mismatches
Все числовые параметры (HP, speed, damage, grab, regen, aggression, coordination) сверены с 11_ENEMY_DESIGN.md и 14_BOSS_DESIGN.md.

## Weapon Audit: 15 weapons — 15/15 .tres resources verified
Все 15 оружий имеют .tres ресурсы, совпадающие с 12_WEAPON_DESIGN.md. 7 ресурсов созданы в M8.4 (shotgun, cult_pistol, bottle, chair, severed_limb, wire, cult_relic).

## DPS Analysis Summary
- Melee DPS range: 59.7 (Cult Relic) — 103.7 (Cult Blade). Variance: ~1.7×. Normal.
- Ranged DPS range: 88.2 (Pistol) — 378.8 (Sawed-off burst). Variance compensated by limited ammo.
- Boss TTK (Head Chef, solo Machete): ~3.0s pure DPS, ~2-3 min with mechanics. Within target.
- No critical outliers found.

## Stat Upgrades: 9/11 base values verified in code
S1-S8, S10 implemented. S9 (Second Wind) and S11 (Bloodlust) are behavioral upgrades applied at combat time (stubs).

## Artifacts: 12 defined in docs, effects stubbed
Artifact .tres resources not yet created. Effects checked via RunState.cult_artifacts array.

---

# 5. ИЗВЕСТНЫЕ ПРОБЛЕМЫ

- Artifact .tres resources not created (effects implemented as code checks, not data-driven)
- S9 Second Wind and S11 Bloodlust activation logic not yet implemented (base values exist)
- Placeholder visuals for gore (need real sprites)
- No music/SFX assets (system code complete)

---

# 6. КАК ЗАПУСТИТЬ ТЕСТЫ

```bash
cd /home/kj/hotel/project
godot --headless --scene scenes/test/test_runner.tscn
```

Критерий: exit code 0. Все 566 тестов pass.
