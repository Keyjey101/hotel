class_name LootSpawner
extends Node

## LootSpawner — Seed-based loot placement system.
## Uses SeedManager for deterministic loot, weights from 12_WEAPON_DESIGN.md.

# Weapon loot weights (12_WEAPON_DESIGN.md section 7.2)
const WEAPON_WEIGHTS: Dictionary = {
	# Common (weight 10)
	"melee_knife": 10,
	"ranged_pistol": 10,
	"melee_bottle": 10,
	# Uncommon (weight 5)
	"melee_machete": 5,
	"melee_bat": 5,
	"ranged_smg": 5,
	"melee_wire": 5,
	# Rare (weight 3)
	"melee_axe": 3,
	"ranged_shotgun": 3,
	"melee_chair": 3,
	# Very Rare (weight 1)
	"melee_cult_blade": 1,
	"ranged_cult_pistol": 1,
	# Ultra Rare (weight 0.5)
	"cult_relic": 0.5,
}

# Weapon availability per floor (12_WEAPON_DESIGN.md section 7.1)
# true = available, false = not available
const WEAPON_FLOOR_AVAILABILITY: Dictionary = {
	"melee_knife":       [1, 1, 1, 1, 1, 1, 1, 1, 1],
	"ranged_pistol":      [1, 1, 1, 1, 1, 1, 1, 1, 1],
	"melee_bottle":      [1, 1, 1, 1, 1, 1, 1, 1, 1],
	"melee_machete":     [1, 1, 1, 1, 1, 1, 1, 1, 1],
	"melee_bat":         [1, 1, 1, 1, 1, 1, 1, 1, 1],
	"melee_axe":         [1, 1, 1, 1, 1, 1, 1, 1, 1],
	"ranged_smg":        [0, 1, 1, 1, 1, 1, 1, 1, 1],
	"melee_wire":        [0, 1, 1, 1, 1, 1, 1, 1, 1],
	"ranged_shotgun":    [0, 0, 1, 1, 1, 1, 1, 1, 1],
	"melee_chair":       [1, 1, 1, 1, 1, 1, 1, 1, 1],
	"melee_cult_blade":  [0, 1, 1, 1, 1, 1, 1, 1, 1],
	"ranged_cult_pistol":[0, 0, 1, 1, 1, 1, 1, 1, 1],
	"cult_relic":        [0, 0, 0, 1, 0, 1, 0, 1, 1],
}

# Starting loadout (01_GDD.md section 3.3)
const STARTING_WEAPONS: Array[String] = ["melee_machete", "ranged_sawed_off"]

# Stat upgrade types
const STAT_UPGRADE_TYPES: Array[String] = [
	"max_hp", "speed", "damage_melee", "damage_ranged", "damage_throw",
	"damage_reduction", "grab_resist", "pickup_speed", "ammo_bonus"
]

# Loot counts by room type (13_FLOOR_DESIGN.md section 1.3)
const ROOM_LOOT_COUNTS: Dictionary = {
	"corridor": {"min": 0, "max": 1, "ammo_only": true},
	"chamber": {"min": 1, "max": 2},
	"storage": {"min": 2, "max": 3},
	"gallery": {"min": 1, "max": 2},
	"service": {"min": 0, "max": 1},
	"trap": {"min": 1, "max": 1},
	"hub": {"min": 1, "max": 1},
	"boss": {"min": 1, "max": 1, "artifact_only": true},
}


