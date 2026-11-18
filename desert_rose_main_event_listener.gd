extends Node


signal player_spawned(player)


var _applied_effects = []
var _applying_effects = []


func _ready():
	if not RunData.has_user_signal("desert_rose_wave_start"):
		RunData.add_user_signal("desert_rose_wave_start")
	
	connect("player_spawned", self, "_on_player_spawned")


func _on_player_spawned(player) -> void:
	_applying_effects.clear()
	
	for item in RunData.get_player_items(player.player_index):
		for effect in item.effects:
			if effect.get_id().begins_with("dr_"):
				effect.apply_connection(player)
				_applying_effects.append(effect)
				if not _applied_effects.has(effect):
					_applied_effects.append(effect)
	
	for weapon in RunData.get_player_weapons_ref(player.player_index):
		for effect in weapon.effects:
			if effect.get_id().begins_with("dr_"):
				effect.apply_connection(player)
				_applying_effects.append(effect)
				if not _applied_effects.has(effect):
					_applied_effects.append(effect)
	
	for effect in _applied_effects.duplicate():
		if not _applying_effects.has(effect):
			effect.cleanup(effect._player_index)
			effect.unapply(effect._player_index)
			_applied_effects.erase(effect)
	
	RunData.emit_signal("desert_rose_wave_start", player)
