extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED, BOTH}


export (float) var chance = 1.0
export (Type) var weapon_type = Type.BOTH


static func get_id() -> String:
	return "dr_chance_weapon_burning"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.dr_chance = chance
	serialized.dr_weapon_type = weapon_type
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("dr_chance"):
		chance = serialized.dr_chance
	if serialized.has("dr_weapon_type"):
		weapon_type = serialized.dr_weapon_type


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)
	
	for weapon_instance in player.current_weapons:
		if weapon_instance is MeleeWeapon:
			if weapon_type == Type.MELEE or weapon_type == Type.BOTH:
				connect_safely(weapon_instance._hitbox, "hit_something", self, "_on_player_hit_something", [weapon_instance._hitbox])
		elif weapon_instance is RangedWeapon:
			if weapon_type == Type.RANGED or weapon_type == Type.BOTH:
				connect_safely(weapon_instance._shooting_behavior, "projectile_shot", self, "_on_player_projectile_shot")


func _on_player_projectile_shot(projectile) -> void:
	if is_instance_valid(projectile):
		var hitbox = projectile._hitbox
		
		if hitbox and is_instance_valid(hitbox):
			connect_safely(hitbox, "hit_something", self, "_on_player_hit_something", [hitbox])


func _on_player_hit_something(_thing_hit, _damage_dealt, source_hitbox) -> void:
	if chance >= 1 or randf() < chance:
		if not _thing_hit.dead:
			var burning_data = BurningData.new()
			burning_data.duration = 3
			burning_data.damage = _damage_dealt
			burning_data.chance = 1
			burning_data.spread = 0
			burning_data.from = source_hitbox.from
			
			_thing_hit.apply_burning(burning_data)


func get_args(_player_index: int) -> Array:
	var type_text = ""
	if weapon_type == Type.RANGED:
		type_text = tr("RANGED") + tr("WEAPONS")
	elif weapon_type == Type.MELEE:
		type_text = tr("MELEE") + tr("WEAPONS")
	else:
		type_text = tr("WEAPONS")
	
	return [type_text, "%.1f" % (chance * 100)]
