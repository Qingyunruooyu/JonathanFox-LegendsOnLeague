extends "res://dlcs/dlc_2/dlc_2_data.gd"


const DR_MUTATION_COPY_BLACKLIST_IDS = [
	"dr_elites_killer_effect",
]


const DR_MUTATION_MIN_SCALE_IDS = [
	"dr_chance_weapon_burning",
	"dr_chance_weapon_kill",
	"dr_ocean_scourge_explosion",
]


func can_effect_be_copied_by_mutation(effect, player_index: int = -1) -> bool:
	if DR_MUTATION_COPY_BLACKLIST_IDS.has(effect.get_id()):
		return false

	if DR_MUTATION_MIN_SCALE_IDS.has(effect.get_id()) and get_mutation_scale(player_index) < MUTATION_ENTITY_MIN_SCALE:
		return false

	return .can_effect_be_copied_by_mutation(effect, player_index)


func _scale_copied_effect(effect, player_index: int) -> void:
	._scale_copied_effect(effect, player_index)

	var scale: float = get_mutation_scale(player_index)

	match effect.get_id():
		"dr_chance_weapon_burning":
			effect.burning_damage = int(ceil(effect.burning_damage * scale))
			effect._base_burning_data = null
			effect._burning_data_by_pid = {}
		"dr_chance_weapon_kill":
			effect.chance = max(0.01, ceil(stepify(effect.chance * scale * 100.0, 0.001)) / 100.0)
		"dr_ocean_scourge_explosion":
			effect.base_damage = int(ceil(effect.base_damage * scale))
			effect._damage_stats = null
			effect._current_exploding_effect = null
		"dr_pride_reaver_handbook":
			effect.stats_add = _dr_scale_stats(effect.stats_add, scale)
			effect.boss_stats_add = _dr_scale_stats(effect.boss_stats_add, scale)
			effect.boss_xp = int(ceil(effect.boss_xp * scale))


func _dr_scale_stats(stats: Array, scale: float) -> Array:
	var scaled = []

	for stat in stats:
		scaled.push_back([stat[0], int(sign(stat[1])) * int(ceil(abs(stat[1]) * scale))])

	return scaled
