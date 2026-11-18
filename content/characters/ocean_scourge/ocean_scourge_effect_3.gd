extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


export (Resource) var exploding_effect
export (PackedScene) var mark_scene: PackedScene
export (float) var interval = 5.0
export (int) var base_damage = 10
export (Array, Array) var stats_scaled = [["stat_max_hp", 0.5]]

var _last_pos = Vector2.ZERO
var _current_exploding_effect = null
var _stats_scaled_hashes = []


static func get_id() -> String:
	return "dr_ocean_scourge_explosion"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_interval = interval
	serialized.dr_base_damage = base_damage
	serialized.dr_stats_scaled = stats_scaled
	if exploding_effect != null:
		serialized.dr_exploding_effect_path = exploding_effect.resource_path
	if mark_scene != null:
		serialized.dr_mark_scene_path = mark_scene.resource_path
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_interval"):
		interval = serialized.dr_interval
	if serialized.has("dr_base_damage"):
		base_damage = serialized.dr_base_damage
	if serialized.has("dr_stats_scaled"):
		stats_scaled = serialized.dr_stats_scaled
	if serialized.has("dr_exploding_effect_path"):
		exploding_effect = load(serialized.dr_exploding_effect_path)
	if serialized.has("dr_mark_scene_path"):
		mark_scene = load(serialized.dr_mark_scene_path)


func _on_desert_rose_wave_start(_p_player) -> void:
	._on_desert_rose_wave_start(_p_player)
	_main = RunData.get_tree().current_scene
	_player_index = _p_player.player_index
	
	_current_exploding_effect = exploding_effect.duplicate()
	_current_exploding_effect.scale = 1.5
	
	_stats_scaled_hashes.clear()
	for stat in stats_scaled:
		_stats_scaled_hashes.push_back([Keys.generate_hash(stat[0]), stat[1]])
	
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


func _get_damage(player_index: int) -> int:
	var damage = base_damage
	for stat in _stats_scaled_hashes:
		var stat_value = Utils.get_stat(stat[0], player_index)
		damage += WeaponService.apply_damage_bonus(int(stat_value * stat[1]), player_index)
	return int(max(1, damage * (Utils.get_stat(Keys.explosion_damage_hash, player_index) / 100.0 + 1.0)))


func _on_timer_timeout() -> void:
	var args = WeaponServiceExplodeArgs.new()
	args.pos = _last_pos
	args.damage = _get_damage(_player_index)
	args.accuracy = 1.0
	args.crit_chance = 0.03
	args.crit_damage = 2.0
	args.burning_data = WeaponService.init_burning_data(BurningData.new(), _player_index)
	args.from_player_index = _player_index
	args.from = _player
	args.damage_tracking_key_hash = Utils.character_dr_ocean_scourge_hash
	
	WeaponService.explode(_current_exploding_effect, args)
	
	_last_pos = ZoneService.get_rand_pos()
	var mark = mark_scene.instance()
	mark.init(interval)
	mark.global_position = _last_pos
	_main.call_deferred("add_child", mark)


func get_args(player_index: int) -> Array:
	var interval_text = "[color=#00ff00]%.1f[/color]" % interval
	
	var damage = _get_damage(player_index)
	var scaling_text = ""
	for stat in stats_scaled:
		scaling_text += "%.0f%% %s " % [stat[1] * 100, tr(stat[0].to_upper())]
	
	scaling_text = scaling_text.trim_suffix(" ")
	var damage_text = "%s [color=gray]| %d[/color] (%s)" % [get_colored_text_by_value(damage, base_damage)[0], base_damage, scaling_text]
	
	return [interval_text, damage_text]
