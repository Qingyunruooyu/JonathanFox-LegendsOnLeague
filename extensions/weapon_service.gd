extends "res://singletons/weapon_service.gd"


func init_ranged_stats(from_stats: RangedWeaponStats, player_index: int, is_special_spawn: bool = false, args: WeaponServiceInitStatsArgs = _init_stats_args_service) -> RangedWeaponStats:
	var new_stats = .init_ranged_stats(from_stats, player_index, is_special_spawn, args)
	
	var max_range_cap = RunData.get_player_effect(Utils.dr_max_range_cap_hash, player_index)
	new_stats.max_range = int(clamp(new_stats.max_range, new_stats.min_range + 25, max_range_cap))
	
	return new_stats
