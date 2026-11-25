extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Filter {MELEE, RANGED, SET}


export (Filter) var filter = Filter.MELEE
export (String) var set_id = ""
export (String) var set_name = "WEAPON_CLASS_BLADE"


static func get_id() -> String:
	return "dr_weapon_number_bonus"


func apply(player_index: int) -> void:
	RunData.get_player_effects(player_index)[Utils.dr_weapon_number_bonus_hash].push_back([filter, Keys.generate_hash(set_id), key_hash, value])


func unapply(player_index: int) -> void:
	RunData.get_player_effects(player_index)[Utils.dr_weapon_number_bonus_hash].erase([filter, Keys.generate_hash(set_id), key_hash, value])


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_filter = filter
	serialized.dr_set_id = set_id
	serialized.dr_set_name = set_name
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	filter = serialized.dr_filter
	set_id = serialized.dr_set_id
	set_name = serialized.dr_set_name


func count_matching_weapons(player_index: int) -> int:
	var number = 0
	
	for weapon in RunData.get_player_weapons_ref(player_index):
		if _weapon_matches(weapon):
			number += 1
	
	return number


func _weapon_matches(weapon) -> bool:
	if filter == Filter.MELEE:
		return weapon.type == 0
	elif filter == Filter.RANGED:
		return weapon.type == 1
	for weapon_set in weapon.sets:
		if weapon_set.my_id_hash == Keys.generate_hash(set_id):
			return true
	return false


func get_args(player_index: int) -> Array:
	var filter_text = ""
	if filter == Filter.SET:
		filter_text = tr(set_name)
	elif filter == Filter.MELEE:
		filter_text = tr("MELEE")
	else:
		filter_text = tr("RANGED")
	
	var number = count_matching_weapons(player_index)
	
	return [filter_text, str(value), tr(key.to_upper()), str(number * value)]


func _add_custom_args() -> void:
	var bonus_arg = CustomArg.new()
	bonus_arg.arg_index = 1
	bonus_arg.arg_sign = Sign.FROM_ARG
	custom_args.append(bonus_arg)
	var total_arg = CustomArg.new()
	total_arg.arg_index = 3
	total_arg.arg_sign = Sign.FROM_ARG
	custom_args.append(total_arg)


func _remove_custom_args() -> void:
	custom_args.pop_back()
	custom_args.pop_back()
