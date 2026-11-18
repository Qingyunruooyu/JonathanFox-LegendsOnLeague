extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (Array, Array) var stats_add: = [["stat_melee_damage", 5]]

var killed_enemies: = []


static func get_id()->String:
	return "desert_rose_effect_handbook"


func _on_desert_rose_wave_start(_player)->void:
	_main = RunData.get_tree().current_scene
	var entity_spawner = _main.get("_entity_spawner")
	
	if RunData.current_wave == 1:
		killed_enemies.clear()
		RunData.effects["dr_character_pride_reaver_killed"].clear()
	
	connect_safely(entity_spawner, "enemy_spawned", self, "_on_enemy_spawned")


func unapply()->void :
	.unapply()
	
	for e in killed_enemies:
		if e in RunData.effects["dr_character_pride_reaver_killed"]:
			RunData.effects["dr_character_pride_reaver_killed"].erase(e)
	
	killed_enemies.clear()


func _on_enemy_spawned(enemy)->void :
	enemy.connect("died", self, "_on_enemy_died")


func _on_enemy_died(enemy)->void :
	if _main._cleaning_up:
		return
	var unit_resource_path:String = enemy.filename
	var enemy_name = unit_resource_path.get_slice("/", unit_resource_path.count("/"))
	if not enemy_name in killed_enemies:
		killed_enemies.push_back(enemy_name)
		for stat in stats_add:
			RunData.add_stat(stat[0], stat[1])
		
		for e in killed_enemies:
			if not e in RunData.effects["dr_character_pride_reaver_killed"]:
				RunData.effects["dr_character_pride_reaver_killed"].push_back(e)
	
	if enemy is Boss:
		RunData.add_xp(RunData.get_xp_needed(RunData.current_level))


func serialize()->Dictionary :
	var serialized = .serialize()
	
	serialized.killed_enemies = to_json(killed_enemies)
	
	return serialized


func deserialize_and_merge(serialized:Dictionary)->void :
	.deserialize_and_merge(serialized)
	
	killed_enemies = parse_json(serialized.killed_enemies)


func get_args()->Array :
	var scaling_text:String = "[color=#00ff00]"
	for stat in stats_add:
		scaling_text += "+%d %s & " % [stat[1], tr(stat[0].to_upper())]
	scaling_text = scaling_text.trim_suffix(" & ")
	scaling_text += "[/color]"
	
	return [scaling_text]
