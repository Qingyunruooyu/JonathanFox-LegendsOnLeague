extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED, BOTH}


export (float) var chance = 1.0
export (Array, Array) var stats_to_add = [["materials", 1]]
export (Type) var weapon_type = Type.BOTH
export (String) var tracking_key = ""

var _stat_hashes = []
var _tracking_key_hash: int = 0


static func get_id() -> String:
	return "dr_chance_weapon_kill"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_chance = chance
	serialized.dr_stats_to_add = stats_to_add
	serialized.dr_weapon_type = weapon_type
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_chance"):
		chance = serialized.dr_chance
	if serialized.has("dr_stats_to_add"):
		stats_to_add = serialized.dr_stats_to_add
	if serialized.has("dr_weapon_type"):
		weapon_type = serialized.dr_weapon_type


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	_stat_hashes.clear()
	for stat in stats_to_add:
		_stat_hashes.push_back([stat[0], Keys.generate_hash(stat[0]), stat[1]])
	
	_tracking_key_hash = Keys.generate_hash(tracking_key) if tracking_key != "" else 0
	
	for weapon_instance in player.current_weapons:
		if weapon_instance is MeleeWeapon:
			if weapon_type == Type.MELEE or weapon_type == Type.BOTH:
				connect_safely(weapon_instance._hitbox, "killed_something", self, "_on_player_killed_something", [player.player_index])
		elif weapon_instance is RangedWeapon:
			if weapon_type == Type.RANGED or weapon_type == Type.BOTH:
				connect_safely(weapon_instance._shooting_behavior, "projectile_shot", self, "_on_player_projectile_shot", [player.player_index])


func _on_player_projectile_shot(projectile, player_index: int) -> void:
	if is_instance_valid(projectile):
		var hitbox = projectile._hitbox
		
		if hitbox and is_instance_valid(hitbox):
			connect_safely(hitbox, "killed_something", self, "_on_player_killed_something", [player_index])


func _on_player_killed_something(_thing_killed, player_index: int) -> void:
	if chance >= 1 or randf() < chance:
		for stat in _stat_hashes:
			if stat[0] == "materials":
				RunData.add_gold(stat[2], player_index)
				if _tracking_key_hash != 0:
					RunData.add_tracked_value(player_index, _tracking_key_hash, stat[2], 1)
			else:
				RunData.add_stat(stat[1], stat[2], player_index)


func get_args(_player_index: int) -> Array:
	var type_text = ""
	if weapon_type == Type.RANGED:
		type_text = tr("RANGED") + tr("WEAPONS")
	elif weapon_type == Type.MELEE:
		type_text = tr("MELEE") + tr("WEAPONS")
	else:
		type_text = tr("WEAPONS")
	
	var stats_text = ""
	for stat in stats_to_add:
		stats_text += "%d %s [color=white]&[/color] " % [stat[1], tr(stat[0].to_upper())]
	stats_text = stats_text.trim_suffix(" [color=white]&[/color] ")
	
	return [type_text, "%.1f" % (chance * 100), stats_text]
