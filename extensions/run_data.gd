extends "res://singletons/run_data.gd"


func resume_from_state(state: Dictionary) -> void:
	.resume_from_state(state)
	for i in players_data.size():
		update_item_related_effects(i)


func update_additional_weapon_bonuses(player_index: int) -> void:
	.update_additional_weapon_bonuses(player_index)
	
	var effects = get_player_effects(player_index)
	var player_data = players_data[player_index]
	
	for record in player_data.dr_weapon_number_records:
		effects[record[0]] -= record[1]
	player_data.dr_weapon_number_records = []
	
	for weapon in get_player_weapons(player_index):
		for entry in effects[Utils.dr_weapon_number_bonus_hash]:
			if _dr_weapon_matches(weapon, entry):
				effects[entry[2]] += entry[entry.size() - 1]
				player_data.dr_weapon_number_records.push_back([entry[2], entry[entry.size() - 1]])


func _dr_weapon_matches(weapon, entry) -> bool:
	if entry[0] == 0:
		return weapon.type == 0
	elif entry[0] == 1:
		return weapon.type == 1
	for weapon_set in weapon.sets:
		if weapon_set.my_id_hash == entry[1]:
			return true
	return false
