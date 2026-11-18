extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED}

export (String) var bonus_key: = "max_range"
export (String) var displayed_key: = "stat_range"
export (int) var bonus_value: = 75
export (Type) var type = Type.MELEE


func _on_desert_rose_wave_start(player)->void :
	var weapons = player.current_weapons
	for weapon in weapons:
		if type == Type.MELEE:
			if weapon is MeleeWeapon:
				var id = weapon.weapon_id
				
				if not check_already_applied(id):
					var b = [id, bonus_key, bonus_value, "dr"]
					RunData.effects["weapon_bonus"].push_back(b)
				
				weapon.init_stats(false)
		else:
			if weapon is RangedWeapon:
				var id = weapon.weapon_id
				
				if not check_already_applied(id):
					var b = [id, bonus_key, bonus_value, "dr"]
					RunData.effects["weapon_bonus"].push_back(b)
				
				weapon.init_stats(false)


func check_already_applied(id:String)->bool :
	for bonus in RunData.effects["weapon_bonus"]:
		if bonus.size() == 4 and bonus[3] == "dr" and bonus[0] == id:
			return true
	return false


func get_args()->Array:
	var type_text
	if type == Type.MELEE:
		type_text = tr("MELEE")
	else:
		type_text = tr("RANGED")
	
	var bonus_text = "[color=#00ff00]+%d %s[/color]" % [bonus_value, tr(displayed_key.to_upper())] if bonus_value >= 0 else "[color=red]-%d %s[/color]" % [abs(bonus_value), tr(displayed_key.to_upper())]

	return [type_text, bonus_text]
