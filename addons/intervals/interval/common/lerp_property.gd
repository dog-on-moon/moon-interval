@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name LerpProperty
## An Interval property lerp, changing a property's values over time.
##
## This interval can change the property of any target Object over time.
## It is quite bulky to call with .new, you can chain with setup/values/interp instead.

var object: Object
var property: NodePath
var duration: float
var final_val: Variant
var from: Variant
var relative: bool
var ease: Tween.EaseType
var trans: Tween.TransitionType
var custom_interpolator: Callable

func _init(p_object: Object = null,
		p_property: NodePath = ^"",
		p_duration := 0.0,
		p_final_val: Variant = null,
		p_from: Variant = null,
		p_relative: bool = false,
		p_ease := Tween.EASE_IN_OUT,
		p_trans := Tween.TRANS_LINEAR,
		p_custom_interpolator: Callable = _do_nothing) -> void:
	object = p_object
	property = p_property
	duration = p_duration
	final_val = p_final_val
	from = p_from
	relative = p_relative
	ease = p_ease
	trans = p_trans
	custom_interpolator = p_custom_interpolator

static func setup(object: Object = null, property: NodePath = ^"", duration := 0.0, final_val: Variant = null) -> LerpProperty:
	return LerpProperty.new(object, property, duration, final_val)

func values(from: Variant = null, relative := false) -> LerpProperty:
	self.from = from
	self.relative = relative
	return self

func interp(ease := Tween.EASE_IN_OUT, trans := Tween.TRANS_LINEAR) -> LerpProperty:
	self.ease = ease
	self.trans = trans
	return self

func _onto_tween(_owner: Node, tween: Tween):
	var property_tweener := tween.tween_property(object, property, final_val, duration)\
	.set_ease(ease).set_trans(trans)
	if relative:
		property_tweener.as_relative()
	if from != null:
		property_tweener.from(from)
	if custom_interpolator != _do_nothing:
		property_tweener.set_custom_interpolator(custom_interpolator)

static func _do_nothing(_x = null):
	pass

func get_duration() -> float:
	return duration
