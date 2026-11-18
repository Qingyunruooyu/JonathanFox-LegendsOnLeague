extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED}


export (Type) var weapon_type = Type.MELEE


static func get_id() -> String:
	return "dr_weapon_type_burning"


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
