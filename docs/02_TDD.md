# TECHNICAL DESIGN DOCUMENT — HOTEL
## Version 0.1 — First Draft

---

# 1. ARCHITECTURE OVERVIEW

## 1.1 Engine

- **Godot 4.x** (latest stable)
- **GDScript** — primary language
- **GDExtension (C++)** — backup для performance-critical systems если Needed

## 1.2 Project Structure

```
hotel/
├── docs/                           # Game design documents
├── project/                        # Godot project root
│   ├── project.godot
│   ├── export_presets.cfg
│   ├── icon.svg
│   ├── addons/                     # Third-party plugins
│   ├── resources/                  # Shared data resources
│   │   ├── enemies/                # Enemy data (stats, loot tables)
│   │   ├── weapons/                # Weapon data
│   │   ├── upgrades/               # Upgrade definitions
│   │   ├── floors/                 # Floor configs
│   │   └── palettes/               # Color palette resources
│   ├── scenes/                     # Godot scenes
│   │   ├── core/                   # Core game scenes
│   │   │   ├── game.tscn           # Main game scene
│   │   │   ├── run_manager.tscn    # Run state manager
│   │   │   └── hud.tscn            # HUD overlay
│   │   ├── player/                 # Player scenes
│   │   │   ├── player.tscn
│   │   │   └── player_states/      # State machine states
│   │   ├── enemies/                # Enemy scenes
│   │   │   ├── base_enemy.tscn     # Base enemy template
│   │   │   ├── staff.tscn
│   │   │   ├── guard.tscn
│   │   │   └── ...
│   │   ├── weapons/                # Weapon scenes
│   │   │   ├── base_weapon.tscn    # Base weapon template
│   │   │   ├── melee/
│   │   │   ├── ranged/
│   │   │   └── improvised/
│   │   ├── rooms/                  # Room templates
│   │   │   ├── room_base.tscn      # Base room with camera bounds
│   │   │   └── ...
│   │   ├── floors/                 # Floor scenes
│   │   │   ├── floor_manager.tscn  # Floor orchestrator
│   │   │   ├── floor_01/           # Floor 1 rooms
│   │   │   ├── floor_02/           # Floor 2 rooms
│   │   │   └── ...
│   │   ├── bosses/                 # Boss scenes
│   │   ├── basement/               # Basement escape scene
│   │   ├── effects/                # VFX scenes (blood, particles)
│   │   ├── ui/                     # UI scenes (menus, HUD elements)
│   │   └── cutscene/               # Any narrative sequences
│   ├── scripts/                    # GDScript files
│   │   ├── core/                   # Core systems
│   │   │   ├── game_manager.gd     # Global game state
│   │   │   ├── run_state.gd        # Per-run state tracking
│   │   │   ├── seed_manager.gd     # Run seed + randomization
│   │   │   └── event_bus.gd        # Global event system
│   │   ├── combat/                 # Combat systems
│   │   │   ├── damage_system.gd    # Damage calculation + limb tracking
│   │   │   ├── regen_system.gd     # Enemy regeneration
│   │   │   ├── weapon_manager.gd   # Weapon pickup/use/throw
│   │   │   └── hitbox_manager.gd   # Hitbox/hurtbox management
│   │   ├── ai/                     # Enemy AI
│   │   │   ├── state_machine.gd    # Generic FSM
│   │   │   ├── enemy_ai.gd         # Base enemy AI
│   │   │   ├── behaviors/          # Reusable AI behaviors
│   │   │   └── coordination.gd     # Enemy coordination system
│   │   ├── player/                 # Player scripts
│   │   │   ├── player_controller.gd
│   │   │   ├── player_stats.gd
│   │   │   └── player_state_machine.gd
│   │   ├── world/                  # World/level systems
│   │   │   ├── floor_manager.gd    # Floor loading + transitions
│   │   │   ├── room_manager.gd     # Room state + transitions
│   │   │   ├── loot_spawner.gd     # Random loot placement
│   │   │   ├── enemy_spawner.gd    # Random enemy placement
│   │   │   └── gate_system.gd      # Route variation gates
│   │   ├── effects/                # Gore + VFX
│   │   │   ├── gore_system.gd      # Blood, dismemberment visuals
│   │   │   ├── limb_entity.gd      # Dismembered limb physics
│   │   │   └── destructible.gd     # Destructible environment
│   │   └── ui/                     # UI scripts
│   │       ├── hud.gd
│   │       ├── run_summary.gd
│   │       └── upgrade_picker.gd
│   ├── assets/                     # Raw assets
│   │   ├── sprites/                # Pixel art sprites
│   │   │   ├── player/
│   │   │   ├── enemies/
│   │   │   ├── weapons/
│   │   │   ├── environment/
│   │   │   ├── effects/
│   │   │   └── ui/
│   │   ├── audio/                  # Sound files
│   │   │   ├── music/
│   │   │   ├── sfx/
│   │   │   └── ambient/
│   │   ├── fonts/
│   │   └── shaders/                # Custom shaders
│   └── data/                       # JSON/config data
│       ├── weapons.json
│       ├── enemies.json
│       ├── upgrades.json
│       └── floors.json
```

