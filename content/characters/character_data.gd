extends "res://items/characters/character_data.gd"


func _get_tracking_text(player_index: int) -> String:
	var text = ""
	if player_index == RunData.DUMMY_PLAYER_INDEX:
		return text

	var tracking_key = my_id_hash

	if not RunData.tracked_item_effects[player_index].has(tracking_key) or tracking_text == "[EMPTY]" or tracking_text == "":
		return text

	var item_effect = RunData.tracked_item_effects[player_index][tracking_key]

	if item_effect is Array:
		for i in item_effect.size():
			var tracked_count = item_effect[i]
			var tracking_text_to_use = tracking_text

			if my_id_hash == Utils.character_dr_ocean_scourge_hash and i == 1:
				tracking_text_to_use = "MATERIALS_GAINED"

			text += "\n[color=#" + Utils.SECONDARY_FONT_COLOR.to_html() + "]" + Text.text(tracking_text_to_use.to_upper(), [Text.get_formatted_number(tracked_count)]) + "[/color]"
	else:
		text += "\n[color=#" + Utils.SECONDARY_FONT_COLOR.to_html() + "]" + Text.text(tracking_text.to_upper(), [Text.get_formatted_number(item_effect)]) + "[/color]"

	return text
