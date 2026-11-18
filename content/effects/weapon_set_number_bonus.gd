extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (String) var set_id: = "set_blade"
export (String) var set_name: = "WEAPON_CLASS_BLADE"

var _number: = 0
var _wave_timer:WaveTimer = null


func _on_desert_rose_wave_start(player)->void :
	RunData.get_tree().current_scene._wave_timer.connect("timeout", self, "_on_wave_timer_timeout")
	
	var weapons = RunData.weapons
	_number = 0
	
	for weapon in RunData.weapons:
		for set in weapon.sets:
			if set.my_id == set_id:
				_number += 1
	
	if _number > 0:
		TempStats.add_stat(key, value * _number)


func _on_wave_timer_timeout()->void :
	yield(RunData.get_tree().create_timer(0.1), "timeout")
	
	var weapons = RunData.weapons
	var number = 0
	
	for weapon in RunData.weapons:
		for set in weapon.sets:
			if set.my_id == set_id:
				number += 1
	
	if number > 0:
		TempStats.add_stat(key, value * number)


func get_args()->Array :
	var bonus_text: = "[color=#00ff00]+%d %s[/color]" % [value, tr(key.to_upper())] if value >= 0 else "[color=red]%d %s[/color]" % [value, tr(key.to_upper())]
	
	_number = 0
	for weapon in RunData.weapons:
		for set in weapon.sets:
			if set.my_id == set_id:
				_number += 1
	var total_bonus: = "[color=white][[/color][color=#00ff00]+%d[/color][color=white]][/color]" % (_number * value)
	
	return [tr(set_name), bonus_text, total_bonus]
