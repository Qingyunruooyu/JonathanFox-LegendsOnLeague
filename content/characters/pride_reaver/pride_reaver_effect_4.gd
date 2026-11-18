extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (float) var duration: = 0.5
export (Array, Array) var bonus_stats: = [["stat_speed", 50]]

var _next_protecting_count: = 0
var _invincibility_timer = null
var _timer:Timer = null


func _on_desert_rose_wave_start(player)->void :
	connect_safely(player, "took_damage", self, "_on_player_took_damage")
	
	_invincibility_timer = player._invincibility_timer
	
	_next_protecting_count = 0
	
	if not _timer or not is_instance_valid(_timer):
		_timer = Timer.new()
		_timer.name = "PrideReaverTimer"
		player.call_deferred("add_child", _timer)
		_timer.autostart = false
		_timer.one_shot = true
		connect_safely(_timer, "timeout", self, "_on_pride_reaver_timer_timeout")


func _on_player_took_damage(_unit, _value, _knockback_direction, _knockback_amount, _is_crit, is_miss, is_dodge, is_protected, _effect_scale, _hit_type)->void :
	if is_miss or is_dodge or is_protected:
		return
	
	_next_protecting_count += 1
	call_deferred("apply_hit_protection")


func apply_hit_protection()->void :
	if _next_protecting_count > 0:
		_next_protecting_count -= 1
		
		for stat in bonus_stats:
			TempStats.add_stat(stat[0], stat[1])
		if is_instance_valid(_invincibility_timer):
			_invincibility_timer.start(duration)
		if is_instance_valid(_timer):
			_timer.start(duration)


func _on_pride_reaver_timer_timeout()->void :
	for stat in bonus_stats:
		TempStats.remove_stat(stat[0], stat[1])


func get_args()->Array :
	var stat_text:String = ""
	for stat in bonus_stats:
		var colored_text = get_colored_text_by_value(stat[1], 0)
		stat_text += "%s %s & " % [colored_text[0], get_colored_text_by_sign(tr(stat[0].to_upper()), colored_text[1])]
	stat_text = stat_text.trim_suffix(" & ")
	
	return [stat_text, "[color=#00ff00]%.1f[/color]" % duration]
