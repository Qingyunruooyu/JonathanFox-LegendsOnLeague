extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


const MONITOR_PATH = "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/destroy_enemy_projectiles_monitor.gd"


static func get_id() -> String:
	return "dr_destroy_enemy_projectiles"


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	var monitor = load(MONITOR_PATH).new()
	set_monitor(player.player_index, monitor)
	player.call_deferred("add_child", monitor)


func connect_weapon(weapon) -> void:
	var monitor = _monitors.get(weapon.player_index)
	if monitor != null and is_instance_valid(monitor):
		monitor.connect_weapon(weapon)
