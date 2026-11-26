extends Node


var _player = null
var _player_index: int = 0
var _main = null
var _chance: float = 0.0
var _max_targets: int = 0
var _detact_scene = null
var _stats_resource = null
var _current_stats = null


func init(chance: float, max_targets: int, detact_scene, stats_resource) -> void:
	_chance = chance
	_max_targets = max_targets
	_detact_scene = detact_scene
	_stats_resource = stats_resource


func _ready():
	_player = get_parent()
	_player_index = _player.player_index
	_main = RunData.get_tree().current_scene
	
	_refresh_stats()
	
	for weapon_instance in _player.current_weapons:
		connect_weapon(weapon_instance)
	
	connect_safely(RunData, "stats_updated", self, "_on_stats_updated")


func connect_weapon(weapon) -> void:
	if weapon is MeleeWeapon:
		connect_safely(weapon._hitbox, "hit_something", self, "_on_player_hit_something")
	elif weapon is RangedWeapon:
		connect_safely(weapon._shooting_behavior, "projectile_shot", self, "_on_player_projectile_shot")


func connect_safely(obj, signal_name: String, target, call_back: String) -> void:
	if obj == null or not is_instance_valid(obj) or obj.is_connected(signal_name, target, call_back):
		return
	
	var _error = obj.connect(signal_name, target, call_back)


func _refresh_stats() -> void:
	_current_stats = WeaponService.init_ranged_stats(_stats_resource, _player_index)
	_current_stats.bounce = 0


func _on_stats_updated(player_index) -> void:
	if player_index == _player_index:
		_refresh_stats()


func _on_player_projectile_shot(projectile) -> void:
	if is_instance_valid(projectile):
		var hitbox = projectile._hitbox
		
		if hitbox and is_instance_valid(hitbox):
			connect_safely(hitbox, "hit_something", self, "_on_player_hit_something")


func _on_player_hit_something(thing_hit, _damage_dealt) -> void:
	if randf() < _chance:
		var detact_area = _detact_scene.instance()
		detact_area.init(_max_targets)
		thing_hit.call_deferred("add_child", detact_area)
		detact_area.connect("spread_ready", self, "_on_spread_ready", [thing_hit])


func _on_spread_ready(targets, thing_hit) -> void:
	if is_instance_valid(thing_hit):
		for target in targets:
			var angle = 0
			if is_instance_valid(target):
				angle = (target.global_position - thing_hit.global_position).angle()
			else:
				angle = rand_range(0, 2 * PI)
			
			var args = WeaponServiceSpawnProjectileArgs.new()
			args.damage_tracking_key_hash = Utils.character_dr_lighting_mage_hash
			args.from_player_index = _player_index
			var projectile = WeaponService.manage_special_spawn_projectile(thing_hit, _current_stats, angle, false, _main._entity_spawner, _player, args)
			projectile.call_deferred("set_ignored_objects", [thing_hit])
