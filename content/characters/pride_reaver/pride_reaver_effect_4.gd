extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (float) var duration = 0.5
export (Array, Array) var bonus_stats = [["stat_speed", 50]]

const MONITOR_PATH = "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/characters/pride_reaver/pride_reaver_protection_monitor.gd"


static func get_id() -> String:
	return "dr_pride_reaver_protection"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_duration = duration
	serialized.dr_bonus_stats = bonus_stats
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	duration = serialized.dr_duration
	bonus_stats = serialized.dr_bonus_stats


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	var monitor = load(MONITOR_PATH).new()
	monitor.init(duration, bonus_stats)
	set_monitor(player.player_index, monitor)
	player.call_deferred("add_child", monitor)


func get_args(_player_index: int) -> Array:
	var stat_text = ""
	for stat in bonus_stats:
		var colored_text = get_colored_text_by_value(stat[1], 0)
		stat_text += "%s %s & " % [colored_text[0], get_colored_text_by_sign(tr(stat[0].to_upper()), colored_text[1])]
	stat_text = stat_text.trim_suffix(" & ")
	
	return [stat_text, get_colored_text_by_value(duration, 0, "%.1f")[0]]
