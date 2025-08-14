@icon("res://addons/moon-interval/icons/interval.png")
extends Interval
class_name LerpShaderGlobal

var shader_global: StringName
var duration: float
var from: Variant
var to: Variant
var ease: Tween.EaseType
var trans: Tween.TransitionType

func _init(p_shader_global: StringName = &"",
		p_duration := 0.0,
		p_from: Variant = null,
		p_to: Variant = null,
		p_ease := Tween.EASE_IN_OUT,
		p_trans := Tween.TRANS_LINEAR) -> void:
	shader_global = p_shader_global
	duration = p_duration
	from = p_from
	to = p_to
	ease = p_ease
	trans = p_trans

func values(from: Variant = null, relative := false) -> LerpShaderGlobal:
	self.from = from
	self.relative = relative
	return self

func interp(ease := Tween.EASE_IN_OUT, trans := Tween.TRANS_LINEAR) -> LerpShaderGlobal:
	self.ease = ease
	self.trans = trans
	return self

func _onto_tween(_owner: Node, tween: Tween):
	tween.tween_method(_set_shader_global, from, to, duration).set_ease(ease).set_trans(trans)

func _set_shader_global(x: Variant):
	RenderingServer.global_shader_parameter_set_override(shader_global, x)

func get_duration() -> float:
	return duration