## Spawn loot in a room using seed-based configuration.
static func spawn_loot(room: RoomInstance, floor_number: int, room_index: int, seed_mgr: SeedManager, key_room: String = "") -> void:
	if room.loot_zones.is_empty() and room.room_type != "boss":
		return

	# Boss room: always 1 cult artifact
	if room.room_type == "boss":
		_spawn_boss_loot(room, floor_number, seed_mgr)
		return

	var loot_config := seed_mgr.get_room_loot_config(floor_number, room_index, room.loot_zones.size())
	var loot_count: int = loot_config["count"]

	# Clamp loot count by room type
	var room_cfg: Dictionary = ROOM_LOOT_COUNTS.get(room.room_type, {"min": 1, "max": 2})
	loot_count = clampi(loot_count, room_cfg.get("min", 0), room_cfg.get("max", 3))

	# Corridors: ammo only
	if room_cfg.get("ammo_only", false):
		_spawn_ammo(room, floor_number, seed_mgr)
		return

	# Seeded RNG for loot selection
	var rng := RandomNumberGenerator.new()
	rng.seed = loot_config["seed"]

	# Get available weapons for this floor
	var available_weapons := _get_available_weapons(floor_number)

	var loot_idx := 0
	for i in range(loot_count):
		if loot_idx >= room.loot_zones.size():
			break

		var pos: Vector2 = room.loot_zones[loot_idx].position
		loot_idx += 1

		# Decide loot type: weapon (60%), upgrade (30%), ammo (10%)
		var roll := rng.randf()
		if roll < 0.6 and available_weapons.size() > 0:
			_spawn_weapon_pickup(room, pos, available_weapons, rng)
		elif roll < 0.9:
			_spawn_stat_upgrade(room, pos, rng)
		else:
			_spawn_ammo_at(room, pos)

	# Key: if this room is the key room
	if room.room_id == key_room and key_room != "":
		var key_pos := Vector2(room.room_bounds.size.x * 0.5, room.room_bounds.size.y * 0.5)
		if loot_idx < room.loot_zones.size():
			key_pos = room.loot_zones[loot_idx].position
		_spawn_key(room, key_pos)


## Give player starting loadout: Machete (slot 0) + Sawed-off (slot 1).
static func give_starting_loadout(run_state: RunState) -> void:
	for i in range(STARTING_WEAPONS.size()):
		if i >= run_state.weapon_slots.size():
			break
		var weapon_id: String = STARTING_WEAPONS[i]
		var path := "res://resources/weapons/%s.tres" % weapon_id
		if ResourceLoader.exists(path):
			run_state.weapon_slots[i] = load(path)
		else:
			push_warning("[LootSpawner] Starting weapon resource not found: %s" % path)


