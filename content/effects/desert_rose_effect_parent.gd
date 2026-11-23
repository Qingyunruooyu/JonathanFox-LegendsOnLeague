extends "res://items/global/effect.gd"


export (bool) var enable_wave_start_signal = true

var _player = null
var _player_index: int = 0
var _main = null
var _owner_pids: Array = []
var _wave_once: Dictionary = {}
var _connections_list: Array = []
var _monitors: Dictionary = {}


static func get_id() -> String:
	return "dr_effect"


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.enable_wave_start_signal = enable_wave_start_signal
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("enable_wave_start_signal"):
		enable_wave_start_signal = serialized.enable_wave_start_signal


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
		
		if enable_wave_start_signal:
			if RunData.is_connected("desert_rose_wave_start", self, "_on_desert_rose_wave_start_prefix"):
				RunData.disconnect("desert_rose_wave_start", self, "_on_desert_rose_wave_start_prefix")
		
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
	
	_player = player
	if player != null and is_instance_valid(player):
		_player_index = player.player_index
		if not _owner_pids.has(_player_index):
			_owner_pids.push_back(_player_index)
	
	if enable_wave_start_signal:
		if not RunData.is_connected("desert_rose_wave_start", self, "_on_desert_rose_wave_start_prefix"):
			RunData.connect("desert_rose_wave_start", self, "_on_desert_rose_wave_start_prefix")


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


func _on_desert_rose_wave_start_prefix(player):
	if player == null or not is_instance_valid(player):
		return
	if player.player_index != _player_index:
		return
	yield(RunData.get_tree().create_timer(0.1), "timeout")
	
	if player and is_instance_valid(player):
		_on_desert_rose_wave_start(player)


func _on_desert_rose_wave_start(player) -> void:
	_player = player
	_player_index = player.player_index
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
		return [("[color=red]" + format + "[/color]") % val, -1]
	else:
		if val >= 0:
			return [("[color=#00ff00]" + format + "[/color]") % val, 1]
		else:
			return [("[color=#00ff00]" + format + "[/color]") % val, -1]


func get_colored_text_by_sign(text: String, isign: int = 0) -> String:
	if isign == 0:
		return "[color=white]%s[/color]" % text
	elif isign == 1:
		return "[color=#00ff00]%s[/color]" % text
	else:
		return "[color=red]%s[/color]" % text
