extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (float) var duration = 0.5
export (Array, Array) var bonus_stats = [["stat_speed", 50]]

var _next_protecting_count = 0
var _invincibility_timer = null
var _timer = null
var _bonus_stat_hashes = []


static func get_id() -> String:
	return "dr_pride_reaver_protection"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_duration = duration
	serialized.dr_bonus_stats = bonus_stats
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_duration"):
		duration = serialized.dr_duration
	if serialized.has("dr_bonus_stats"):
		bonus_stats = serialized.dr_bonus_stats


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	connect_safely(player, "took_damage", self, "_on_player_took_damage")
	
	_invincibility_timer = player._invincibility_timer
	
	_next_protecting_count = 0
	
	_bonus_stat_hashes.clear()
	for stat in bonus_stats:
		_bonus_stat_hashes.push_back([Keys.generate_hash(stat[0]), stat[1]])
	
	if not _timer or not is_instance_valid(_timer):
		_timer = Timer.new()
		_timer.name = "PrideReaverTimer"
		player.call_deferred("add_child", _timer)
		_timer.autostart = false
		_timer.one_shot = true
		connect_safely(_timer, "timeout", self, "_on_pride_reaver_timer_timeout")


func _on_player_took_damage(_unit, _value, _knockback_direction, _is_crit, is_dodge, is_protected, _armor_did_something, _args, _hit_type, _is_one_shot) -> void:
	if is_dodge or is_protected:
		return
	
	_next_protecting_count += 1
	call_deferred("apply_hit_protection")


func apply_hit_protection() -> void:
	if _next_protecting_count > 0:
		_next_protecting_count -= 1
		
		for stat in _bonus_stat_hashes:
			TempStats.add_stat(stat[0], stat[1], _player_index)
		if is_instance_valid(_invincibility_timer):
			_invincibility_timer.start(duration)
		if is_instance_valid(_timer):
			_timer.start(duration)


func _on_pride_reaver_timer_timeout() -> void:
	for stat in _bonus_stat_hashes:
		TempStats.remove_stat(stat[0], stat[1], _player_index)


func get_args(_player_index: int) -> Array:
	var stat_text = ""
	for stat in bonus_stats:
		var colored_text = get_colored_text_by_value(stat[1], 0)
		stat_text += "%s %s & " % [colored_text[0], get_colored_text_by_sign(tr(stat[0].to_upper()), colored_text[1])]
	stat_text = stat_text.trim_suffix(" & ")
	
	return [stat_text, "[color=#00ff00]%.1f[/color]" % duration]
