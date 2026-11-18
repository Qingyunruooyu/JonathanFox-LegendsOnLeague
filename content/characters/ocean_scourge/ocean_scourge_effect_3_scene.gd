extends Node2D


onready var _tween = $Tween
onready var _sprite = $Sprite

var _duration: = 5.0


func init(duration = 5.0):
	_duration = duration


func _ready():
	_tween.interpolate_property(_sprite, "scale", Vector2(0.5, 0.5), Vector2(1, 1), _duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tween.interpolate_property(_sprite, "modulate", Color.white, Color.red, _duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tween.start()


func _on_Tween_tween_all_completed():
	queue_free()
