extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (PackedScene) var detact_scene:PackedScene
export (Resource) var lighting_projectiles_stats
export (float) var chance: = 0.3
export (int) var max_targets: = 3

var _current_lighting_projectiles_stats:RangedWeaponStats = null
var _actual_chance: = 0.3
var DesertRoseMainEventListener = null


func _on_desert_rose_wave_start(player)->void :
	._on_desert_rose_wave_start(player)
	
	if not DesertRoseMainEventListener:
		DesertRoseMainEventListener = RunData.get_node_or_null("/root/ModLoader/QianMo-LegendsOnLeague/DesertRoseMainEventListener")
	
	_actual_chance = max(0, Utils.get_stat("stat_elemental_damage") * 0.0035 + chance)
	_current_lighting_projectiles_stats = WeaponService.init_ranged_stats(lighting_projectiles_stats)
	_current_lighting_projectiles_stats.bounce = 0
	
	for weapon_instance in player.current_weapons:
		if weapon_instance is MeleeWeapon:
			connect_safely(weapon_instance._hitbox, "hit_something", self, "_on_player_hit_something")
		elif weapon_instance is RangedWeapon:
			connect_safely(weapon_instance._shooting_behavior, "projectile_shot", self, "_on_player_projectile_shot")
	
	connect_safely(DesertRoseMainEventListener, "stats_updated", self, "_on_stats_updated")


func _on_stats_updated()->void :
	_actual_chance = max(0, Utils.get_stat("stat_elemental_damage") * 0.0035 + chance)
	_current_lighting_projectiles_stats = WeaponService.init_ranged_stats(lighting_projectiles_stats)
	_current_lighting_projectiles_stats.bounce = 0


func _on_player_projectile_shot(projectile)->void :
	if is_instance_valid(projectile):
		var hitbox = projectile.get("_hitbox")
		
		if hitbox and is_instance_valid(hitbox):
			hitbox.connect("hit_something", self, "_on_player_hit_something")


func _on_player_hit_something(thing_hit, _damage_dealt)->void:
	if randf() < _actual_chance:
		var detact_area = detact_scene.instance()
		detact_area.init(max_targets)
		thing_hit.call_deferred("add_child", detact_area)
		detact_area.connect("spread_ready", self, "_on_spread_ready", [thing_hit])


func _on_spread_ready(targets, thing_hit)->void :
	if is_instance_valid(thing_hit):
		for target in targets:
			var angle = 0
			if is_instance_valid(target):
				angle = (target.global_position - thing_hit.global_position).angle()
			else:
				angle = rand_range(0, 2 * PI)
			
			var projectile = WeaponService.manage_special_spawn_projectile(thing_hit, _current_lighting_projectiles_stats, false, null, angle)
			projectile.connect("ready", self, "_on_projectile_ready", [projectile, thing_hit])


func _on_projectile_ready(projectile, thing_hit)->void :
	projectile._hitbox.ignored_objects.push_back(thing_hit)


func get_args()->Array :
	_actual_chance = max(0, Utils.get_stat("stat_elemental_damage") * 0.0035 + chance)
	var chance_text:String = "%s (%s)" % [get_colored_text_by_value(_actual_chance * 100.0, chance * 100.0, "%.1f%%")[0], Utils.get_scaling_stat_text("stat_elemental_damage", 0.35)]
	
	_current_lighting_projectiles_stats = WeaponService.init_ranged_stats(lighting_projectiles_stats)
	var damage_text:String = _current_lighting_projectiles_stats.get_damage_text(lighting_projectiles_stats)
	
	return [chance_text, damage_text, str(max_targets)]
