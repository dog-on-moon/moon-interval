@tool
@icon("res://addons/moon-interval/icons/play_audio_node.png")
extends IntervalNode
class_name PlayFmodNode
## Calls an Fmod event.

## The fmod event GUID.
@export var guid_fmod := ""

## Parameters applied onto the start of the event.
@export var parameters := {}

## Determines if this fmod event is played in 3D.
@export var in_3d := false:
	set(x):
		in_3d = x
		notify_property_list_changed()

## The global transform used when the event playback starts.
@export var node: Node3D

func as_interval() -> Interval:
	return PlayFmod.new(guid_fmod, parameters, in_3d, node.global_transform if node else Transform3D.IDENTITY)

func _validate_property(property: Dictionary) -> void:
	if Engine.is_editor_hint():
		if property.name == &"node" and not in_3d:
			property.usage ^= PROPERTY_USAGE_EDITOR
