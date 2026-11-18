extends "res://singletons/run_data.gd"


func resume_from_state(state: Dictionary) -> void:
	.resume_from_state(state)
	for data in players_data:
		for weapon in data.weapons:
			weapon.stats.set_meta("weapon_id_hash", weapon.weapon_id_hash)
