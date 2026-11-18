extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (String) var set_id = "set_blade"
export (String) var set_name = "WEAPON_CLASS_BLADE"

var _number = 0


static func get_id() -> String:
	return "dr_weapon_set_number_bonus"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_set_id = set_id
	serialized.dr_set_name = set_name
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_set_id"):
		set_id = serialized.dr_set_id
	if serialized.has("dr_set_name"):
		set_name = serialized.dr_set_name


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	RunData.get_tree().current_scene._wave_timer.connect("timeout", self, "_on_wave_timer_timeout")
	
	_number = _count_set_weapons(_player_index)
	
	if _number > 0:
		TempStats.add_stat(key_hash, value * _number, _player_index)


func _on_wave_timer_timeout() -> void:
	yield(RunData.get_tree().create_timer(0.1), "timeout")
	
	var number = _count_set_weapons(_player_index)
	
	if number > 0:
		TempStats.add_stat(key_hash, value * number, _player_index)


func _count_set_weapons(player_index: int) -> int:
	var number = 0
	
	for weapon in RunData.get_player_weapons_ref(player_index):
		for weapon_set in weapon.weapon_sets:
			if weapon_set.my_id == set_id:
				number += 1
	
	return number


func get_args(player_index: int) -> Array:
	var bonus_text = "[color=#00ff00]+%d %s[/color]" % [value, tr(key.to_upper())] if value >= 0 else "[color=red]%d %s[/color]" % [value, tr(key.to_upper())]
	
	_number = _count_set_weapons(player_index)
	var total_bonus = "[color=white][[/color][color=#00ff00]+%d[/color][color=white]][/color]" % (_number * value)
	
	return [tr(set_name), bonus_text, total_bonus]
