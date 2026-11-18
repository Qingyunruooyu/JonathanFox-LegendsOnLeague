extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


var ELITE_WAVE_DATA = null

var _entity_spawner = null
var _wave_ended = false
var _elite_scenes = []


static func get_id() -> String:
	return "dr_elites_killer_effect"


func apply(player_index: int) -> void:
	RunData.get_player_effects(player_index)[key_hash] += value


func unapply(player_index: int) -> void:
	RunData.get_player_effects(player_index)[key_hash] -= value


func cleanup(player_index: int) -> void:
	if is_instance_valid(_entity_spawner):
		disconnect_safely(_entity_spawner, "enemy_spawned", self, "_on_enemy_spawned")
		_entity_spawner.dr_elite_replace_chance = 0.0
		_entity_spawner.dr_elite_scenes = []
	
	.cleanup(player_index)


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	_main = RunData.get_tree().current_scene
	_entity_spawner = _main._entity_spawner
	
	disconnect_safely(_entity_spawner, "enemy_spawned", self, "_on_enemy_spawned")
	_entity_spawner.connect("enemy_spawned", self, "_on_enemy_spawned")
	
	_wave_ended = false
	disconnect_safely(_main._wave_timer, "timeout", self, "_on_wave_timer_timeout")
	_main._wave_timer.connect("timeout", self, "_on_wave_timer_timeout")
	
	_elite_scenes.clear()
	var zone_data = ZoneService.get_zone_data(RunData.current_zone)
	for elite in zone_data.elites:
		_elite_scenes.push_back(elite.scene)
	
	_entity_spawner.dr_elite_scenes = _elite_scenes
	_entity_spawner.dr_elite_replace_chance = min(1.0, RunData.sum_all_player_effects(key_hash) / 100.0)
	
	spawn_elite()
	check_map_size()


func check_map_size() -> void:
	if _main and is_instance_valid(_main):
		var effects = RunData.get_player_effects(_player_index)
		var map_size_coef = (1 + (effects[Keys.map_size_hash] / 100.0))
		
		if not map_size_coef == 0.67:
			effects[Keys.map_size_hash] = -33
			
			var current_zone = ZoneService.get_zone_data(RunData.current_zone).duplicate()
			current_zone.width = max(_main.MIN_MAP_SIZE, int(current_zone.width * 0.67))
			current_zone.height = max(_main.MIN_MAP_SIZE, int(current_zone.height * 0.67))
			
			ZoneService.set_current_zone(current_zone)
			_main._tile_map.clear()
			_main._tile_map.init(current_zone)
			for child in _main._tile_map_limits.get_children():
				child.queue_free()
			_main._tile_map_limits.init(current_zone)
			
			_entity_spawner._zone_min_pos = ZoneService.current_zone_min_position
			_entity_spawner._zone_max_pos = ZoneService.current_zone_max_position
			
			var max_bounds = ZoneService.get_current_zone_rect().grow_individual(_main.EDGE_SIZE, _main.EDGE_SIZE * 2, _main.EDGE_SIZE, _main.EDGE_SIZE)
			_main._camera.init(max_bounds, float(_main.EDGE_SIZE))
			ZoneService.current_zone_max_camera_rect = _main._camera.get_max_camera_bounds()


func _on_wave_timer_timeout() -> void:
	_wave_ended = true


func spawn_elite() -> void:
	if _entity_spawner.bosses.size() > 5:
		var rnd_boss = Utils.get_rand_element(_entity_spawner.bosses)
		rnd_boss.stats.can_drop_consumables = false
		rnd_boss.stats.value = 0
		rnd_boss.stats.base_drop_chance = 0
		rnd_boss.stats.item_drop_chance = 0
		rnd_boss.die()
	
	if _elite_scenes.empty():
		return
	
	var unit = WaveUnitData.new()
	unit.type = EntityType.BOSS
	unit.unit_scene = Utils.get_rand_element(_elite_scenes)
	
	if not ELITE_WAVE_DATA:
		ELITE_WAVE_DATA = WaveGroupData.new()
	ELITE_WAVE_DATA.repeating = randi() % 3
	ELITE_WAVE_DATA.repeating_interval = randi() % 3 + 5
	var new_group_data = ELITE_WAVE_DATA.duplicate()
	new_group_data.is_boss = true
	new_group_data.wave_units_data.push_back(unit)
	
	_entity_spawner.on_group_spawn_timing_reached(new_group_data)


func _on_enemy_spawned(enemy) -> void:
	if enemy is Boss:
		enemy.connect("died", self, "_on_boss_died")


func _on_boss_died(_boss, _args) -> void:
	if not _wave_ended:
		if is_instance_valid(_entity_spawner):
			var timer = Timer.new()
			_entity_spawner.add_child(timer)
			timer.connect("timeout", self, "_on_extra_spawn_timer_timeout", [timer])
			timer.wait_time = rand_range(5.0, 8.0)
			timer.one_shot = true
			timer.start()


func _on_extra_spawn_timer_timeout(timer) -> void:
	if is_instance_valid(timer):
		timer.queue_free()
	check_boss()


func check_boss() -> void:
	if not _wave_ended and is_instance_valid(_entity_spawner):
		if _entity_spawner.bosses.empty():
			spawn_elite()


func get_args(_player_index: int) -> Array:
	return [str(value) + "%"]
