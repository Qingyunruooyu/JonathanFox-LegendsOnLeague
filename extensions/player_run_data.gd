extends "res://singletons/player_run_data.gd"


var dr_weapon_number_records = []


static func init_effects() -> Dictionary:
	var vanilla_effects = .init_effects()
	var mod_effects = {
		Utils.dr_character_elites_killer_effect_hash: 0,
		Utils.dr_character_pride_reaver_killed_hash: [],
		Utils.dr_weapon_number_bonus_hash: [],
		Utils.dr_max_range_cap_hash: Utils.LARGE_NUMBER,
	}
	
	vanilla_effects.merge(mod_effects)
	return vanilla_effects


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_weapon_number_records = dr_weapon_number_records.duplicate()
	
	return serialized


func deserialize(data: Dictionary) -> PlayerRunData:
	.deserialize(data)
	
	dr_weapon_number_records = data.dr_weapon_number_records.duplicate() if "dr_weapon_number_records" in data else []
	
	return self
