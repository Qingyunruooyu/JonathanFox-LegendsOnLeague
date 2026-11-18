extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


static func get_id() -> String:
	return "dr_destroy_enemy_projectiles"


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	var weapons = player.current_weapons
	for weapon in weapons:
		if weapon is MeleeWeapon:
			var hitbox = weapon._hitbox
			
			if hitbox:
				hitbox.set_deferred("collision_mask", hitbox.collision_mask | 1 << 4)
				hitbox.set_deferred("monitoring", true)
				
				connect_safely(hitbox, "area_entered", self, "_on_area_entered")


func unapply(player_index: int) -> void:
	pass


func cleanup(player_index: int) -> void:
	if not _player == null and is_instance_valid(_player):
		var weapons = _player.current_weapons
		for weapon in weapons:
			if weapon is MeleeWeapon:
				var hitbox = weapon._hitbox
				
				if hitbox:
					hitbox.set_deferred("monitoring", false)
					
					disconnect_safely(hitbox, "area_entered", self, "_on_area_entered")
	
	.cleanup(player_index)


func _on_area_entered(area) -> void:
	if area.collision_layer & 1 << 4:
		var parent = area.get_parent()
		if parent is EnemyProjectile:
			parent.set_to_be_destroyed()
