extends Node


var _player = null
var _hitboxes: Array = []


func _ready():
	_player = get_parent()
	
	for weapon in _player.current_weapons:
		connect_weapon(weapon)


func connect_weapon(weapon) -> void:
	if weapon is MeleeWeapon:
		var hitbox = weapon._hitbox

		if hitbox and not _hitboxes.has(hitbox):
			_hitboxes.push_back(hitbox)
			hitbox.set_deferred("collision_mask", hitbox.collision_mask | 1 << 4)
			hitbox.set_deferred("monitoring", true)
			connect_safely(hitbox, "area_entered", self, "_on_area_entered")


func _exit_tree():
	for hitbox in _hitboxes:
		if hitbox != null and is_instance_valid(hitbox):
			hitbox.set_deferred("monitoring", false)
			if hitbox.is_connected("area_entered", self, "_on_area_entered"):
				hitbox.disconnect("area_entered", self, "_on_area_entered")
	
	_hitboxes.clear()


func connect_safely(obj, signal_name: String, target, call_back: String) -> void:
	if obj == null or not is_instance_valid(obj) or obj.is_connected(signal_name, target, call_back):
		return
	
	var _error = obj.connect(signal_name, target, call_back)


func _on_area_entered(area) -> void:
	if area.collision_layer & 1 << 4:
		var parent = area.get_parent()
		if parent is EnemyProjectile:
			RunData.add_tracked_value(_player.player_index, Utils.character_dr_desert_rose_hash, 1)
			area.hit_something(_player, 0)
