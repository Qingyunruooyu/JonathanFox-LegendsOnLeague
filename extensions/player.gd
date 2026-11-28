extends "res://entities/units/player/player.gd"


func init(zone_min_pos: Vector2, zone_max_pos: Vector2, p_players_ref: Array = [], entity_spawner_ref = null) -> void:
	.init(zone_min_pos, zone_max_pos, p_players_ref, entity_spawner_ref)

	var _error = _entity_spawner_ref.connect("players_spawned", self, "_dr_on_players_spawned")


func _dr_on_players_spawned(players: Array) -> void:
	if not players.has(self):
		return

	var dr_effects = []
	for item in RunData.get_player_items(player_index):
		for effect in item.effects:
			if effect.get_id().begins_with("dr_"):
				effect.apply_connection(self)
				effect._on_desert_rose_wave_start(self)
				dr_effects.push_back(effect)

	for weapon in current_weapons:
		for effect in dr_effects:
			effect.connect_weapon(weapon)


func add_weapon(weapon: WeaponData, pos: int) -> void:
	.add_weapon(weapon, pos)

	var instance = current_weapons.back()
	if instance != null:
		for item in RunData.get_player_items(player_index):
			for effect in item.effects:
				if effect.get_id().begins_with("dr_"):
					effect.connect_weapon(instance)


func apply_items_effects() -> void:
	if _dr_check_character("dr_", player_index):
		var player_appearances = RunData.players_data[player_index].appearances
		player_appearances.clear()
		
		for item in RunData.get_player_items(player_index):
			if item is CharacterData and item.my_id.begins_with("dr_"):
				for appearance in item.item_appearances:
					player_appearances.push_back(appearance)
		
		RunData.sort_appearances()
	
	.apply_items_effects()


func _dr_check_character(start: String, player_index: int) -> bool:
	var current_character = RunData.get_player_character(player_index)
	if current_character == null:
		return false
	
	if current_character.my_id.begins_with(start):
		return true
	
	if current_character.my_id == "GMO_dummy":
		var gmo_characters = RunData.get("gmo_characters")
		if gmo_characters != null:
			for id in gmo_characters:
				if id.begins_with(start):
					return true
	
	return false
