extends Node2D


signal spread_ready(targets)


var _targets_in_range: = []
var _max_targets: = 3


func init(max_targets = 3)->void :
	_max_targets = max_targets


func _on_DetactArea_body_entered(body):
	if not body == get_parent():
		_targets_in_range.push_back(body)


func _on_DetactArea_body_exited(body):
	if not body == get_parent():
		_targets_in_range.erase(body)


func _on_Timer_timeout():
	var targets:Array = []
	if _targets_in_range.size() > _max_targets:
		for i in _max_targets:
			var target_array = Utils.get_nearest(_targets_in_range, global_position)
			
			if not target_array.empty():
				var target = target_array[0]
				_targets_in_range.erase(target)
				if target and is_instance_valid(target):
					targets.push_back(target)
	else:
		targets = _targets_in_range
	
	if not targets.empty():
		emit_signal("spread_ready", targets)
	
	call_deferred("queue_free")
