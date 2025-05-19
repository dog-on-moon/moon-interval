@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name Func
## An Interval function call.

var method: Callable

func _init(p_method: Callable) -> void:
	method = p_method

func _onto_tween(_owner: Node, tween: Tween):
	tween.tween_callback(method)
