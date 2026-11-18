extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (Resource) var exploding_effect
export (PackedScene) var mark_scene:PackedScene
export (float) var interval: = 5.0
export (int) var base_damage: = 10
export (Array, Array) var stats_scaled: = [["stat_max_hp", 0.5]]

var _last_pos:Vector2 = Vector2.ZERO
var _current_exploding_effect = null


func _on_desert_rose_wave_start(_p_player)->void :
	_main = RunData.get_tree().current_scene
	
	_current_exploding_effect = exploding_effect.duplicate()
	_current_exploding_effect.scale = 1.5
	
	var timer = Timer.new()
	_main.add_child(timer)
	timer.wait_time = interval
	timer.one_shot = false
	timer.start()
	
	var _error = timer.connect("timeout", self, "_on_timer_timeout")
	
	_last_pos = ZoneService.get_rand_pos()
	var mark = mark_scene.instance()
	mark.init(interval)
	mark.global_position = _last_pos
	_main.call_deferred("add_child", mark)


func _on_timer_timeout()->void :
	var damage = base_damage
	for stat in stats_scaled:
		var stat_value = Utils.get_stat(stat[0])
		damage += RunData.get_dmg(stat_value * stat[1])
	damage = max(1, damage * (Utils.get_stat("explosion_damage") / 100.0 + 1.0)) as int
	
	WeaponService.explode(_current_exploding_effect, _last_pos, damage, 1.0, 0.03, 2.0, RunData.effects["burn_chance"])
	
	_last_pos = ZoneService.get_rand_pos()
	var mark = mark_scene.instance()
	mark.init(interval)
	mark.global_position = _last_pos
	_main.call_deferred("add_child", mark)


func get_args()->Array :
	var interval_text:String = "[color=#00ff00]%.1f[/color]" % interval
	
	var damage:int = base_damage
	var scaling_text:String = ""
	for stat in stats_scaled:
		var stat_value = Utils.get_stat(stat[0])
		scaling_text += Utils.get_scaling_stat_text(stat[0], stat[1]) + " "
		damage += RunData.get_dmg(stat_value * stat[1])
	damage = max(1, damage * (Utils.get_stat("explosion_damage") / 100.0 + 1.0)) as int
	
	scaling_text = scaling_text.trim_suffix(" ")
	var damage_text:String = "%s [color=gray]| %d[/color] (%s)" % [get_colored_text_by_value(damage, base_damage)[0], base_damage, scaling_text]
	
	return [interval_text, damage_text]
