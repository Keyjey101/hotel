extends "res://scripts/tests/test_base.gd"

## Bug #48: Race condition between consume() and take_damage() on CorpseEntity.
## Both paths check guards independently -> double emit of corpse_consumed.

const CorpseEntityScript = preload("res://scripts/world/corpse_entity.gd")


func test_corpse_entity_script_loads():
	assert_ne(CorpseEntityScript, null, "CorpseEntity script should load")


func test_consume_and_damage_no_double_emit():
	var corpse = CorpseEntityScript.new()
	Engine.get_main_loop().root.add_child(corpse)
	_auto_free_nodes.append(corpse)

	var emit_count := 0
	corpse.corpse_consumed.connect(func(_c):
		emit_count += 1
	)

	# Call both paths simultaneously (race condition scenario)
	corpse.consume()
	corpse.take_damage(100.0, Vector2.ZERO, 0.0)

	# After fix: should emit only once
	assert_eq(emit_count, 1, "corpse_consumed should emit exactly once despite race condition")


func test_consume_idempotent():
	var corpse = CorpseEntityScript.new()
	Engine.get_main_loop().root.add_child(corpse)
	_auto_free_nodes.append(corpse)

	var emit_count := 0
	corpse.corpse_consumed.connect(func(_c):
		emit_count += 1
	)

	corpse.consume()
	corpse.consume()  # Second call
	corpse.consume()  # Third call

	assert_eq(emit_count, 1, "consume() should be idempotent")


func test_damage_then_consume_no_double():
	var corpse = CorpseEntityScript.new()
	Engine.get_main_loop().root.add_child(corpse)
	_auto_free_nodes.append(corpse)

	var emit_count := 0
	corpse.corpse_consumed.connect(func(_c):
		emit_count += 1
	)

	# Kill via damage
	corpse.take_damage(100.0, Vector2.ZERO, 0.0)
	# Try to consume the destroyed corpse
	corpse.consume()

	assert_eq(emit_count, 1, "Should not double-emit even with damage then consume")


func after_each():
	teardown_autoqfree()
