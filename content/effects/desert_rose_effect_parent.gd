extends "res://items/global/effect.gd"


var _main = null
var _owner_pids: Array = []
var _wave_once: Dictionary = {}
var _connections_list: Array = []
var _monitors: Dictionary = {}


static func get_id() -> String:
	return "dr_effect"


func apply(player_index: int) -> void:
	pass


func unapply(player_index: int) -> void:
	pass


func cleanup(player_index: int) -> void:
	_owner_pids.erase(player_index)
	remove_monitor(player_index)
	_on_owner_removed(player_index)
	
	if _owner_pids.empty():
		_disconnect_all()
		_wave_once.clear()
		_on_last_owner_removed()


func _on_owner_removed(player_index: int) -> void:
	pass


func _on_last_owner_removed() -> void:
	pass


func apply_connection(player) -> void:
	var scene = RunData.get_tree().current_scene
	if scene != _main:
		_main = scene
		_owner_pids.clear()
		_wave_once.clear()
		
		for i in range(_connections_list.size() - 1, -1, -1):
			var connection = _connections_list[i]
			if connection[0] == null or not is_instance_valid(connection[0]):
				_connections_list.remove(i)
	
	if player != null and is_instance_valid(player):
		if not _owner_pids.has(player.player_index):
			_owner_pids.push_back(player.player_index)


func connect_weapon(weapon) -> void:
	pass


func once_per_wave(key: String) -> bool:
	if _wave_once.has(key):
		return false
	
	_wave_once[key] = true
	return true


func set_monitor(player_index: int, monitor) -> void:
	var old = _monitors.get(player_index)
	if old != null and is_instance_valid(old):
		old.queue_free()
	
	_monitors[player_index] = monitor


func remove_monitor(player_index: int) -> void:
	var monitor = _monitors.get(player_index)
	if monitor != null and is_instance_valid(monitor):
		monitor.queue_free()
	
	_monitors.erase(player_index)


func _on_desert_rose_wave_start(player) -> void:
	_main = RunData.get_tree().current_scene


func connect_safely(obj, signal_name: String, target, call_back: String, binds: Array = []) -> void:
	if obj == null or not is_instance_valid(obj) or obj.is_connected(signal_name, target, call_back):
		return
	
	_connections_list.push_back([obj, signal_name, target, call_back])
	
	if binds.size() == 0:
		var _error = obj.connect(signal_name, target, call_back)
	else:
		var _error = obj.connect(signal_name, target, call_back, binds)


func disconnect_safely(obj, signal_name: String, target, call_back: String) -> void:
	if obj == null or not is_instance_valid(obj) or not obj.is_connected(signal_name, target, call_back):
		return
	
	for i in range(_connections_list.size()):
		var connection = _connections_list[i]
		if obj == connection[0] and signal_name == connection[1] and target == connection[2] and call_back == connection[3]:
			_connections_list.remove(i)
			break
	
	obj.disconnect(signal_name, target, call_back)


func _disconnect_all() -> void:
	for connection in _connections_list.duplicate():
		disconnect_safely(connection[0], connection[1], connection[2], connection[3])
	
	_connections_list.clear()


func get_colored_text_by_value(val, base_val, format: String = "%s") -> Array:
	if val < base_val:
		return [("[color=#" + ProgressData.settings.color_negative + "]" + format + "[/color]") % val, -1]
	else:
		if val >= 0:
			return [("[color=#" + ProgressData.settings.color_positive + "]" + format + "[/color]") % val, 1]
		else:
			return [("[color=#" + ProgressData.settings.color_positive + "]" + format + "[/color]") % val, -1]


func get_colored_text_by_sign(text: String, isign: int = 0) -> String:
	if isign == 0:
		return "[color=white]%s[/color]" % text
	elif isign == 1:
		return "[color=#" + ProgressData.settings.color_positive + "]%s[/color]" % text
	else:
		return "[color=#" + ProgressData.settings.color_negative + "]%s[/color]" % text
