class_name EnemySpawner
extends Node

## EnemySpawner — Seed-based enemy spawn system.
## Uses SeedManager for deterministic spawns, applies per-floor scaling from 11_ENEMY_DESIGN.md.

const MAX_ENEMIES_PER_ROOM: int = 10

# Enemy scene paths (M4: Floor 1 pool + placeholder entries for later floors)
const ENEMY_SCENES: Dictionary = {
	"staff": "res://scenes/enemies/staff.tscn",
	"guard": "res://scenes/enemies/guard.tscn",
	"handler": "res://scenes/enemies/handler.tscn",
	"head_chef": "res://scenes/enemies/head_chef.tscn",
	# Floor 2+ (placeholder — scenes created in M6+)
	"seductress": "res://scenes/enemies/seductress.tscn",
	"bodyguard": "res://scenes/enemies/bodyguard.tscn",
	# Floor 3+
	"chef": "res://scenes/enemies/chef.tscn",
	"taster": "res://scenes/enemies/taster.tscn",
	"butcher": "res://scenes/enemies/butcher.tscn",
	# Floor 4+
	"banker": "res://scenes/enemies/banker.tscn",
	"vault_drone": "res://scenes/enemies/vault_drone.tscn",
	# Floor 5+
	"attendant": "res://scenes/enemies/attendant.tscn",
	"drowned_one": "res://scenes/enemies/drowned_one.tscn",
	# Floor 6+
	"gladiator": "res://scenes/enemies/gladiator.tscn",
	"berserker": "res://scenes/enemies/berserker.tscn",
	# Floor 7+
	"spy": "res://scenes/enemies/spy.tscn",
	"shadow_stalker": "res://scenes/enemies/shadow_stalker.tscn",
	"cultist": "res://scenes/enemies/cultist.tscn",
	# Floor 8+
	"royal_guard": "res://scenes/enemies/royal_guard.tscn",
	"champion": "res://scenes/enemies/champion.tscn",
	# Floor 9+
	"demon": "res://scenes/enemies/demon.tscn",
	# Boss entries (used by FloorManager and boss spawn systems)
	"madame": "res://scenes/bosses/boss_madame.tscn",
	"gourmand": "res://scenes/bosses/boss_gourmand.tscn",
	"accountant": "res://scenes/bosses/boss_accountant.tscn",
	"attendant_prime": "res://scenes/bosses/boss_attendant_prime.tscn",
	"boss_champion": "res://scenes/bosses/boss_champion.tscn",
	"curator": "res://scenes/bosses/boss_curator.tscn",
	"consort": "res://scenes/bosses/boss_consort.tscn",
	"sister": "res://scenes/bosses/boss_sister.tscn",
	"satan": "res://scenes/bosses/boss_satan.tscn",
}

# Per-floor enemy pools (11_ENEMY_DESIGN.md section 4.3)
const FLOOR_ENEMY_POOLS: Dictionary = {
	1: ["staff", "guard", "handler"],
	2: ["staff", "guard", "seductress", "bodyguard"],
	3: ["staff", "guard", "chef", "taster", "butcher"],
	4: ["guard", "banker", "vault_drone"],
	5: ["staff", "attendant", "drowned_one"],
	6: ["gladiator", "berserker", "butcher"],
	7: ["spy", "shadow_stalker", "cultist"],
	8: ["royal_guard", "champion", "cultist"],
	9: ["demon"],
}

# Per-floor scaling multipliers (11_ENEMY_DESIGN.md section 5.1)
# Format: [hp_mult, speed_mult, regen_mult, aggression_mult]
const FLOOR_SCALING: Dictionary = {
	1: [1.0, 1.0, 1.0, 1.0],
	2: [1.0, 1.05, 1.0, 1.1],
	3: [1.1, 1.05, 1.05, 1.1],
	4: [1.1, 1.1, 1.05, 1.15],
	5: [1.15, 1.1, 1.1, 1.15],
	6: [1.2, 1.15, 1.15, 1.25],
	7: [1.25, 1.15, 1.15, 1.25],
	8: [1.3, 1.2, 1.2, 1.3],
	9: [1.5, 1.3, 1.3, 1.5],
}


