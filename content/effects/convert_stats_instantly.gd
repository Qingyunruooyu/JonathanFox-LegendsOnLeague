extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (float) var pct_converted = 1.0
export (String) var to_stat = "stat_max_hp"
export (int) var to_value = 1


func _on_desert_rose_wave_start(player)->void :
	if not RunData.is_connected("stat_added", self, "_on_stat_changed"):
		RunData.connect("stat_added", self, "_on_stat_changed")
	if not RunData.is_connected("stat_removed", self, "_on_stat_changed"):
		RunData.connect("stat_removed", self, "_on_stat_changed")
	if not TempStats.is_connected("temp_stat_updated", self, "_on_stat_changed"):
		TempStats.connect("temp_stat_updated", self, "_on_stat_changed")
	if not LinkedStats.is_connected("linked_stat_updated", self, "_on_stat_changed"):
		LinkedStats.connect("linked_stat_updated", self, "_on_stat_changed")
		
	convert_stats([self])


func unapply()->void :
	.unapply()
	
	if RunData.is_connected("stat_added", self, "_on_stat_changed"):
		RunData.disconnect("stat_added", self, "_on_stat_changed")
	if RunData.is_connected("stat_removed", self, "_on_stat_changed"):
		RunData.disconnect("stat_removed", self, "_on_stat_changed")
	if TempStats.is_connected("temp_stat_updated", self, "_on_stat_changed"):
		TempStats.disconnect("temp_stat_updated", self, "_on_stat_changed")
	if LinkedStats.is_connected("linked_stat_updated", self, "_on_stat_changed"):
		LinkedStats.disconnect("linked_stat_updated", self, "_on_stat_changed")


func _on_stat_changed(_stat_name:String, _value:int, _db_mod:float = 0.0, from:String=""):
	if _stat_name == key:
		convert_stats([self])


func get_args()->Array:
	return [str(pct_converted), tr(key.to_upper()), tr(to_stat.to_upper()), str(value), str(to_value)]


func convert_stats(stats:Array, permanent:bool = true)->void :
	for stat_to_convert in stats:
		var pct = stat_to_convert.pct_converted / 100.0
		var stat_to_remove = stat_to_convert.key
		var stat_to_add = stat_to_convert.to_stat
		
		var stat_to_remove_value = RunData.gold if stat_to_remove == "materials" else RunData.get_stat(stat_to_remove) as int
		var nb_chunks_stat_removed = floor((stat_to_remove_value * pct) / stat_to_convert.value)
		
		if nb_chunks_stat_removed == 0:
			break
		
		var stat_removed_gain = RunData.get_stat_gain(stat_to_remove)
		var stat_added_gain = RunData.get_stat_gain(stat_to_add)
		
		var base_nb_stat_removed = nb_chunks_stat_removed * stat_to_convert.value
		var base_nb_stat_added = stat_to_convert.to_value * nb_chunks_stat_removed
		var actual_nb_stat_removed = base_nb_stat_removed
		var actual_nb_stat_added = base_nb_stat_added
		
		if stat_removed_gain > 0.0:
			actual_nb_stat_removed = round(base_nb_stat_removed / stat_removed_gain) as int
		if stat_added_gain > 0.0:
			actual_nb_stat_added = round(base_nb_stat_added / stat_added_gain) as int
		
		if stat_to_remove == "materials":
			RunData.remove_gold(actual_nb_stat_removed)
		else :
			if permanent:
				if actual_nb_stat_removed > 0:
					RunData.remove_stat(stat_to_remove, actual_nb_stat_removed)
				else:
					RunData.add_stat(stat_to_remove, -actual_nb_stat_removed)
			else :
				TempStats.remove_stat(stat_to_remove, actual_nb_stat_removed)
		
		if stat_to_add == "materials":
			RunData.add_gold(actual_nb_stat_added)
		else :
			if permanent:
				if actual_nb_stat_added < 0:
					RunData.remove_stat(stat_to_add, -actual_nb_stat_added)
				else:
					RunData.add_stat(stat_to_add, actual_nb_stat_added)
			else :
				TempStats.add_stat(stat_to_add, actual_nb_stat_added)
				RunData.emit_signal("stat_added", stat_to_add, base_nb_stat_added, 0.0)
