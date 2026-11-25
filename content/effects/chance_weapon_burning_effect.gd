extends "res://mods-unpacked/JonathanFox-LegendsOnLeague/content/effects/desert_rose_effect_parent.gd"


enum Type {MELEE, RANGED, BOTH}


export (float) var chance = 1.0
export (Type) var weapon_type = Type.BOTH
export (int) var burning_damage = 4
export (int) var burning_duration = 2
export (Array, Array) var stats_scaled = [["stat_melee_damage", 0.75], ["stat_crit_chance", 0.75]]

var _base_burning_data: BurningData = null
var _burning_data: BurningData = null


static func get_id() -> String:
	return "dr_chance_weapon_burning"


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.dr_chance = chance
	serialized.dr_weapon_type = weapon_type
	serialized.dr_burning_damage = burning_damage
	serialized.dr_burning_duration = burning_duration
	serialized.dr_stats_scaled = stats_scaled

	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	chance = serialized.dr_chance
	weapon_type = serialized.dr_weapon_type
	burning_damage = serialized.dr_burning_damage
	burning_duration = serialized.dr_burning_duration
	stats_scaled = serialized.dr_stats_scaled


func _on_desert_rose_wave_start(player) -> void:
	._on_desert_rose_wave_start(player)

	_build_base_burning_data()
	_refresh_burning_data()
	connect_safely(RunData, "stats_updated", self, "_on_stats_updated")

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


func _on_stats_updated(player_index) -> void:
	if player_index == _player_index:
		_refresh_burning_data()


func _on_player_hit_something(_thing_hit, _damage_dealt, source_hitbox) -> void:
	if chance >= 1 or randf() < chance:
		if not _thing_hit.dead:
			if _burning_data == null:
				_refresh_burning_data()
			_burning_data.from = source_hitbox.from

			_thing_hit.apply_burning(_burning_data)


func _build_base_burning_data() -> void:
	if _base_burning_data != null:
		return
	var burning_data = BurningData.new()
	burning_data.chance = 1
	burning_data.damage = burning_damage
	burning_data.duration = burning_duration
	burning_data.spread = 0
	burning_data.scaling_stats = stats_scaled.duplicate()
	_base_burning_data = burning_data


func _refresh_burning_data() -> void:
	_build_base_burning_data()
	_burning_data = WeaponService.init_burning_data(_base_burning_data, _player_index)


func get_args(player_index: int) -> Array:
	var type_text = ""
	if weapon_type == Type.RANGED:
		type_text = tr("RANGED") + tr("WEAPONS")
	elif weapon_type == Type.MELEE:
		type_text = tr("MELEE") + tr("WEAPONS")
	else:
		type_text = tr("WEAPONS")

	_build_base_burning_data()
	var current_burning_data = WeaponService.init_burning_data(_base_burning_data, player_index)
	var scaling_text = WeaponService.get_scaling_stats_icon_text(current_burning_data.scaling_stats)
	var damage_text = "%s*%d (%s)" % [get_colored_text_by_value(current_burning_data.damage, burning_damage)[0], current_burning_data.duration, scaling_text]

	return [type_text, "%.1f" % (chance * 100), damage_text]


func _add_custom_args() -> void:
	var chance_arg = CustomArg.new()
	chance_arg.arg_index = 1
	chance_arg.arg_sign = Sign.FROM_ARG
	custom_args.append(chance_arg)


func _remove_custom_args() -> void:
	custom_args.pop_back()
