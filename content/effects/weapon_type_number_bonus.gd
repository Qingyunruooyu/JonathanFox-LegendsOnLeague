extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED}


export (Type) var type = Type.MELEE


static func get_id() -> String:
	return "dr_weapon_type_number_bonus"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_type = type
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_type"):
		type = serialized.dr_type


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	RunData.get_tree().current_scene._wave_timer.connect("timeout", self, "_on_wave_timer_timeout")
	
	var number = _count_type_weapons(_player_index)
	
	if number > 0:
		TempStats.add_stat(key_hash, value * number, _player_index)


func _on_wave_timer_timeout() -> void:
	yield(RunData.get_tree().create_timer(0.1), "timeout")
	
	var number = _count_type_weapons(_player_index)
	
	if number > 0:
		TempStats.add_stat(key_hash, value * number, _player_index)


func _count_type_weapons(player_index: int) -> int:
	var number = 0
	
	for weapon in RunData.get_player_weapons_ref(player_index):
		if type == Type.MELEE and weapon is MeleeWeapon:
			number += 1
		elif type == Type.RANGED and weapon is RangedWeapon:
			number += 1
	
	return number


func get_args(player_index: int) -> Array:
	var type_text = "[color=#00ff00]"
	if type == Type.MELEE:
		type_text += tr("MELEE")
	else:
		type_text += tr("RANGED")
	type_text += "[/color]"
	
	var bonus_text = "[color=#00ff00]+%d %s[/color]" % [value, tr(key.to_upper())] if value >= 0 else "[color=red]%d %s[/color]" % [value, tr(key.to_upper())]
	
	var number = _count_type_weapons(player_index)
	var total_bonus = "[color=white][[/color][color=#00ff00]+%d[/color][color=white]][/color]" % (number * value)
	
	return [type_text, bonus_text, total_bonus]
