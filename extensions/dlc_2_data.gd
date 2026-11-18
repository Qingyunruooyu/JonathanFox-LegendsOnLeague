extends "res://dlcs/dlc_2/dlc_2_data.gd"


const DR_MUTATION_COPY_BLACKLIST_IDS = [
	"dr_convert_stats_instantly",
	"dr_elites_killer_effect",
	"dr_weapon_set_number_bonus",
	"dr_weapon_type_number_bonus",
]


func can_effect_be_copied_by_mutation(effect, player_index: int = -1) -> bool:
	if DR_MUTATION_COPY_BLACKLIST_IDS.has(effect.get_id()):
		return false
	return .can_effect_be_copied_by_mutation(effect, player_index)
