extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (PackedScene) var detact_scene: PackedScene
export (Resource) var lighting_projectiles_stats
export (float) var chance = 0.3
export (int) var max_targets = 3

const MONITOR_PATH = "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/characters/lighting_mage/lighting_mage_monitor.gd"


static func get_id() -> String:
	return "dr_lighting_mage_effect"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_chance = chance
	serialized.dr_max_targets = max_targets
	if detact_scene != null:
		serialized.dr_detact_scene_path = detact_scene.resource_path
	if lighting_projectiles_stats != null:
		serialized.dr_stats_path = lighting_projectiles_stats.resource_path
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_chance"):
		chance = serialized.dr_chance
	if serialized.has("dr_max_targets"):
		max_targets = serialized.dr_max_targets
	if serialized.has("dr_detact_scene_path"):
		detact_scene = load(serialized.dr_detact_scene_path)
	if serialized.has("dr_stats_path"):
		lighting_projectiles_stats = load(serialized.dr_stats_path)


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	var monitor = load(MONITOR_PATH).new()
	monitor.init(chance, max_targets, detact_scene, lighting_projectiles_stats)
	set_monitor(player.player_index, monitor)
	player.call_deferred("add_child", monitor)


func get_args(player_index: int) -> Array:
	var actual_chance = max(0, Utils.get_stat(Keys.stat_elemental_damage_hash, player_index) * 0.0035 + chance)
	var chance_text = "%.1f" % (actual_chance * 100.0)
	
	var current_stats = WeaponService.init_ranged_stats(lighting_projectiles_stats, player_index)
	var damage_text = current_stats.get_damage_text(lighting_projectiles_stats, player_index, [])
	
	return [chance_text, _get_scaling_text(player_index), damage_text, get_colored_text_by_value(max_targets, 0)[0]]


func _add_custom_args() -> void:
	var chance_arg = CustomArg.new()
	chance_arg.arg_index = 0
	chance_arg.arg_sign = Sign.FROM_ARG
	custom_args.append(chance_arg)


func _remove_custom_args() -> void:
	custom_args.pop_back()


func _get_scaling_text(_player_index: int) -> String:
	return Utils.get_scaling_stat_icon_text(Keys.stat_elemental_damage_hash, 0.35)
