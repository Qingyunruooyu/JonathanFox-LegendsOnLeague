extends "res://singletons/run_data.gd"


func init_effects()->Dictionary:
	var vanilla_effects = .init_effects()
	var mod_effects = {
		"dr_character_elites_killer_effect": 0,
		"dr_character_pride_reaver_killed": [],
	}
	
	vanilla_effects.merge(mod_effects)
	return vanilla_effects
