extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


var ELITE_WAVE_DATA = null

var _entity_spawner = null
var _change_chance: = 0.0
var _wave_ended: = false


func apply()->void :
	RunData.effects[key] += value


func unapply()->void :
	RunData.effects[key] -= value
	
	disconnect_safely(RunData.get_tree(), "node_added", self, "_on_node_added")
	
	.unapply()


func _on_desert_rose_wave_start(player)->void:
	_main = RunData.get_tree().current_scene
	_entity_spawner = _main._entity_spawner
	_entity_spawner.connect("enemy_spawned", self, "_on_enemy_spawned")
	
	_wave_ended = false
	_main._wave_timer.connect("timeout", self, "_on_wave_timer_timeout")
	
	_change_chance = RunData.effects["dr_character_elites_killer_effect"] / 100.0
	
	if _change_chance <= 0:
		disconnect_safely(RunData.get_tree(), "node_added", self, "_on_node_added")
	
	spawn_elite()
	connect_safely(RunData.get_tree(), "node_added", self, "_on_node_added")
	
	check_map_size()


func check_map_size()->void :
	if _main and is_instance_valid(_main):
		var map_size_coef = (1 + (RunData.effects["map_size"] / 100.0))
		
		if not map_size_coef == 0.67:
			map_size_coef = 0.67
			RunData.effects["map_size"] = -33
			
			var current_zone = ZoneService.get_zone_data(RunData.current_zone).duplicate()
			var current_wave_data = ZoneService.get_wave_data(RunData.current_zone, RunData.current_wave)
			
			current_zone.width = max(_main.MIN_MAP_SIZE, (current_zone.width * map_size_coef)) as int
			current_zone.height = max(_main.MIN_MAP_SIZE, (current_zone.height * map_size_coef)) as int
			
			_main._tile_map.clear()
			_main._tile_map.init(current_zone)
			_main._tile_map_limits.clear()
			_main._tile_map_limits.init(current_zone)
			
			ZoneService.current_zone_max_position = Vector2(current_zone.width * Utils.TILE_SIZE, current_zone.height * Utils.TILE_SIZE)
			
			_entity_spawner._zone_max_pos = ZoneService.current_zone_max_position
			
			_main.init_camera()


func _on_wave_timer_timeout()->void :
	_wave_ended = true


func _on_node_added(node)->void :
	if node is EntityBirth:
		yield(node, "ready")
		if node.type == EntityType.ENEMY:
			var unit_resource_path:String = node.entity_to_spawn.resource_path
			if unit_resource_path.ends_with("23.tscn") or unit_resource_path.ends_with("24.tscn"):
				return
			
			_entity_spawner.births.erase(node)
			node.queue_free()
			
			if randf() < _change_chance:
				spawn_elite()


func spawn_elite()->void :
	if _entity_spawner.bosses.size() > 5:
		var rnd_boss = Utils.get_rand_element(_entity_spawner.bosses)
		rnd_boss.stats.can_drop_consumables = false
		rnd_boss.stats.value = 0
		rnd_boss.stats.base_drop_chance = 0
		rnd_boss.stats.item_drop_chance = 0
		rnd_boss.die(Vector2.ZERO, true)

	var rnd_elite = Utils.get_rand_element(ItemService.elites)
	var unit = WaveUnitData.new()
	unit.type = EntityType.BOSS
	unit.unit_scene = rnd_elite.scene
	
	if not ELITE_WAVE_DATA:
		ELITE_WAVE_DATA = WaveGroupData.new()
	ELITE_WAVE_DATA.repeating = randi() % 3
	ELITE_WAVE_DATA.repeating_interval = randi() % 3 + 5
	var new_group_data = ELITE_WAVE_DATA.duplicate()
	new_group_data.wave_units_data.push_back(unit)
	
	_entity_spawner.on_group_spawn_timing_reached(new_group_data, false)

 
func _on_enemy_spawned(enemy)->void :
	if enemy is Boss:
		enemy.connect("died", self, "_on_boss_died")


func _on_boss_died(boss)->void :
	if not _wave_ended:
		if is_instance_valid(_entity_spawner):
			var timer = Timer.new()
			_entity_spawner.add_child(timer)
			timer.connect("timeout", self, "_on_extra_spawn_timer_timeout", [timer])
			timer.wait_time = rand_range(5.0, 8.0)
			timer.one_shot = true
			timer.start()


func _on_extra_spawn_timer_timeout(timer)->void :
	if is_instance_valid(timer):
		timer.queue_free()
	check_boss()


func check_boss()->void :
	if not _wave_ended and is_instance_valid(_entity_spawner):
		if _entity_spawner.bosses.empty():
			spawn_elite()


func get_args()->Array :
	return [str(value) + "%"]
