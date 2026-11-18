extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (PackedScene) var detact_scene: PackedScene
export (Resource) var lighting_projectiles_stats
export (float) var chance = 0.3
export (int) var max_targets = 3

var _current_lighting_projectiles_stats = null
var _actual_chance = 0.3


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
	
	_refresh_stats()
	
	for weapon_instance in player.current_weapons:
		if weapon_instance is MeleeWeapon:
			connect_safely(weapon_instance._hitbox, "hit_something", self, "_on_player_hit_something")
		elif weapon_instance is RangedWeapon:
			connect_safely(weapon_instance._shooting_behavior, "projectile_shot", self, "_on_player_projectile_shot")
	
	connect_safely(RunData, "stats_updated", self, "_on_stats_updated")


func _refresh_stats() -> void:
	_actual_chance = max(0, Utils.get_stat(Keys.stat_elemental_damage_hash, _player_index) * 0.0035 + chance)
	_current_lighting_projectiles_stats = WeaponService.init_ranged_stats(lighting_projectiles_stats, _player_index)
	_current_lighting_projectiles_stats.bounce = 0


func unapply(player_index: int) -> void:
	pass


func cleanup(player_index: int) -> void:
	disconnect_safely(RunData, "stats_updated", self, "_on_stats_updated")
	
	.cleanup(player_index)


func _on_stats_updated(player_index) -> void:
	if player_index == _player_index:
		_refresh_stats()


func _on_player_projectile_shot(projectile) -> void:
	if is_instance_valid(projectile):
		var hitbox = projectile._hitbox
		
		if hitbox and is_instance_valid(hitbox):
			connect_safely(hitbox, "hit_something", self, "_on_player_hit_something")


func _on_player_hit_something(thing_hit, _damage_dealt) -> void:
	if randf() < _actual_chance:
		var detact_area = detact_scene.instance()
		detact_area.init(max_targets)
		thing_hit.call_deferred("add_child", detact_area)
		detact_area.connect("spread_ready", self, "_on_spread_ready", [thing_hit])


func _on_spread_ready(targets, thing_hit) -> void:
	if is_instance_valid(thing_hit):
		for target in targets:
			var angle = 0
			if is_instance_valid(target):
				angle = (target.global_position - thing_hit.global_position).angle()
			else:
				angle = rand_range(0, 2 * PI)
			
			var projectile = WeaponService.manage_special_spawn_projectile(thing_hit, _current_lighting_projectiles_stats, angle, false, _main._entity_spawner, _player)
			projectile.connect("ready", self, "_on_projectile_ready", [projectile, thing_hit])


func _on_projectile_ready(projectile, thing_hit) -> void:
	projectile._hitbox.ignored_objects.push_back(thing_hit)


func get_args(player_index: int) -> Array:
	var actual_chance = max(0, Utils.get_stat(Keys.stat_elemental_damage_hash, player_index) * 0.0035 + chance)
	var chance_text = "%s (%s)" % [get_colored_text_by_value(actual_chance * 100.0, chance * 100.0, "%.1f%%")[0], _get_scaling_text(player_index)]
	
	var current_stats = WeaponService.init_ranged_stats(lighting_projectiles_stats, player_index)
	var damage_text = current_stats.get_damage_text(lighting_projectiles_stats, player_index, [])
	
	return [chance_text, damage_text, str(max_targets)]


func _get_scaling_text(player_index: int) -> String:
	var stat_value = Utils.get_stat(Keys.stat_elemental_damage_hash, player_index)
	return "%d%% %s" % [int(stat_value * 0.35), tr("STAT_ELEMENTAL_DAMAGE")]
