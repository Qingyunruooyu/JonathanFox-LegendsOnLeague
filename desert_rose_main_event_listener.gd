extends Node


signal player_spawned(player)


var _applied_effects = {}


func _ready():
	if not RunData.has_user_signal("desert_rose_wave_start"):
		RunData.add_user_signal("desert_rose_wave_start")
	
	connect("player_spawned", self, "_on_player_spawned")


func _on_player_spawned(player) -> void:
	var pid: int = player.player_index
	
	for stale_pid in _applied_effects.keys():
		if stale_pid >= RunData.get_player_count():
			for effect in _applied_effects[stale_pid]:
				effect.cleanup(stale_pid)
			_applied_effects.erase(stale_pid)
	
	if not _applied_effects.has(pid):
		_applied_effects[pid] = []
	
	var applying_effects = []
	
	for item in RunData.get_player_items(pid):
		for effect in item.effects:
			if effect.get_id().begins_with("dr_"):
				effect.apply_connection(player)
				applying_effects.append(effect)
				if not _applied_effects[pid].has(effect):
					_applied_effects[pid].append(effect)
	
	for weapon in RunData.get_player_weapons_ref(pid):
		for effect in weapon.effects:
			if effect.get_id().begins_with("dr_"):
				effect.apply_connection(player)
				applying_effects.append(effect)
				if not _applied_effects[pid].has(effect):
					_applied_effects[pid].append(effect)
	
	for effect in _applied_effects[pid].duplicate():
		if not applying_effects.has(effect):
			effect.cleanup(pid)
			_applied_effects[pid].erase(effect)
	
	RunData.emit_signal("desert_rose_wave_start", player)