## 1.3 Naming Conventions

- **Scenes**: `snake_case.tscn`
- **Scripts**: `snake_case.gd`
- **Resources**: `snake_case.tres`
- **Sprites**: `snake_case.png` (atlas: `sprite_name_frames.png`)
- **Folders**: `snake_case/`
- **Constants**: `UPPER_SNAKE_CASE`
- **Variables**: `snake_case`
- **Functions**: `snake_case`
- **Signals**: `snake_case` (past tense for events: `enemy_damaged`)

---

# 2. CORE SYSTEMS

## 2.1 Game Manager (Autoload)

```gdscript
# core/game_manager.gd — Autoload singleton
extends Node

signal run_started(run_seed: int)
signal run_ended(victory: bool)
signal floor_entered(floor_number: int)
signal player_died
signal basement_entered
signal basement_escaped
signal basement_failed

enum GameState { MENU, PLAYING, BASEMENT, PAUSED, GAME_OVER, VICTORY }

var current_state: GameState = GameState.MENU
var current_run: RunState
var seed_manager: SeedManager

func start_new_run() -> void:
    var run_seed = randi()
    seed_manager = SeedManager.new(run_seed)
    current_run = RunState.new()
    current_state = GameState.PLAYING
    run_started.emit(run_seed)

func transition_to_basement() -> void:
    current_state = GameState.BASEMENT
    basement_entered.emit()

func handle_basement_success() -> void:
    current_state = GameState.PLAYING
    basement_escaped.emit()

func handle_basement_failure() -> void:
    current_state = GameState.GAME_OVER
    basement_failed.emit()
    run_ended.emit(false)
```

## 2.2 Run State Manager

```gdscript
# core/run_state.gd — Per-run state tracking
class_name RunState

var current_floor: int = 1
var player_hp: float = 100.0
var player_max_hp: float = 100.0
var player_speed: float = 200.0
var weapons: Array[WeaponData] = []
var max_weapon_slots: int = 2
var stat_upgrades: Dictionary = {}
var cult_artifacts: Array[CultArtifactData] = []
var rooms_cleared: Dictionary = {}  # floor -> room_name -> bool
var mini_boss_defeated: Dictionary = {}  # floor -> bool

func apply_stat_upgrade(upgrade: StatUpgradeData) -> void:
    stat_upgrades[upgrade.stat_name] = stat_upgrades.get(upgrade.stat_name, 0) + upgrade.value
    _recalculate_stats()

func apply_cult_artifact(artifact: CultArtifactData) -> void:
    cult_artifacts.append(artifact)
    _recalculate_stats()

func _recalculate_stats() -> void:
    player_max_hp = 100.0
    player_speed = 200.0
    # Apply all stat modifiers
    for stat_name in stat_upgrades:
        match stat_name:
            "max_hp": player_max_hp += stat_upgrades[stat_name]
            "speed": player_speed += stat_upgrades[stat_name]
    # Apply artifact trade-offs
    for artifact in cult_artifacts:
        player_max_hp *= artifact.hp_multiplier
        player_speed *= artifact.speed_multiplier
```

## 2.3 Seed Manager (Randomization)

