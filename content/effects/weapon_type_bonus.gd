extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED}


export (Type) var type = Type.MELEE
export (String) var bonus_key = "max_range"
export (String) var displayed_key = "stat_range"
export (int) var bonus_value = 75


static func get_id() -> String:
	return "dr_weapon_type_bonus"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_type = type
	serialized.dr_bonus_key = bonus_key
	serialized.dr_displayed_key = displayed_key
	serialized.dr_bonus_value = bonus_value
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_type"):
		type = serialized.dr_type
	if serialized.has("dr_bonus_key"):
		bonus_key = serialized.dr_bonus_key
	if serialized.has("dr_displayed_key"):
		displayed_key = serialized.dr_displayed_key
	if serialized.has("dr_bonus_value"):
		bonus_value = serialized.dr_bonus_value


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	var weapons = player.current_weapons
	for weapon in weapons:
		if type == Type.MELEE and weapon is MeleeWeapon:
			_apply_weapon_bonus(weapon)
		elif type == Type.RANGED and weapon is RangedWeapon:
			_apply_weapon_bonus(weapon)


func _apply_weapon_bonus(weapon) -> void:
	if not check_already_applied(weapon.weapon_id_hash):
		RunData.get_player_effects(_player_index)[Utils.dr_weapon_bonus_hash].push_back([weapon.weapon_id_hash, bonus_key, bonus_value])
	
	weapon.init_stats(false)


func check_already_applied(id_hash: int) -> bool:
	for bonus in RunData.get_player_effect(Utils.dr_weapon_bonus_hash, _player_index):
		if bonus[0] == id_hash:
			return true
	return false


func get_args(_player_index: int) -> Array:
	var type_text = ""
	if type == Type.MELEE:
		type_text = tr("MELEE")
	else:
		type_text = tr("RANGED")
	
	var bonus_text = "[color=#00ff00]+%d %s[/color]" % [bonus_value, tr(displayed_key.to_upper())] if bonus_value >= 0 else "[color=red]-%d %s[/color]" % [abs(bonus_value), tr(displayed_key.to_upper())]
	
	return [type_text, bonus_text]
