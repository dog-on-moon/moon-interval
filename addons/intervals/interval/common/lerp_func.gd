@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name LerpFunc
## An Interval function call, calling a function over time.

var method: Callable
var duration: float
var from: Variant
var to: Variant
var ease: Tween.EaseType
var trans: Tween.TransitionType

func _init(p_method: Callable = _do_nothing,
		p_duration := 0.0,
		p_from: Variant = null,
		p_to: Variant = null,
		p_ease := Tween.EASE_IN_OUT,
		p_trans := Tween.TRANS_LINEAR) -> void:
	method = p_method
	duration = p_duration
	from = p_from
	to = p_to
	ease = p_ease
	trans = p_trans

func values(from: Variant = null, relative := false) -> LerpFunc:
	self.from = from
	self.relative = relative
	return self

func interp(ease := Tween.EASE_IN_OUT, trans := Tween.TRANS_LINEAR) -> LerpFunc:
	self.ease = ease
	self.trans = trans
	return self

func _onto_tween(_owner: Node, tween: Tween):
	tween.tween_method(method, from, to, duration).set_ease(ease).set_trans(trans)

static func _do_nothing(_x = null):
	pass

func get_duration() -> float:
	return duration
