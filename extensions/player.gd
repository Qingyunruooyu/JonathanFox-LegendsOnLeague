extends "res://entities/units/player/player.gd"


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