```gdscript
# core/seed_manager.gd — Deterministic per-run randomness
class_name SeedManager

var _seed: int
var _rng: RandomNumberGenerator

func _init(run_seed: int) -> void:
    _seed = run_seed
    _rng = RandomNumberGenerator.new()
    _rng.seed = run_seed

func get_floor_seed(floor_number: int) -> int:
    # Deterministic seed per floor
    return _seed * floor_number + floor_number * 7

func get_room_seed(floor_number: int, room_index: int) -> int:
    # Deterministic seed per room
    return _seed * floor_number + room_index * 31

func get_enemy_spawn_config(floor_number: int, room_index: int) -> EnemySpawnConfig:
    var room_rng = RandomNumberGenerator.new()
    room_rng.seed = get_room_seed(floor_number, room_index)
    # Generate spawn configuration
    ...

func get_loot_config(floor_number: int, room_index: int) -> LootConfig:
    var room_rng = RandomNumberGenerator.new()
    room_rng.seed = get_room_seed(floor_number, room_index) + 999
    # Generate loot configuration
    ...

func get_gate_config(floor_number: int) -> GateConfig:
    var floor_rng = RandomNumberGenerator.new()
    floor_rng.seed = get_floor_seed(floor_number) + 777
    # Generate which hub branches are open
    ...
```

## 2.4 Event Bus (Autoload)

```gdscript
# core/event_bus.gd — Decoupled event system (Autoload singleton)
extends Node

# Combat events
signal enemy_damaged(enemy: CharacterBody2D, zone: String, damage: float)
signal enemy_limb_severed(enemy: CharacterBody2D, limb: String)
signal enemy_regen_tick(enemy: CharacterBody2D, limb: String, progress: float)
signal enemy_fully_regenerated(enemy: CharacterBody2D)
signal player_damaged(amount: float)
signal player_captured
signal weapon_thrown(weapon: WeaponData, direction: Vector2)
signal weapon_picked_up(weapon: WeaponData)
signal weapon_hit_target(weapon: WeaponData, target: Node2D)

# Game flow events
signal room_entered(floor_number: int, room_name: String)
signal room_cleared(floor_number: int, room_name: String)
signal mini_boss_defeated(floor_number: int)
signal floor_completed(floor_number: int)
signal upgrade_collected(upgrade_data: Resource)
```

---

# 3. COMBAT SYSTEMS

## 3.1 Damage System

```gdscript
# combat/damage_system.gd
class_name DamageSystem

enum DamageZone { HEAD, LEFT_ARM, RIGHT_ARM, LEFT_LEG, RIGHT_LEG, TORSO }

func apply_damage(target: CharacterBody2D, zone: DamageZone, damage: float, weapon: WeaponData) -> void:
    var limb_hp = target.limb_health[zone]
    limb_hp -= damage

    if limb_hp <= 0:
        _sever_limb(target, zone, weapon)
    else:
        target.limb_health[zone] = limb_hp
        _apply_hit_effects(target, zone, weapon)

    # Pause regen on hit
    target.regen_system.pause_regen(zone, 2.0)  # 2 second pause

    EventBus.enemy_damaged.emit(target, DamageZone.keys()[zone], damage)

func _sever_limb(target: CharacterBody2D, zone: DamageZone, weapon: WeaponData) -> void:
    target.limb_health[zone] = 0
    target.active_limbs.erase(zone)

    # Spawn limb entity (physical object)
    GoreSystem.spawn_severed_limb(target.global_position, zone, target)

    # Update enemy behavior based on lost limb
    target.ai.on_limb_lost(zone)

    EventBus.enemy_limb_severed.emit(target, DamageZone.keys()[zone])

func _apply_hit_effects(target: CharacterBody2D, zone: DamageZone, weapon: WeaponData) -> void:
    # Stagger, knockback, etc based on weapon properties
    if weapon.knockback > 0:
        target.apply_knockback(weapon.knockback_direction, weapon.knockback_force)
    if weapon.stun_chance > 0:
        if randf() < weapon.stun_chance:
            target.apply_stun(weapon.stun_duration)
```

## 3.2 Regeneration System

