extends "res://entities/units/player/player.gd"


const PRESERVE_KEY_WORDS: = [
	"Shadow", 
	"Highlight", 
	"Sprite", 
	"Legs",
]


func apply_items_effects()->void :
	if _dr_check_character("dr_"):
		RunData.appearances_displayed.clear()
		var animation_node = $Animation
		
		for character in RunData.items:
			if character is CharacterData and character.my_id.begins_with("dr_"):
				character = character as CharacterData
				for apperance in character.item_appearances:
					RunData.appearances_displayed.push_back(apperance)
	
	.apply_items_effects()


func _dr_check_character(start:String)->bool :
	if RunData.current_character == null:
		return false
	
	var gmo_characters:Array = RunData.get("gmo_characters")
	if gmo_characters:
		if gmo_characters.empty():
			for item in RunData.items:
				if item is CharacterData:
					if item.my_id.begins_with(start):
						gmo_characters.push_back(item.my_id)
						break
	else:
		gmo_characters = []
	
	if RunData.current_character.my_id.begins_with(start):
		return true
	elif RunData.current_character.my_id == "GMO_dummy":
		for id in gmo_characters:
			if id.begins_with(start):
				return true
	return false
