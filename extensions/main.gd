extends "res://main.gd"


var dr_listener = null


func _on_EntitySpawner_players_spawned(players) -> void:
	._on_EntitySpawner_players_spawned(players)
	
	dr_listener = get_node_or_null("/root/ModLoader/JonathanFox-LegendsOnLeague/DesertRoseMainEventListener")
	
	if dr_listener:
		for player in players:
			dr_listener.emit_signal("player_spawned", player)
