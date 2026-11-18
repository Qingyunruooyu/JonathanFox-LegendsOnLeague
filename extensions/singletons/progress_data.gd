extends "res://singletons/progress_data.gd"


var PRIDE_REAVER_EFFECT = null


func deserialize_run_state(state:Dictionary)->Dictionary :
	if not PRIDE_REAVER_EFFECT:
		PRIDE_REAVER_EFFECT = load("res://mods-unpacked/QianMo-LegendsOnLeague/content/characters/pride_reaver/pride_reaver_effect_1.tres")
	var deserialized_run_state = .deserialize_run_state(state)

	if deserialized_run_state.has("effects") and deserialized_run_state.effects.has("dr_character_pride_reaver_killed"):
		PRIDE_REAVER_EFFECT.killed_enemies = deserialized_run_state.effects["dr_character_pride_reaver_killed"]
		RunData.effects["dr_character_pride_reaver_killed"] = deserialized_run_state.effects["dr_character_pride_reaver_killed"]

	return deserialized_run_state