```gdscript
# combat/regen_system.gd
class_name RegenSystem

var limb_timers: Dictionary = {}  # zone -> {current, max, paused}
var base_regen_time: float = 30.0  # seconds per limb
var speed_multiplier: float = 1.0
var entity: CharacterBody2D

func _init(owner: CharacterBody2D) -> void:
    entity = owner
    for zone in DamageSystem.DamageZone.values():
        limb_timers[zone] = {"current": 0.0, "max": base_regen_time, "paused": false}

func _process(delta: float) -> void:
    for zone in limb_timers:
        var timer = limb_timers[zone]
        if timer.paused:
            timer.paused = false if timer.current <= 0 else true
            timer.current -= delta
            continue
        if entity.limb_health[zone] <= 0:
            timer.max -= delta * speed_multiplier
            if timer.max <= 0:
                _regenerate_limb(zone)

func _regenerate_limb(zone: int) -> void:
    entity.limb_health[zone] = entity.max_limb_health[zone]
    entity.active_limbs.append(zone)
    entity.ai.on_limb_regenerated(zone)
    limb_timers[zone] = {"current": 0.0, "max": base_regen_time, "paused": false}
    EventBus.enemy_fully_regenerated.emit(entity)

func pause_regen(zone: int, duration: float) -> void:
    limb_timers[zone]["paused"] = true
    limb_timers[zone]["current"] = duration

func set_speed_multiplier(mult: float) -> void:
    speed_multiplier = mult
```

## 3.3 Weapon Manager

```gdscript
# combat/weapon_manager.gd
class_name WeaponManager

extends Node2D

signal weapon_equipped(weapon: WeaponData, slot: int)
signal weapon_dropped(weapon: WeaponData)

var equipped_weapons: Array[WeaponData] = [null, null]
var active_slot: int = 0
var max_slots: int = 2

func _ready() -> void:
    # Connect input
    pass

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("attack"):
        _attack()
    elif event.is_action_pressed("throw"):
        _throw_weapon()
    elif event.is_action_pressed("switch_weapon"):
        _switch_slot()
    elif event.is_action_pressed("pick_up"):
        _try_pick_up()

func _attack() -> void:
    var weapon = equipped_weapons[active_slot]
    if weapon == null: return
    if weapon.weapon_type == WeaponData.WeaponType.MELEE:
        _melee_attack(weapon)
    elif weapon.weapon_type == WeaponData.WeaponType.RANGED:
        _ranged_attack(weapon)

func _throw_weapon() -> void:
    var weapon = equipped_weapons[active_slot]
    if weapon == null: return

    var throw_dir = (get_global_mouse_position() - global_position).normalized()
    var projectile = weapon.throw_scene.instantiate()
    projectile.setup(weapon, throw_dir, get_parent())
    get_tree().current_scene.add_child(projectile)

    equipped_weapons[active_slot] = null
    weapon_dropped.emit(weapon)
    EventBus.weapon_thrown.emit(weapon, throw_dir)

func _try_pick_up() -> void:
    # Check for nearby weapons on ground
    var area = %PickupArea as Area2D
    var bodies = area.get_overlapping_bodies()
    var closest_weapon = null
    var closest_dist = INF
    for body in bodies:
        if body is WeaponPickup:
            var dist = global_position.distance_to(body.global_position)
            if dist < closest_dist:
                closest_dist = dist
                closest_weapon = body
    if closest_weapon:
        _equip_weapon(closest_weapon.weapon_data)

func _equip_weapon(weapon: WeaponData) -> void:
    # Find empty slot or replace current
    if equipped_weapons[0] == null:
        equipped_weapons[0] = weapon
        weapon_equipped.emit(weapon, 0)
    elif equipped_weapons[1] == null:
        equipped_weapons[1] = weapon
        weapon_equipped.emit(weapon, 1)
    else:
        # Drop current, equip new
        var dropped = equipped_weapons[active_slot]
        _drop_weapon(dropped)
        equipped_weapons[active_slot] = weapon
        weapon_equipped.emit(weapon, active_slot)
```

## 3.4 Hitbox System

