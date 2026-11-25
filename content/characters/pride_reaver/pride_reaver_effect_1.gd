extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (Array, Array) var stats_add = [["stat_melee_damage", 5]]
export (Array, Array) var boss_stats_add = [["stat_evolution", -20]]
export (int) var boss_xp = 100

var killed_enemies = []
var _stats_add_hashes = []
var _boss_stats_add_hashes = []


static func get_id() -> String:
	return "dr_pride_reaver_handbook"


func apply(player_index: int) -> void:
	pass


func unapply(player_index: int) -> void:
	pass


func cleanup(player_index: int) -> void:
	var killed_effect = RunData.get_player_effect(Utils.dr_character_pride_reaver_killed_hash, player_index)
	for e in killed_enemies:
		killed_effect.erase(e)
	
	.cleanup(player_index)


func _on_last_owner_removed() -> void:
	killed_enemies.clear()


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	var entity_spawner = _main._entity_spawner
	
	_stats_add_hashes.clear()
	for stat in stats_add:
		_stats_add_hashes.push_back([Keys.generate_hash(stat[0]), stat[1]])
	
	_boss_stats_add_hashes.clear()
	for stat in boss_stats_add:
		_boss_stats_add_hashes.push_back([Keys.generate_hash(stat[0]), stat[1]])
	
	if RunData.current_wave == 1:
		killed_enemies.clear()
		RunData.get_player_effect(Utils.dr_character_pride_reaver_killed_hash, _player_index).clear()
	
	connect_safely(entity_spawner, "enemy_spawned", self, "_on_enemy_spawned")


func _on_enemy_spawned(enemy) -> void:
	connect_safely(enemy, "died", self, "_on_enemy_died")


func _on_enemy_died(enemy, _args) -> void:
	if not is_instance_valid(_main) or _main._cleaning_up:
		return
	var unit_resource_path = enemy.filename
	var enemy_name = unit_resource_path.get_slice("/", unit_resource_path.count("/"))
	if not enemy_name in killed_enemies:
		killed_enemies.push_back(enemy_name)
		for pid in _owner_pids:
			_dr_add_stats(_stats_add_hashes, pid)
			
			var killed_effect = RunData.get_player_effect(Utils.dr_character_pride_reaver_killed_hash, pid)
			for e in killed_enemies:
				if not e in killed_effect:
					killed_effect.push_back(e)
	
	if enemy is Boss:
		for pid in _owner_pids:
			_dr_add_stats(_boss_stats_add_hashes, pid)
			RunData.add_xp(boss_xp, pid)


func _dr_add_stats(stats: Array, pid: int) -> void:
	for stat in stats:
		RunData.add_stat(stat[0], stat[1], pid)
		var tracked_value = stat[1]
		if stat[0] == Keys.stat_evolution_hash:
			tracked_value = abs(tracked_value)
		RunData.add_tracked_value(pid, Utils.character_dr_pride_reaver_hash, tracked_value)


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_stats_add = stats_add
	serialized.dr_boss_stats_add = boss_stats_add
	serialized.dr_boss_xp = boss_xp
	serialized.killed_enemies = to_json(killed_enemies)
	
	return serialized


func deserialize_and_merge(effect: Dictionary) -> void:
	.deserialize_and_merge(effect)
	
	if effect.has("dr_stats_add"):
		stats_add = effect.dr_stats_add
	if effect.has("dr_boss_stats_add"):
		boss_stats_add = effect.dr_boss_stats_add
	if effect.has("dr_boss_xp"):
		boss_xp = effect.dr_boss_xp
	if effect.has("killed_enemies"):
		killed_enemies = parse_json(effect.killed_enemies)


func get_args(_player_index: int) -> Array:
	return [_get_stats_text(stats_add), _get_stats_text(boss_stats_add), get_colored_text_by_value(boss_xp, 0, "%d")[0]]


func _get_stats_text(stats: Array) -> String:
	var stat_text = ""
	for stat in stats:
		var colored_text = get_colored_text_by_value(stat[1], 0, "+%d" if stat[1] >= 0 else "%d")
		stat_text += "%s %s & " % [colored_text[0], get_colored_text_by_sign(tr(stat[0].to_upper()), colored_text[1])]
	
	return stat_text.trim_suffix(" & ")
