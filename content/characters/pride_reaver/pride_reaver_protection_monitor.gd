extends Node


var _player = null
var _player_index: int = 0
var _duration: float = 0.5
var _bonus_stats: Array = []
var _bonus_stat_hashes: Array = []
var _next_protecting_count: int = 0
var _invincibility_timer = null
var _timer: Timer = null


func init(duration: float, bonus_stats: Array) -> void:
	_duration = duration
	_bonus_stats = bonus_stats


func _ready():
	_player = get_parent()
	_player_index = _player.player_index
	_invincibility_timer = _player._invincibility_timer
	
	_bonus_stat_hashes.clear()
	for stat in _bonus_stats:
		_bonus_stat_hashes.push_back([Keys.generate_hash(stat[0]), stat[1]])
	
	_timer = Timer.new()
	_timer.name = "PrideReaverTimer"
	add_child(_timer)
	_timer.autostart = false
	_timer.one_shot = true
	var _error = _timer.connect("timeout", self, "_on_pride_reaver_timer_timeout")
	
	var _error2 = _player.connect("took_damage", self, "_on_player_took_damage")


func _on_player_took_damage(_unit, _value, _knockback_direction, _is_crit, is_dodge, is_protected, _armor_did_something, _args, _hit_type, _is_one_shot) -> void:
	if is_dodge or is_protected:
		return
	
	_next_protecting_count += 1
	call_deferred("apply_hit_protection")


func apply_hit_protection() -> void:
	if _next_protecting_count > 0:
		_next_protecting_count -= 1
		
		for stat in _bonus_stat_hashes:
			TempStats.add_stat(stat[0], stat[1], _player_index)
		if is_instance_valid(_invincibility_timer):
			_invincibility_timer.start(_duration)
		if is_instance_valid(_timer):
			_timer.start(_duration)


func _on_pride_reaver_timer_timeout() -> void:
	for stat in _bonus_stat_hashes:
		TempStats.remove_stat(stat[0], stat[1], _player_index)
