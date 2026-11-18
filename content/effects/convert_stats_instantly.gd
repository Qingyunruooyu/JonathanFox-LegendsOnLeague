extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (float) var pct_converted = 1.0
export (String) var to_stat = "stat_max_hp"
export (int) var to_value = 1

var _to_stat_hash: int = 0


static func get_id() -> String:
	return "dr_convert_stats_instantly"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_pct_converted = pct_converted
	serialized.dr_to_stat = to_stat
	serialized.dr_to_value = to_value
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_pct_converted"):
		pct_converted = serialized.dr_pct_converted
	if serialized.has("dr_to_stat"):
		to_stat = serialized.dr_to_stat
	if serialized.has("dr_to_value"):
		to_value = serialized.dr_to_value


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	_to_stat_hash = Keys.generate_hash(to_stat)
	
	connect_safely(RunData, "stat_added", self, "_on_stat_changed")
	connect_safely(RunData, "stat_removed", self, "_on_stat_changed")
	connect_safely(RunData, "stats_updated", self, "_on_stats_updated")
	connect_safely(RunData, "gold_changed", self, "_on_gold_changed")
	
	convert_stats([self])


func unapply(player_index: int) -> void:
	pass


func cleanup(player_index: int) -> void:
	disconnect_safely(RunData, "stat_added", self, "_on_stat_changed")
	disconnect_safely(RunData, "stat_removed", self, "_on_stat_changed")
	disconnect_safely(RunData, "stats_updated", self, "_on_stats_updated")
	disconnect_safely(RunData, "gold_changed", self, "_on_gold_changed")
	
	.cleanup(player_index)


func _on_stat_changed(_stat_name, _value, _db_mod, player_index) -> void:
	if player_index == _player_index and _stat_name == key_hash:
		convert_stats([self])


func _on_stats_updated(player_index) -> void:
	if player_index == _player_index:
		convert_stats([self])


func _on_gold_changed(_new_value, player_index) -> void:
	if player_index == _player_index and key == "materials":
		convert_stats([self])


func get_args(player_index: int) -> Array:
	return [str(pct_converted), tr(key.to_upper()), tr(to_stat.to_upper()), str(value), str(to_value)]


func convert_stats(stats: Array, permanent: bool = true) -> void:
	for stat_to_convert in stats:
		var pct = stat_to_convert.pct_converted / 100.0
		var stat_to_remove_hash = stat_to_convert.key_hash
		var stat_to_add_hash = stat_to_convert._to_stat_hash
		var current_player_index = stat_to_convert._player_index
		
		var stat_to_remove_value = RunData.get_player_gold(current_player_index) if stat_to_remove_hash == Keys.materials_hash else int(RunData.get_stat(stat_to_remove_hash, current_player_index))
		var nb_chunks_stat_removed = int(floor((stat_to_remove_value * pct) / stat_to_convert.value))
		
		if nb_chunks_stat_removed == 0:
			break
		
		var stat_removed_gain = RunData.get_stat_gain(stat_to_remove_hash, current_player_index)
		var stat_added_gain = RunData.get_stat_gain(stat_to_add_hash, current_player_index)
		
		var base_nb_stat_removed = nb_chunks_stat_removed * stat_to_convert.value
		var base_nb_stat_added = stat_to_convert.to_value * nb_chunks_stat_removed
		var actual_nb_stat_removed = base_nb_stat_removed
		var actual_nb_stat_added = base_nb_stat_added
		
		if stat_removed_gain > 0.0:
			actual_nb_stat_removed = int(round(base_nb_stat_removed / stat_removed_gain))
		if stat_added_gain > 0.0:
			actual_nb_stat_added = int(round(base_nb_stat_added / stat_added_gain))
		
		if stat_to_remove_hash == Keys.materials_hash:
			RunData.remove_gold(actual_nb_stat_removed, current_player_index)
		else:
			if permanent:
				if actual_nb_stat_removed > 0:
					RunData.remove_stat(stat_to_remove_hash, actual_nb_stat_removed, current_player_index)
				else:
					RunData.add_stat(stat_to_remove_hash, -actual_nb_stat_removed, current_player_index)
			else:
				TempStats.remove_stat(stat_to_remove_hash, actual_nb_stat_removed, current_player_index)
		
		if stat_to_add_hash == Keys.materials_hash:
			RunData.add_gold(actual_nb_stat_added, current_player_index)
		else:
			if permanent:
				if actual_nb_stat_added < 0:
					RunData.remove_stat(stat_to_add_hash, -actual_nb_stat_added, current_player_index)
				else:
					RunData.add_stat(stat_to_add_hash, actual_nb_stat_added, current_player_index)
			else:
				TempStats.add_stat(stat_to_add_hash, actual_nb_stat_added, current_player_index)
				RunData.emit_signal("stat_added", stat_to_add_hash, base_nb_stat_added, 0.0, current_player_index)