```
Structure:
- CharacterBody2D (enemy/player)
  ├── HitboxHurtboxManager
  │   ├── HurtboxMain (Area2D + CollisionShape2D) — torso
  │   ├── HurtboxHead (Area2D + CollisionShape2D)
  │   ├── HurtboxLeftArm (Area2D + CollisionShape2D)
  │   ├── HurtboxRightArm (Area2D + CollisionShape2D)
  │   ├── HurtboxLeftLeg (Area2D + CollisionShape2D)
  │   └── HurtboxRightLeg (Area2D + CollisionShape2D)
  └── Hitbox (Area2D + CollisionShape2D) — attack area

Layers:
- Layer 1: Player hurtbox
- Layer 2: Player hitbox
- Layer 3: Enemy hurtbox
- Layer 4: Enemy hitbox
- Layer 5: Weapon hitbox
- Layer 6: Projectile hitbox
- Layer 7: Environment
- Layer 8: Throwable

Collision masks:
- Player hitbox → Layer 3 (enemy hurtbox)
- Enemy hitbox → Layer 1 (player hurtbox)
- Weapon → Layer 3 (enemy hurtbox) + Layer 7 (environment)
- Throwable → Layer 3 + Layer 4 + Layer 7
```

---

# 4. AI SYSTEM

## 4.1 State Machine Architecture

```gdscript
# ai/state_machine.gd
class_name StateMachine

extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.state_machine = self
            child.entity = owner
    if initial_state:
        current_state = initial_state
        current_state.enter()

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)

func transition_to(state_name: String) -> void:
    var new_state = states.get(state_name.to_lower())
    if new_state and new_state != current_state:
        current_state.exit()
        current_state = new_state
        current_state.enter()

# ai/state.gd
class_name State

extends Node

var state_machine: StateMachine
var entity: CharacterBody2D

func enter() -> void:
    pass

func exit() -> void:
    pass

func update(delta: float) -> void:
    pass

func physics_update(delta: float) -> void:
    pass
```

## 4.2 Enemy AI States

```
Base Enemy State Machine:

PATROL ──► ALERT ──► CHASE ──► ENGAGE ──│
  ▲          │          │          │     │
  │          ▼          │          ▼     │
  └──── IDLE ◄──────────┘   MUTILATED   │
                                │        │
                                ▼        │
                          RETREAT ◄──────┘
                                │
                                ▼
                          STUNNED / GRABBING
```

**State Descriptions:**

| State | Behavior |
|-------|----------|
| PATROL | Move between waypoints, passive |
| ALERT | Heard/saw player, investigate, alert nearby |
| CHASE | Move toward player, call for support |
| ENGAGE | Attack within range, use weapon |
| MUTILATED | Modified behavior based on lost limbs |
| RETREAT | Low threat capability, retreat to regroup |
| STUNNED | Hit by stun effect, temporary disable |
| GRABBING | Attempting to grab player (specific enemy types) |

## 4.3 Enemy Coordination

```gdscript
# ai/coordination.gd
class_name EnemyCoordinator

extends Node

var active_enemies: Array[CharacterBody2D] = []
var alert_level: float = 0.0  # 0-1, room-wide awareness

func register_enemy(enemy: CharacterBody2D) -> void:
    active_enemies.append(enemy)
    enemy.tree_exited.connect(func(): active_enemies.erase(enemy))

func alert_nearby(source: CharacterBody2D, radius: float = 300.0) -> void:
    for enemy in active_enemies:
        if enemy == source: continue
        if enemy.global_position.distance_to(source.global_position) <= radius:
            enemy.ai.transition_to("alert")

func get_attack_role(enemy: CharacterBody2D) -> String:
    # Assign roles: "flanker", "frontal", "support"
    var role_count = {"flanker": 0, "frontal": 0, "support": 0}
    for e in active_enemies:
        if e.ai.current_state.name == "engage":
            role_count[e.ai.attack_role] += 1
    # Assign least used role
    var min_role = role_count.keys().min_custom(func(k): return role_count[k])
    return min_role
```

---

# 5. WORLD SYSTEMS

## 5.1 Floor Manager

