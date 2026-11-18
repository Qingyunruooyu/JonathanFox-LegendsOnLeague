extends "res://singletons/progress_data.gd"


var dr_data = null
const DR_MOD_NAME = "JonathanFox-LegendsOnLeague"
const DR_MOD_PATH = "res://mods-unpacked/" + DR_MOD_NAME + "/"


func _ready() -> void:
	_dr_ready()


func _dr_ready() -> void:
	dr_data = load(DR_MOD_PATH + "content_data/content_data.tres")
	dr_data.add_resources()
	
	add_unlocked_by_default()
	RunData.reset()
	set_max_selectable_difficulty()
