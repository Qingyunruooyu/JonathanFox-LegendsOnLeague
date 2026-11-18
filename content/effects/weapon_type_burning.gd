extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED}


export (Type) var weapon_type: = Type.MELEE


func _on_desert_rose_wave_start(player)->void :
	var weapons = player.current_weapons
	for weapon in weapons:
		if weapon_type == Type.MELEE:
			if weapon is MeleeWeapon:
				pass
		else:
			if weapon is RangedWeapon:
				pass
