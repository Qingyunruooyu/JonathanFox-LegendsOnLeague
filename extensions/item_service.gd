extends "res://singletons/item_service.gd"


func get_disabled_required_update(character: CharacterData) -> UpdateData:
	if "dr_required_item_set" in character:
		for item_set_id in character.dr_required_item_set:
			if not ProgressData.has_item_set(item_set_id):
				for update_data in update_data_list:
					if update_data != null and update_data.id == item_set_id:
						return update_data
	return .get_disabled_required_update(character)
