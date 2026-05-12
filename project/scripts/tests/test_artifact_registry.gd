extends Node

## TestArtifactRegistry — Verifies artifact registry loads and returns correct resources.
## Run via test_runner.gd.

var _test_runner: Object  # Injected by TestRunner


func before_all() -> void:
	# Ensure registries are loaded
	if ArtifactRegistry:
		await get_tree().process_frame


func test_registry_has_artifacts() -> void:
	assert(ArtifactRegistry != null, "ArtifactRegistry autoload should exist")
	if ArtifactRegistry:
		var all := ArtifactRegistry.get_all_artifacts()
		assert(all.size() >= 12, "Should have at least 12 artifacts, got %d" % all.size())


func test_get_demon_eye() -> void:
	if ArtifactRegistry:
		var art: CultArtifact = ArtifactRegistry.get_artifact("a1_demon_eye")
		assert(art != null, "Demon Eye artifact should exist")
		if art:
			assert(art.display_name == "Demon Eye", "Display name should be Demon Eye, got %s" % art.display_name)
			assert(art.stat_mods.has("ranged_damage_mult"), "Should have ranged_damage_mult stat mod")
			assert(art.rarity == 1, "Demon Eye should be common (rarity=1)")


func test_get_blood_pact() -> void:
	if ArtifactRegistry:
		var art: CultArtifact = ArtifactRegistry.get_artifact("a2_blood_pact")
		assert(art != null, "Blood Pact artifact should exist")
		if art:
			assert(art.stat_mods.has("max_hp_mult"), "Should have max_hp_mult")
			assert(art.stat_mods.has("enemy_regen_speed_mult"), "Should have enemy_regen_speed_mult")


func test_get_void_contract() -> void:
	if ArtifactRegistry:
		var art: CultArtifact = ArtifactRegistry.get_artifact("a12_void_contract")
		assert(art != null, "Void Contract artifact should exist")
		if art:
			assert(art.rarity == 3, "Void Contract should be cursed (rarity=3)")


func test_apply_artifact_changes_stats() -> void:
	var rs := RunState.new()
	var art := CultArtifact.new()
	art.id = "test_artifact"
	art.stat_mods = {"test_stat": 5.0}
	rs.apply_artifact(art)
	assert(rs.stat_upgrades.get("test_stat", 0.0) == 5.0, "Artifact stat should be applied")
	assert(rs.has_artifact("test_artifact"), "Artifact should be tracked")


func test_has_artifact_by_id() -> void:
	var rs := RunState.new()
	var art := CultArtifact.new()
	art.id = "my_test_art"
	art.stat_mods = {}
	rs.apply_artifact(art)
	assert(rs.has_artifact("my_test_art"), "Should find artifact by id")


func test_upgrade_registry_has_upgrades() -> void:
	assert(UpgradeRegistry != null, "UpgradeRegistry autoload should exist")
	if UpgradeRegistry:
		var all := UpgradeRegistry.get_all_upgrades()
		assert(all.size() >= 11, "Should have at least 11 upgrades, got %d" % all.size())


func test_get_vitality_shard() -> void:
	if UpgradeRegistry:
		var upg: StatUpgrade = UpgradeRegistry.get_upgrade("s1_vitality_shard")
		assert(upg != null, "Vitality Shard should exist")
		if upg:
			assert(upg.stat_key == "max_hp", "stat_key should be max_hp")
			assert(upg.delta == 25.0, "delta should be 25.0")