```gdscript
# world/floor_manager.gd
class_name FloorManager

extends Node

var current_floor: int = 1
var rooms: Dictionary = {}  # room_name -> RoomInstance
var hub_room: String = ""
var active_room: String = ""

func load_floor(floor_number: int, run_seed: int) -> void:
    current_floor = floor_number
    var floor_config = load("res://resources/floors/floor_%02d.tres" % floor_number)
    var gate_config = GameManager.seed_manager.get_gate_config(floor_number)

    # Load rooms based on gate config
    for room_data in floor_config.rooms:
        if gate_config.is_room_accessible(room_data.name):
            var room = room_data.scene.instantiate()
            rooms[room_data.name] = room
            add_child(room)
            # Setup room: spawn enemies, place loot
            _setup_room(room, floor_number, run_seed)

func _setup_room(room: Node2D, floor_number: int, run_seed: int) -> void:
    var room_index = rooms.keys().find(room.name)
    var enemy_config = GameManager.seed_manager.get_enemy_spawn_config(floor_number, room_index)
    var loot_config = GameManager.seed_manager.get_loot_config(floor_number, room_index)
    room.setup(enemy_config, loot_config)

func transition_to_room(room_name: String) -> void:
    if active_room:
        rooms[active_room].deactivate()
    active_room = room_name
    rooms[room_name].activate()
    EventBus.room_entered.emit(current_floor, room_name)
```

## 5.2 Room System

```gdscript
# world/room_instance.gd
class_name RoomInstance

extends Node2D

@export var room_bounds: Rect2  # Camera limits
@export var spawn_points: Array[Marker2D]
@export var loot_zones: Array[Marker2D]
@export var doors: Array[Door]

var active_enemies: Array[CharacterBody2D] = []
var is_active: bool = false
var is_cleared: bool = false

func setup(enemy_config: EnemySpawnConfig, loot_config: LootConfig) -> void:
    _spawn_enemies(enemy_config)
    _place_loot(loot_config)

func activate() -> void:
    is_active = true
    # Update camera bounds
    var camera = get_tree().get_first_node_in_group("camera")
    camera.set_limits(room_bounds)
    # Activate enemies in range

func deactivate() -> void:
    is_active = false
    # Don't destroy enemies, just pause their AI

func _spawn_enemies(config: EnemySpawnConfig) -> void:
    for spawn in config.spawns:
        var enemy_scene = load("res://scenes/enemies/%s.tscn" % spawn.enemy_type)
        var enemy = enemy_scene.instantiate()
        enemy.global_position = spawn_points[spawn.point_index].global_position
        add_child(enemy)
        active_enemies.append(enemy)

func _place_loot(config: LootConfig) -> void:
    for loot in config.items:
        var pickup_scene = load("res://scenes/weapons/weapon_pickup.tscn")
        var pickup = pickup_scene.instantiate()
        pickup.setup(loot)
        pickup.global_position = loot_zones[loot.zone_index].global_position
        add_child(pickup)
```

---

# 6. GORE SYSTEM

## 6.1 Architecture

```gdscript
# effects/gore_system.gd
class_name GoreSystem

extends Node2D

var blood_particles: PackedScene = preload("res://scenes/effects/blood_splash.tscn")
var limb_scene: PackedScene = preload("res://scenes/effects/severed_limb.tscn")
var blood_pool_scene: PackedScene = preload("res://scenes/effects/blood_pool.tscn")

func spawn_severed_limb(position: Vector2, limb_type: int, owner: CharacterBody2D) -> void:
    var limb = limb_scene.instantiate()
    limb.global_position = position
    limb.setup(limb_type, owner.get_limb_sprite(limb_type))
    get_tree().current_scene.add_child(limb)

    # Blood splash
    var blood = blood_particles.instantiate()
    blood.global_position = position
    blood.emitting = true
    get_tree().current_scene.add_child(blood)

    # Blood pool (persistent)
    var pool = blood_pool_scene.instantiate()
    pool.global_position = position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
    get_tree().current_scene.add_child(pool)

func spawn_blood_splash(position: Vector2, direction: Vector2) -> void:
    var blood = blood_particles.instantiate()
    blood.global_position = position
    blood.direction = direction
    blood.emitting = true
    get_tree().current_scene.add_child(blood)
```

## 6.2 Limb Entity (Physics Object)

```gdscript
# effects/limb_entity.gd
class_name SeveredLimb

extends RigidBody2D

var limb_type: int
var can_be_picked_up: bool = true
var lifetime: float = 30.0  # Despawn after 30 seconds

func setup(type: int, texture: Texture2D) -> void:
    limb_type = type
    $Sprite2D.texture = texture
    # Apply random impulse for visual flair
    apply_impulse(Vector2(randf_range(-100, 100), randf_range(-200, -50)))

func _process(delta: float) -> void:
    lifetime -= delta
    if lifetime <= 0:
        queue_free()
```

