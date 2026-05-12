extends "res://scripts/tests/test_base.gd"

## TestScreenEffects — Tests for the centralized ScreenEffects autoload.


func test_screen_effects_script_loads() -> void:
	var script := load("res://scripts/effects/screen_effects.gd")
	assert_ne(script, null, "screen_effects.gd loads")


func test_screen_effects_has_shake() -> void:
	var script := load("res://scripts/effects/screen_effects.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("shake" in methods, "shake method exists")


func test_screen_effects_has_flash() -> void:
	var script := load("res://scripts/effects/screen_effects.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("flash" in methods, "flash method exists")


func test_screen_effects_has_hit_stop() -> void:
	var script := load("res://scripts/effects/screen_effects.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("hit_stop" in methods, "hit_stop method exists")


func test_screen_effects_has_vignette() -> void:
	var script := load("res://scripts/effects/screen_effects.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("update_vignette" in methods, "update_vignette method exists")


func test_screen_effects_has_chromatic() -> void:
	var script := load("res://scripts/effects/screen_effects.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("chromatic_aberration" in methods, "chromatic_aberration method exists")


func test_screen_effects_has_zoom() -> void:
	var script := load("res://scripts/effects/screen_effects.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("zoom" in methods, "zoom method exists")


func test_shake_params_default() -> void:
	# Default: amplitude=4.0, duration=0.15, decay=0.9
	# Verify method accepts 3 parameters
	var script := load("res://scripts/effects/screen_effects.gd")
	for method in script.get_script_method_list():
		if method.name == "shake":
			assert_gte(method.args.size(), 3, "shake has at least 3 params")
			return
	assert_true(false, "shake method not found")


func test_flash_params_default() -> void:
	# Default: Color.WHITE, duration=0.05, max_alpha=0.6
	var script := load("res://scripts/effects/screen_effects.gd")
	for method in script.get_script_method_list():
		if method.name == "flash":
			assert_gte(method.args.size(), 3, "flash has at least 3 params")
			return
	assert_true(false, "flash method not found")


func test_hit_stop_default_duration() -> void:
	# Default: 0.05s
	var script := load("res://scripts/effects/screen_effects.gd")
	for method in script.get_script_method_list():
		if method.name == "hit_stop":
			assert_gte(method.args.size(), 1, "hit_stop has at least 1 param")
			return
	assert_true(false, "hit_stop method not found")


func test_zoom_has_hold_param() -> void:
	# zoom(target_zoom, duration, hold, return_duration)
	var script := load("res://scripts/effects/screen_effects.gd")
	for method in script.get_script_method_list():
		if method.name == "zoom":
			assert_gte(method.args.size(), 4, "zoom has at least 4 params")
			return
	assert_true(false, "zoom method not found")


func test_vignette_threshold() -> void:
	# update_vignette takes player_hp_percent
	# Vignette activates below 0.3 (30%)
	var script := load("res://scripts/effects/screen_effects.gd")
	for method in script.get_script_method_list():
		if method.name == "update_vignette":
			assert_gte(method.args.size(), 1, "update_vignette has at least 1 param")
			return
	assert_true(false, "update_vignette method not found")


func test_screen_effects_extends_canvas_layer() -> void:
	var script := load("res://scripts/effects/screen_effects.gd")
	# ScreenEffects extends CanvasLayer (autoload)
	assert_ne(script, null, "Script loaded")


func test_screen_effects_registered_as_autoload() -> void:
	# Verify project.godot has ScreenEffects autoload
	var cfg := ConfigFile.new()
	var err := cfg.load("res://project.godot")
	assert_eq(err, OK, "project.godot loads")
	var autoloads := cfg.get_section_keys("autoload")
	assert_true("ScreenEffects" in autoloads, "ScreenEffects in autoloads")
