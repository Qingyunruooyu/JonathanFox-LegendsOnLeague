extends Node


const MOD_NAME = "JonathanFox-LegendsOnLeague"
const MOD_PATH = "res://mods-unpacked/" + MOD_NAME + "/"
const DR_EXTENSION_DIR = MOD_PATH + "extensions/"
const DR_TRANSLATION_DIR = MOD_PATH + "translations/"

const EXTENSION_SCRIPTS = [
	"utils.gd",
	"player_run_data.gd",
	"progress_data.gd",
	"run_data.gd",
	"main.gd",
	"player.gd",
	"weapon_service.gd",
	"entity_spawner.gd",
	"dlc_2_data.gd",
]


func _init():
	ModLoaderLog.info("Init", MOD_NAME)
	
	for script in EXTENSION_SCRIPTS:
		ModLoaderMod.install_script_extension(DR_EXTENSION_DIR + script)
	
	ModLoaderMod.add_translation(DR_TRANSLATION_DIR + "mod_translation.en.translation")
	ModLoaderMod.add_translation(DR_TRANSLATION_DIR + "mod_translation.zh_Hans_CN.translation")


func _ready():
	ModLoaderLog.info("Done", MOD_NAME)
	
	var listener = load(MOD_PATH + "desert_rose_main_event_listener.gd")
	listener = listener.new()
	listener.name = "DesertRoseMainEventListener"
	add_child(listener)
