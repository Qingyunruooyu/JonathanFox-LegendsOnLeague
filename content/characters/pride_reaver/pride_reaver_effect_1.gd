extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (Array, Array) var stats_add = [["stat_melee_damage", 5]]

var killed_enemies = []
var _stats_add_hashes = []


static func get_id() -> String:
	return "dr_pride_reaver_handbook"


func apply(player_index: int) -> void:
	pass


func unapply(player_index: int) -> void:
	pass


func cleanup(player_index: int) -> void:
	for e in killed_enemies:
		RunData.get_player_effect(Utils.dr_character_pride_reaver_killed_hash, player_index).erase(e)
	
	killed_enemies.clear()
	
	.cleanup(player_index)


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	_main = RunData.get_tree().current_scene
	var entity_spawner = _main._entity_spawner
	
	_stats_add_hashes.clear()
	for stat in stats_add:
		_stats_add_hashes.push_back([Keys.generate_hash(stat[0]), stat[1]])
	
	if RunData.current_wave == 1:
		killed_enemies.clear()
		RunData.get_player_effect(Utils.dr_character_pride_reaver_killed_hash, _player_index).clear()
	
	connect_safely(entity_spawner, "enemy_spawned", self, "_on_enemy_spawned")


func _on_enemy_spawned(enemy) -> void:
	enemy.connect("died", self, "_on_enemy_died")


func _on_enemy_died(enemy, _args) -> void:
	if _main._cleaning_up:
		return
	var unit_resource_path = enemy.filename
	var enemy_name = unit_resource_path.get_slice("/", unit_resource_path.count("/"))
	if not enemy_name in killed_enemies:
		killed_enemies.push_back(enemy_name)
		for stat in _stats_add_hashes:
			RunData.add_stat(stat[0], stat[1], _player_index)
		
		var killed_effect = RunData.get_player_effect(Utils.dr_character_pride_reaver_killed_hash, _player_index)
		for e in killed_enemies:
			if not e in killed_effect:
				killed_effect.push_back(e)
	
	if enemy is Boss:
		RunData.add_xp(int(RunData.get_xp_needed(RunData.players_data[_player_index].current_level)), _player_index)


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_stats_add = stats_add
	serialized.killed_enemies = to_json(killed_enemies)
	
	return serialized


func deserialize_and_merge(effect: Dictionary) -> void:
	.deserialize_and_merge(effect)
	
	if effect.has("dr_stats_add"):
		stats_add = effect.dr_stats_add
	if effect.has("killed_enemies"):
		killed_enemies = parse_json(effect.killed_enemies)


func get_args(_player_index: int) -> Array:
	var scaling_text = "[color=#00ff00]"
	for stat in stats_add:
		scaling_text += "+%d %s & " % [stat[1], tr(stat[0].to_upper())]
	scaling_text = scaling_text.trim_suffix(" & ")
	scaling_text += "[/color]"
	
	return [scaling_text]
