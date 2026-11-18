extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED}

export (Type) var type: = Type.MELEE


func _on_desert_rose_wave_start(player)->void :
	RunData.get_tree().current_scene._wave_timer.connect("timeout", self, "_on_wave_timer_timeout")
	
	var weapons = RunData.weapons
	var number: = 0
	
	for weapon in RunData.weapons:
		if weapon.type == type:
			number += 1
	
	if number > 0:
		TempStats.add_stat(key, value * number)


func _on_wave_timer_timeout()->void :
	yield(RunData.get_tree().create_timer(0.1), "timeout")
	
	var weapons = RunData.weapons
	var number = 0
	
	for weapon in RunData.weapons:
		if weapon.type == type:
			number += 1
	
	if number > 0:
		TempStats.add_stat(key, value * number)


func get_args()->Array :
	var type_text: = "[color=#00ff00]"
	if type == Type.MELEE:
		type_text += tr("MELEE")
	else:
		type_text += tr("RANGED")
	type_text += "[/color]"
	
	var bonus_text: = "[color=#00ff00]+%d %s[/color]" % [value, tr(key.to_upper())] if value >= 0 else "[color=red]%d %s[/color]" % [value, tr(key.to_upper())]
	
	var number: = 0
	
	for weapon in RunData.weapons:
		if weapon.type == type:
			number += 1
	var total_bonus: = "[color=white][[/color][color=#00ff00]+%d[/color][color=white]][/color]" % (number * value)
	
	return [type_text, bonus_text, total_bonus]
