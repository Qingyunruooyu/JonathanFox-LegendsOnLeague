extends Node


const MOD_DIR = "QianMo-LegendsOnLeague/"
const MOD_NAME = 'QianMo-LegendsOnLeague'

var dir = ""
var ext_dir = ""
var trans_dir = ""


func _init(_modLoader = ModLoader):
	ModLoaderLog.info("Init", MOD_NAME)
	
	dir = ModLoaderMod.get_unpacked_dir() + MOD_DIR
	
	ext_dir = dir + "extensions/"
	trans_dir = dir + "translations/"
	
	ModLoaderMod.install_script_extension(ext_dir + "main.gd")
	ModLoaderMod.install_script_extension(ext_dir + "players/player.gd")
	ModLoaderMod.install_script_extension(ext_dir + "singletons/run_data.gd")
	ModLoaderMod.install_script_extension(ext_dir + "singletons/progress_data.gd")
	
	ModLoaderMod.add_translation(trans_dir + "mod_translation.zh.translation")
	ModLoaderMod.add_translation(trans_dir + "mod_translation.en.translation")


func _ready():
	ModLoaderLog.info('Done', MOD_NAME)
	
	ItemService.effects.push_back(load("res://mods-unpacked/QianMo-LegendsOnLeague/content/characters/pride_reaver/pride_reaver_effect_1.gd"))
	
	var ContentLoader = get_node("/root/ModLoader/Darkly77-ContentLoader/ContentLoader")
	ContentLoader.load_data(dir + "content_data/desert_rose_items.tres", MOD_NAME)
	
	var listener = load("res://mods-unpacked/QianMo-LegendsOnLeague/desert_rose_main_event_listener.gd")
	listener = listener.new()
	listener.name = "DesertRoseMainEventListener"
	add_child(listener)