## 6.3 Destructible Environment

```gdscript
# effects/destructible.gd
class_name Destructible

extends StaticBody2D

@export var max_health: float = 50.0
@export var debris_scene: PackedScene
@export var drop_table: LootTable

var health: float

func _ready() -> void:
    health = max_health

func take_damage(amount: float) -> void:
    health -= amount
    _update_visual()
    if health <= 0:
        _destroy()

func _update_visual() -> void:
    # Crack/damage overlay based on health %
    var damage_ratio = 1.0 - (health / max_health)
    $DamageOverlay.modulate.a = damage_ratio

func _destroy() -> void:
    if debris_scene:
        var debris = debris_scene.instantiate()
        debris.global_position = global_position
        get_parent().add_child(debris)
    if drop_table:
        var drop = drop_table.roll()
        if drop:
            _spawn_drop(drop)
    queue_free()
```

---

# 7. CAMERA SYSTEM

```gdscript
# core/camera_controller.gd
class_name CameraController

extends Camera2D

var bounds: Rect2 = Rect2()
var target: Node2D
var smoothing: float = 8.0

func _process(delta: float) -> void:
    if target:
        global_position = global_position.lerp(target.global_position, smoothing * delta)
        _clamp_to_bounds()

func set_limits(new_bounds: Rect2) -> void:
    bounds = new_bounds
    _clamp_to_bounds()

func _clamp_to_bounds() -> void:
    var half_viewport = get_viewport_rect().size / 2.0 / zoom
    global_position.x = clampf(global_position.x,
        bounds.position.x + half_viewport.x,
        bounds.end.x - half_viewport.x)
    global_position.y = clampf(global_position.y,
        bounds.position.y + half_viewport.y,
        bounds.end.y - half_viewport.y)
```

---

# 8. SAVE SYSTEM

Roguelike = minimal saving. Only save:
- Run in progress (current floor, HP, upgrades)
- Settings (audio, controls)
- Best records (deepest floor reached, fastest run)

No permanent unlocks in MVP (potential future feature).

```gdscript
# core/save_manager.gd
class_name SaveManager

extends Node

const SAVE_PATH = "user://hotel_save.json"

func save_run_state(run: RunState) -> void:
    var data = {
        "current_floor": run.current_floor,
        "player_hp": run.player_hp,
        "player_max_hp": run.player_max_hp,
        "player_speed": run.player_speed,
        "weapons": run.weapons.map(func(w): return w.resource_path),
        "stat_upgrades": run.stat_upgrades,
        "cult_artifacts": run.cult_artifacts.map(func(a): return a.resource_path),
        "run_seed": GameManager.seed_manager._seed,
    }
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))

func load_run_state() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    return JSON.parse_string(file.get_as_text())

func save_settings(settings: Dictionary) -> void:
    var file = FileAccess.open("user://hotel_settings.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(settings))

func save_record(deepest_floor: int, fastest_time: float) -> void:
    var records = load_records()
    if deepest_floor > records.get("deepest_floor", 0):
        records["deepest_floor"] = deepest_floor
    if fastest_time < records.get("fastest_time", INF):
        records["fastest_time"] = fastest_time
    var file = FileAccess.open("user://hotel_records.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(records))
```

---

# 9. PERFORMANCE BUDGET

## 9.1 Targets

- 60 FPS stable
- Max 10 active enemies
- Max 50 physics objects (limbs, debris)
- Max 200 particles active
- Room-by-room loading (only active room processes)

## 9.2 Optimization Strategies

- **Object pooling** для blood particles, debris, projectile
- **Room deactivation** — враги в неактивных комнатах frozen
- **LOD для gore** — fewer particles при high enemy count
- **Limited blood pools** — max N per room, oldest despawns
- **Sprite batching** — Godot 4 handles automatically for CanvasItem
- **Navigation** — NavigationRegion2D per room, only active room navigates
- **Process mode** — inactive rooms set to PROCESS_MODE_DISABLED

## 9.3 Profiling Points

- Enemy AI update frequency (consider tick-based AI, not per-frame)
- Blood particle count per room
- Number of RigidBody2D (severed limbs have lifetime limit)
- Navigation mesh complexity per room
