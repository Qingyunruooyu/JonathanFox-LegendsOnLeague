extends "res://singletons/weapon_service.gd"


func _ready():
	call_deferred("dr_add_weapon_id_hash")


func dr_add_weapon_id_hash():
	for weapon in ItemService.get_weapons():
		weapon.stats.set_meta("weapon_id_hash", weapon.weapon_id_hash)


func init_base_stats(from_stats: WeaponStats, player_index: int, args = WeaponServiceInitStatsArgs.new(), is_structure = false, is_special_spawn = false, is_pet = false) -> WeaponStats:
	var new_stats = .init_base_stats(from_stats, player_index, args, is_structure, is_special_spawn, is_pet)
	if not from_stats.has_meta("weapon_id_hash"):
		return new_stats
	for weapon_bonus in RunData.get_player_effect(Utils.dr_weapon_bonus_hash, player_index):
		if from_stats.get_meta("weapon_id_hash") == weapon_bonus[0]:
			new_stats.set(weapon_bonus[1], weapon_bonus[2] + new_stats.get(weapon_bonus[1]))
	
	return new_stats
