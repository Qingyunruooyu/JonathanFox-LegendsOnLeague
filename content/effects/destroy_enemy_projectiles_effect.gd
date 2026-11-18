extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


func _on_desert_rose_wave_start(player)->void :
	._on_desert_rose_wave_start(player)

	var weapons = player.current_weapons
	for weapon in weapons:
		if weapon is MeleeWeapon:
			var hitbox = weapon.get("_hitbox")
			
			if hitbox:
				hitbox.set_deferred("collision_mask", hitbox.collision_mask | 1 << 4)
				hitbox.set_deferred("monitoring", true)
				
				connect_safely(hitbox, "area_entered", self, "_on_area_entered")


func unapply()->void :
	.unapply()
	
	_player = TempStats.player
	if not _player == null and is_instance_valid(_player):
		var weapons = _player.current_weapons
		for weapon in weapons:
			if weapon is MeleeWeapon:
				var hitbox = weapon.get("_hitbox")
				
				if hitbox:
					hitbox.set_deferred("monitoring", false)
					
					disconnect_safely(hitbox, "area_entered", self, "_on_area_entered")


func _on_area_entered(area)->void :
	if area.collision_layer & 1 << 4:
		var parent = area.get_parent()
		if parent is EnemyProjectile:
			parent.set_to_be_destroyed()
