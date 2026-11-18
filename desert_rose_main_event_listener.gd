class_name DesertRoseMainEventListener
extends Node


signal player_spawned(player)
signal stats_updated


var _applied_effects = []
var _applying_effects = []


func _ready():
	if not RunData.has_user_signal("desert_rose_wave_start"):
		RunData.add_user_signal("desert_rose_wave_start")
	
	connect("player_spawned", self, "_on_player_spawned")


func _on_player_spawned(player)->void :
	for item in RunData.items:
		for effect in item.effects:
			if not effect.get_id().find("desert_rose_effect") == -1:
				effect.apply_connection()
				_applying_effects.append(effect)
				if not _applied_effects.has(effect):
					_applied_effects.append(effect)
	for weapon in RunData.weapons:
		for effect in weapon.effects:
			if not effect.get_id().find("desert_rose_effect") == -1:
				effect.apply_connection()
				_applying_effects.append(effect)
				if not _applied_effects.has(effect):
					_applied_effects.append(effect)
	for effect in _applied_effects.duplicate():
		if not _applying_effects.has(effect):
			effect.unapply()
			_applied_effects.erase(effect)
	_applying_effects.clear()
	
	RunData.emit_signal("desert_rose_wave_start", player)
