@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name SetProperty
## An Interval property setter, instantly setting an object's property.

var object: Object
var property: StringName
var value: Variant

func _init(p_object: Object = null,
		p_property: StringName = &"",
		p_value: Variant = null,) -> void:
	object = p_object
	property = p_property
	value = p_value

func _onto_tween(_owner: Node, tween: Tween):
	tween.tween_callback(object.set.bind(property, value))
