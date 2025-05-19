@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name Connect
## Connects a method to a signal.

var _signal: Signal
var method: Callable
var flags: int

func _init(p_signal: Signal, p_method: Callable, p_flags := 0) -> void:
	_signal = p_signal
	method = p_method
	flags = p_flags

func _onto_tween(_owner: Node, tween: Tween):
	tween.tween_callback(_signal.connect.bind(method, flags))
