extends "res://items/global/effect.gd"


export (bool) var enable_wave_start_signal = true

var _player = null
var _player_index: int = 0
var _main = null


static func get_id() -> String:
	return "dr_effect"


func apply(player_index: int) -> void:
	pass


func serialize() -> Dictionary:
	var serialized = .serialize()
	
	serialized.enable_wave_start_signal = enable_wave_start_signal
	
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	
	if serialized.has("enable_wave_start_signal"):
		enable_wave_start_signal = serialized.enable_wave_start_signal


func unapply(player_index: int) -> void:
	pass


func cleanup(player_index: int) -> void:
	if enable_wave_start_signal:
		if RunData.is_connected("desert_rose_wave_start", self, "_on_desert_rose_wave_start_prefix"):
			RunData.disconnect("desert_rose_wave_start", self, "_on_desert_rose_wave_start_prefix")


func apply_connection(player) -> void:
	_player = player
	if player != null and is_instance_valid(player):
		_player_index = player.player_index
	
	if enable_wave_start_signal:
		if not RunData.is_connected("desert_rose_wave_start", self, "_on_desert_rose_wave_start_prefix"):
			RunData.connect("desert_rose_wave_start", self, "_on_desert_rose_wave_start_prefix")


func _on_desert_rose_wave_start_prefix(player):
	yield(RunData.get_tree().create_timer(0.1), "timeout")
	
	if player and is_instance_valid(player):
		_on_desert_rose_wave_start(player)


func _on_desert_rose_wave_start(player) -> void:
	_player = player
	_player_index = player.player_index


func connect_safely(obj, signal_name: String, target, call_back: String, binds: Array = []) -> void:
	if obj == null or not is_instance_valid(obj) or obj.is_connected(signal_name, target, call_back):
		return
	if binds.size() == 0:
		var _error = obj.connect(signal_name, target, call_back)
	else:
		var _error = obj.connect(signal_name, target, call_back, binds)


func disconnect_safely(obj, signal_name: String, target, call_back: String) -> void:
	if obj == null or not is_instance_valid(obj) or not obj.is_connected(signal_name, target, call_back):
		return
	obj.disconnect(signal_name, target, call_back)


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
