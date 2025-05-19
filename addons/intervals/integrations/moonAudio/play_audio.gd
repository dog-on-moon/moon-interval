@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name PlayAudio
## An Interval audio event call.

var audio_event: AudioEvent = null
var volume_db := 0.0
var pitch_scale := 1.0
var positional_parent: Node = null

func _init(_audio_event: AudioEvent, _volume_db := 0.0, _pitch_scale := 1.0, _positional_parent: Node = null) -> void:
	audio_event = _audio_event
	volume_db = _volume_db
	pitch_scale = _pitch_scale
	positional_parent = _positional_parent

func _onto_tween(_owner: Node, tween: Tween):
	tween.tween_callback(_play_sound.bind(_owner))

func _play_sound(_owner: Node):
	if not audio_event:
		return
	var aae := audio_event.play(_owner, positional_parent)
	aae.volume_db = volume_db
	aae.pitch_scale = pitch_scale
