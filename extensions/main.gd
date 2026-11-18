extends "res://main.gd"


var DesertRoseMainEventListener = null


func _on_EntitySpawner_player_spawned(player)->void :
	._on_EntitySpawner_player_spawned(player)
	
	DesertRoseMainEventListener = get_node_or_null("/root/ModLoader/QianMo-LegendsOnLeague/DesertRoseMainEventListener")
	
	if DesertRoseMainEventListener:
		DesertRoseMainEventListener.emit_signal("player_spawned", player)


func reload_stats()->void :
	.reload_stats()
	
	if DesertRoseMainEventListener:
		DesertRoseMainEventListener.emit_signal("stats_updated")
