extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (Array, Array) var stats_add = [["stat_melee_damage", 5]]
export (Array, Array) var boss_stats_add = [["stat_evolution", -20]]
export (int) var boss_xp = 100


static func get_id() -> String:
	return "dr_pride_reaver_handbook"


func apply(player_index: int) -> void:
	pass


func unapply(player_index: int) -> void:
	pass


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	connect_safely(_main._entity_spawner, "enemy_spawned", self, "_on_enemy_spawned")


func _on_enemy_spawned(enemy) -> void:
	connect_safely(enemy, "died", self, "_on_enemy_died")


func _on_enemy_died(enemy, _args) -> void:
	if not is_instance_valid(_main) or _main._cleaning_up:
		return

	for pid in _owner_pids:
		var killed = RunData.get_player_effect(Utils.dr_killed_enemies_hash, pid)
		if not killed.has(enemy.enemy_id_hash):
			killed[enemy.enemy_id_hash] = 1
			
			for item in RunData.get_player_items(pid):
				for effect in item.effects:
					if effect.get_id() == "dr_pride_reaver_handbook":
						_dr_add_stats(effect.stats_add, pid)
	
	if enemy is Boss:
		for pid in _owner_pids:
			_dr_add_stats(boss_stats_add, pid)
			RunData.add_xp(boss_xp, pid)

	if enemy is Boss:
		for pid in _owner_pids:
			_dr_add_stats(boss_stats_add, pid)
			RunData.add_xp(boss_xp, pid)


func _dr_add_stats(stats: Array, pid: int) -> void:
	for stat in stats:
		RunData.add_stat(Keys.generate_hash(stat[0]), stat[1], pid)
		var tracked_value = stat[1]
		if stat[0] == "stat_evolution":
			tracked_value = abs(tracked_value)
		RunData.add_tracked_value(pid, Utils.character_dr_pride_reaver_hash, tracked_value)


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_stats_add = stats_add
	serialized.dr_boss_stats_add = boss_stats_add
	serialized.dr_boss_xp = boss_xp
	
	return serialized


func deserialize_and_merge(effect: Dictionary) -> void:
	.deserialize_and_merge(effect)
	
	stats_add = effect.dr_stats_add
	boss_stats_add = effect.dr_boss_stats_add
	boss_xp = effect.dr_boss_xp


func get_args(_player_index: int) -> Array:
	return [_get_stats_text(stats_add), _get_stats_text(boss_stats_add), get_colored_text_by_value(boss_xp, 0, "%d")[0]]


func _get_stats_text(stats: Array) -> String:
	var stat_text = ""
	for stat in stats:
		var colored_text = get_colored_text_by_value(stat[1], 0, "+%d" if stat[1] >= 0 else "%d")
		var value_text = colored_text[0]
		var name_text = get_colored_text_by_sign(tr(stat[0].to_upper()), colored_text[1])
		if stat[0] == "stat_evolution" and stat[1] != 0:
			var evolution_color = Utils.get_evolution_color(stat[1]).to_html()
			value_text = "[color=#%s]%d[/color]" % [evolution_color, stat[1]]
			name_text = "[color=#%s]%s[/color]" % [evolution_color, tr(stat[0].to_upper())]
		stat_text += "%s %s & " % [value_text, name_text]

	return stat_text.trim_suffix(" & ")
