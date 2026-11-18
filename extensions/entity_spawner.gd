extends "res://global/entity_spawner.gd"


var dr_elite_replace_chance = 0.0
var dr_elite_scenes = []


func on_group_spawn_timing_reached(group_data: WaveGroupData) -> void:
	var prev_size = queue_to_spawn.size()
	.on_group_spawn_timing_reached(group_data)
	
	if dr_elite_replace_chance <= 0.0 or dr_elite_scenes.empty():
		return
	
	for i in range(prev_size, queue_to_spawn.size()):
		var request = queue_to_spawn[i]
		if request.type == EntityType.ENEMY and randf() < dr_elite_replace_chance:
			request.type = EntityType.BOSS
			request.scene = Utils.get_rand_element(dr_elite_scenes)