## Spawn enemies in a room using seed-based configuration.
## Returns array of spawned enemy CharacterBody2D nodes.
static func spawn_enemies(room: RoomInstance, floor_number: int, room_index: int, seed_mgr: SeedManager) -> Array[CharacterBody2D]:
	var spawned: Array[CharacterBody2D] = []
	if room.spawn_points.is_empty():
		return spawned

	# Get seed-based enemy config
	var config := seed_mgr.get_room_enemy_config(floor_number, room_index, room.spawn_points.size())
	var enemy_count: int = config["count"]
	var active_points: Array = config["active_points"]

	# Get floor-specific enemy pool
	var pool: Array = FLOOR_ENEMY_POOLS.get(floor_number, FLOOR_ENEMY_POOLS[1])

	# Create seeded RNG for type selection
	var rng := seed_mgr.get_room_rng(floor_number, room_index)
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = rng.seed + 42

	# Get scaling for this floor
	var scaling: Array = FLOOR_SCALING.get(floor_number, FLOOR_SCALING[1])
	var hp_mult: float = scaling[0]
	var speed_mult: float = scaling[1]

	# Spawn enemies at active spawn points
	for i in range(mini(mini(enemy_count, active_points.size()), MAX_ENEMIES_PER_ROOM)):
		var point_idx: int = int(active_points[i])
		if point_idx >= room.spawn_points.size():
			continue

		# Pick enemy type from floor pool (seeded random)
		var type_idx := local_rng.randi_range(0, pool.size() - 1)
		var enemy_type: String = pool[type_idx]

		# Load enemy scene
		var scene_path: String = ENEMY_SCENES.get(enemy_type, "")
		if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
			# Fallback to staff for Floor 1, skip for unknown types
			if ENEMY_SCENES.has("staff") and ResourceLoader.exists(ENEMY_SCENES["staff"]):
				scene_path = ENEMY_SCENES["staff"]
				enemy_type = "staff"
			else:
				continue

		var scene: PackedScene = load(scene_path)
		var pos: Vector2 = room.spawn_points[point_idx].position

		var enemy := room.add_enemy(scene, pos)
		if enemy != null:
			# Apply per-floor scaling
			_apply_scaling(enemy, hp_mult, speed_mult)
			spawned.append(enemy)

	return spawned


## Spawn enemies in a room using predefined config (for floor_manager compatibility).
static func spawn_from_config(room: RoomInstance, enemies_config: Array[Dictionary], floor_number: int) -> Array[CharacterBody2D]:
	var spawned: Array[CharacterBody2D] = []
	if enemies_config.is_empty():
		return spawned

	var scaling: Array = FLOOR_SCALING.get(floor_number, FLOOR_SCALING[1])
	var hp_mult: float = scaling[0]
	var speed_mult: float = scaling[1]

	var spawn_points := room.spawn_points.duplicate()
	spawn_points.shuffle()
	var spawn_idx := 0
	var enemy_count := 0

	for enemy_group: Dictionary in enemies_config:
		var type: String = enemy_group["type"]
		var count: int = enemy_group["count"]

		var scene_path: String = ENEMY_SCENES.get(type, "")
		if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
			continue

		var scene: PackedScene = load(scene_path)
		for i in range(count):
			if enemy_count >= MAX_ENEMIES_PER_ROOM:
				return spawned
			var pos := Vector2(room.room_bounds.size.x * 0.5, room.room_bounds.size.y * 0.5)
			if spawn_idx < spawn_points.size():
				pos = spawn_points[spawn_idx].position
				spawn_idx += 1
			var enemy := room.add_enemy(scene, pos)
			if enemy != null:
				_apply_scaling(enemy, hp_mult, speed_mult)
				spawned.append(enemy)
				enemy_count += 1

	return spawned


## Apply per-floor HP/speed scaling to an enemy.
static func _apply_scaling(enemy: CharacterBody2D, hp_mult: float, speed_mult: float) -> void:
	# Scale HP if enemy has max_hp property
	if "max_hp" in enemy:
		enemy.max_hp = float(enemy.max_hp) * hp_mult
		if "hp" in enemy:
			enemy.hp = float(enemy.hp) * hp_mult
	# Scale speed if enemy has speed/move_speed property
	if "speed" in enemy:
		enemy.speed = float(enemy.speed) * speed_mult
	elif "move_speed" in enemy:
		enemy.move_speed = float(enemy.move_speed) * speed_mult
	# Store scaling metadata for reference
	enemy.set_meta("floor_hp_mult", hp_mult)
	enemy.set_meta("floor_speed_mult", speed_mult)


## Basement-specific scaling (19_BASEMENT_DESIGN.md section 3.2)
const BASEMENT_SCALING: Dictionary = {
	1: {"enemies": [5, 6], "types": ["staff", "guard"], "hp": 0.8, "speed": 0.9},
	2: {"enemies": [5, 6], "types": ["staff", "guard"], "hp": 0.8, "speed": 0.9},
	3: {"enemies": [6, 7], "types": ["staff", "guard", "handler"], "hp": 1.0, "speed": 1.0},
	4: {"enemies": [6, 7], "types": ["staff", "guard", "handler"], "hp": 1.0, "speed": 1.0},
	5: {"enemies": [7, 8], "types": ["guard", "handler"], "hp": 1.1, "speed": 1.1},
	6: {"enemies": [7, 8], "types": ["guard", "handler"], "hp": 1.1, "speed": 1.1},
	7: {"enemies": [8, 9], "types": ["guard", "handler"], "hp": 1.2, "speed": 1.15},
	8: {"enemies": [8, 9], "types": ["guard", "handler"], "hp": 1.2, "speed": 1.15},
	9: {"enemies": [9, 10], "types": ["demon"], "hp": 1.5, "speed": 1.3},
}
