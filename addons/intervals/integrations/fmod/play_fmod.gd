@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name PlayFmod
## An Interval fmod event call.

var guid := ""
var parameters := {}
var in_3d := false
var t3d := Transform3D.IDENTITY

func _init(_guid: String, _parameters := {}, _in_3d := false, _transform := Transform3D.IDENTITY) -> void:
	guid = _guid
	parameters = _parameters
	in_3d = _in_3d
	t3d = _transform

func _onto_tween(_owner: Node, tween: Tween):
	tween.tween_callback(_play_sound)

func _play_sound():
	if not guid:
		return
	var e := FmodServer.create_event_instance_with_guid(guid)
	for key in parameters:
		e.set_parameter_by_name(key, parameters[key])
	if in_3d:
		e.set_3d_attributes(t3d)
	e.start()