## Get available weapons for a floor, with weights.
static func _get_available_weapons(floor_number: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var floor_idx := floor_number - 1
	for weapon_id in WEAPON_WEIGHTS:
		var avail: Array = WEAPON_FLOOR_AVAILABILITY.get(weapon_id, [])
		if floor_idx >= 0 and floor_idx < avail.size() and avail[floor_idx] == 1:
			result.append({"id": weapon_id, "weight": WEAPON_WEIGHTS[weapon_id]})
	return result


## Weighted random selection from weapon pool.
static func _weighted_select(pool: Array[Dictionary], rng: RandomNumberGenerator) -> String:
	if pool.is_empty():
		return ""
	var total_weight := 0.0
	for item in pool:
		total_weight += item["weight"]
	var roll := rng.randf() * total_weight
	var accumulated := 0.0
	for item in pool:
		accumulated += item["weight"]
		if roll <= accumulated:
			return item["id"]
	return pool[-1]["id"]


## Create a weapon pickup in the room.
static func _spawn_weapon_pickup(room: RoomInstance, pos: Vector2, available_weapons: Array[Dictionary], rng: RandomNumberGenerator) -> void:
	var weapon_id := _weighted_select(available_weapons, rng)
	if weapon_id.is_empty():
		return

	var pickup := _create_pickup_node({"type": "weapon", "id": weapon_id}, pos)
	room.add_child(pickup)


## Create a stat upgrade pickup.
static func _spawn_stat_upgrade(room: RoomInstance, pos: Vector2, rng: RandomNumberGenerator) -> void:
	var type_idx := rng.randi_range(0, STAT_UPGRADE_TYPES.size() - 1)
	var upgrade_type: String = STAT_UPGRADE_TYPES[type_idx]
	var pickup := _create_pickup_node({"type": "stat_upgrade", "id": upgrade_type}, pos)
	room.add_child(pickup)


## Create an ammo pickup.
static func _spawn_ammo(room: RoomInstance, floor_number: int, seed_mgr: SeedManager) -> void:
	if room.loot_zones.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_mgr.get_room_rng(floor_number, 0).seed + 555
	if rng.randf() < 0.5:
		return  # 50% chance for ammo in corridor
	_spawn_ammo_at(room, room.loot_zones[0].position)


## Create an ammo pickup at specific position.
static func _spawn_ammo_at(room: RoomInstance, pos: Vector2) -> void:
	var pickup := _create_pickup_node({"type": "ammo", "id": "ammo"}, pos)
	room.add_child(pickup)


## Create a key pickup.
static func _spawn_key(room: RoomInstance, pos: Vector2) -> void:
	var pickup := _create_pickup_node({"type": "key", "id": "floor_key"}, pos)
	room.add_child(pickup)


## Spawn an artifact pickup in a room using the ArtifactRegistry.
static func spawn_artifact_pickup(room: RoomInstance, rarity_weights: Dictionary = {}) -> void:
	if ArtifactRegistry == null:
		return
	var pos := Vector2(room.room_bounds.size.x * 0.5, room.room_bounds.size.y * 0.5)
	if room.loot_zones.size() > 0:
		pos = room.loot_zones[0].position
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(room.room_id) + 777
	var weights := rarity_weights if not rarity_weights.is_empty() else {1: 0.3, 2: 0.5, 3: 0.2}
	var art: CultArtifact = ArtifactRegistry.get_random_artifact(weights, rng)
	if art == null:
		return
	var pickup := _create_pickup_node({"type": "cult_artifact", "id": art.id}, pos)
	room.add_child(pickup)


## Spawn a specific stat upgrade pickup in a room.
static func spawn_upgrade_pickup(room: RoomInstance, upgrade_id: String) -> void:
	if UpgradeRegistry == null:
		return
	var upg: StatUpgrade = UpgradeRegistry.get_upgrade(upgrade_id)
	if upg == null:
		return
	var pos := Vector2(room.room_bounds.size.x * 0.5, room.room_bounds.size.y * 0.5)
	if room.loot_zones.size() > 0:
		pos = room.loot_zones[0].position
	var pickup := _create_pickup_node({"type": "stat_upgrade", "id": upgrade_id}, pos)
	room.add_child(pickup)


## Boss room: 1 cult artifact.
static func _spawn_boss_loot(room: RoomInstance, floor_number: int, seed_mgr: SeedManager) -> void:
	var pos := Vector2(room.room_bounds.size.x * 0.5, room.room_bounds.size.y * 0.5)
	if room.loot_zones.size() > 0:
		pos = room.loot_zones[0].position
	var pickup := _create_pickup_node({"type": "cult_artifact", "id": "random"}, pos)
	room.add_child(pickup)


## Create a generic pickup Area2D node (matches floor_manager.gd pattern).
static func _create_pickup_node(loot_item: Dictionary, pos: Vector2) -> Area2D:
	var pickup := Area2D.new()
	pickup.name = "Pickup_%s" % loot_item.get("type", "item")
	pickup.position = pos
	pickup.add_to_group("pickups")

	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 16)
	var col := CollisionShape2D.new()
	col.shape = shape
	pickup.add_child(col)

	# Visual
	var visual := ColorRect.new()
	visual.size = Vector2(12, 12)
	visual.position = Vector2(-6, -6)
	match loot_item.get("type", ""):
		"weapon":
			visual.color = Color(0.2, 0.6, 1.0, 0.8)
		"key":
			visual.color = Color(1.0, 0.9, 0.0, 0.9)
			pickup.set_meta("is_key", true)
		"ammo":
			visual.color = Color(0.8, 0.4, 0.1, 0.8)
		"stat_upgrade":
			visual.color = Color(0.0, 1.0, 0.5, 0.8)
		"cult_artifact":
			visual.color = Color(0.7, 0.0, 1.0, 0.9)
		_:
			visual.color = Color(1.0, 1.0, 1.0, 0.5)
	pickup.add_child(visual)

	# Store loot data in metadata
	pickup.set_meta("loot_type", loot_item.get("type", ""))
	pickup.set_meta("loot_id", loot_item.get("id", ""))

	# Connect body_entered for pickup collection
	pickup.body_entered.connect(func(body: Node2D):
		if not is_instance_valid(pickup):
			return
		if not body.is_in_group("player"):
			return
		if pickup.get_meta("collected", false):
			return
		# Delegate to FloorManager if available
		var fm := _find_floor_manager(body.get_tree().root)
		if fm == null:
			var cs := body.get_tree().current_scene
			if cs and cs.has_method("_on_pickup_collected"):
				fm = cs
		if fm and fm.has_method("_on_pickup_collected"):
			fm._on_pickup_collected(body, pickup)
		else:
			pickup.set_meta("collected", true)
			pickup.queue_free()
	)

	return pickup

## Find FloorManager using group lookup
static func _find_floor_manager(node: Node) -> Node:
	if node == null:
		return null
	var tree := node.get_tree()
	if tree:
		return tree.get_first_node_in_group("floor_manager")
	return null
