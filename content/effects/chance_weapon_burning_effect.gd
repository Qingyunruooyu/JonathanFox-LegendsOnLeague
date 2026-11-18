extends "res://mods-unpacked/QianMo-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED, BOTH}


export (float) var chance: = 1.0
export (Type) var weapon_type: = Type.BOTH


func _on_desert_rose_wave_start(player)->void :
	._on_desert_rose_wave_start(player)
	
	for weapon_instance in player.current_weapons:
		if weapon_instance is MeleeWeapon:
			if weapon_type == Type.MELEE or weapon_type == Type.BOTH:
				connect_safely(weapon_instance._hitbox, "hit_something", self, "_on_player_hit_something")
		elif weapon_instance is RangedWeapon:
			if weapon_type == Type.RANGED or weapon_type == Type.BOTH:
				connect_safely(weapon_instance._shooting_behavior, "projectile_shot", self, "_on_player_projectile_shot")


func _on_player_projectile_shot(projectile)->void :
	if is_instance_valid(projectile):
		var hitbox = projectile.get("_hitbox")
		
		if hitbox and is_instance_valid(hitbox):
			hitbox.connect("hit_something", self, "_on_player_hit_something")


func _on_player_hit_something(_thing_hit, _damage_dealt)->void:
	if chance >= 1 or randf() < chance:
		if not _thing_hit.dead:
			var burning_data = BurningData.new()
			burning_data.duration = 3
			burning_data.damage = _damage_dealt
			burning_data.chance = 1
			burning_data.spread = 0
			
			_thing_hit.apply_burning(burning_data)


func get_args()->Array :
	var type_text:String
	if weapon_type == Type.RANGED:
		type_text = tr("RANGED") + tr("DR_WEAPON")
	elif weapon_type == Type.MELEE:
		type_text = tr("MELEE") + tr("DR_WEAPON")
	else:
		type_text = tr("DR_WEAPON")
	
	return [type_text, "%.1f" % (chance * 100)]
