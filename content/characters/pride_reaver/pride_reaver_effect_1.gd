extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (Array, Array) var stats_add = [["stat_melee_damage", 4]]
export (Array, Array) var mutant_stats_add = [["stat_melee_damage", 2]]
export (int) var elite_xp = 100
export (int) var meca_xp = 500
export (int) var meca_parts = 1


static func get_id() -> String:
	return "dr_pride_reaver_handbook"


func apply(player_index: int) -> void:
	RunData.get_player_effects(player_index)[Utils.dr_pride_reaver_handbook_hash].push_back(self)


func unapply(player_index: int) -> void:
	RunData.get_player_effects(player_index)[Utils.dr_pride_reaver_handbook_hash].erase(self)


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

			for handbook in RunData.get_player_effect(Utils.dr_pride_reaver_handbook_hash, pid):
				_dr_add_stats(handbook.stats_add, pid)

		if enemy._is_mutant:
			var killed_mutant = RunData.get_player_effect(Utils.dr_killed_mutant_enemies_hash, pid)
			if not killed_mutant.has(enemy.enemy_id_hash):
				killed_mutant[enemy.enemy_id_hash] = 1

				for handbook in RunData.get_player_effect(Utils.dr_pride_reaver_handbook_hash, pid):
					_dr_add_stats(handbook.mutant_stats_add, pid)

		if enemy is Boss:
			RunData.add_xp(elite_xp, pid)

			if enemy._is_meca:
				RunData.add_xp(meca_xp, pid)
				RunData.add_meca_parts(meca_parts, pid)


func _dr_add_stats(stats: Array, pid: int) -> void:
	for stat in stats:
		RunData.add_stat(Keys.generate_hash(stat[0]), stat[1], pid)
		RunData.add_tracked_value(pid, Utils.character_dr_pride_reaver_hash, stat[1])


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.dr_stats_add = stats_add
	serialized.dr_mutant_stats_add = mutant_stats_add
	serialized.dr_elite_xp = elite_xp
	serialized.dr_meca_xp = meca_xp
	serialized.dr_meca_parts = meca_parts

	return serialized


func deserialize_and_merge(effect: Dictionary) -> void:
	.deserialize_and_merge(effect)

	stats_add = effect.get("dr_stats_add", stats_add)
	mutant_stats_add = effect.get("dr_mutant_stats_add", mutant_stats_add)
	elite_xp = effect.get("dr_elite_xp", elite_xp)
	meca_xp = effect.get("dr_meca_xp", meca_xp)
	meca_parts = effect.get("dr_meca_parts", meca_parts)


func get_args(_player_index: int) -> Array:
	return [
		_get_stats_text(stats_add),
		_get_stats_text(mutant_stats_add),
		get_colored_text_by_value(elite_xp, 0, "%d")[0],
		get_colored_text_by_value(meca_xp, 0, "%d")[0],
		get_colored_text_by_value(meca_parts, 0, "%d")[0]
	]


func _get_stats_text(stats: Array) -> String:
	var stat_text = ""
	for stat in stats:
		var colored_text = get_colored_text_by_value(stat[1], 0, "+%d" if stat[1] >= 0 else "%d")
		var name_text = get_colored_text_by_sign(tr(stat[0].to_upper()), colored_text[1])
		stat_text += "%s %s & " % [colored_text[0], name_text]

	return stat_text.trim_suffix(" & ")
