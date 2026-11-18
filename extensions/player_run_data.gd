extends "res://singletons/player_run_data.gd"


static func init_effects() -> Dictionary:
	var vanilla_effects = .init_effects()
	var mod_effects = {
		Utils.dr_character_elites_killer_effect_hash: 0,
		Utils.dr_character_pride_reaver_killed_hash: [],
		Utils.dr_weapon_bonus_hash: [],
	}
	
	vanilla_effects.merge(mod_effects)
	return vanilla_effects
