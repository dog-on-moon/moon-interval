@tool
@icon("res://addons/moon-interval/icons/play_audio_node.png")
extends IntervalNode
class_name PlayAudioNode
## Calls an AudioEvent.

## Sets the audio event used for playback at this step.
@export var audio_event: AudioEvent = null:
	set(x):
		audio_event = x
		update_configuration_warnings()

## Sets the volume used on this event.
@export var volume_db := 0.0

## Sets the pitch scale of this event.
@export var pitch_scale := 1.0

## Targets a node for positional properties.
## Generally required for 2D/3D audio events.
@export var positional_parent: Node = null:
	set(x):
		positional_parent = x
		update_configuration_warnings()

func as_interval() -> Interval:
	return PlayAudio.new(audio_event, volume_db, pitch_scale, positional_parent)

func _get_configuration_warnings() -> PackedStringArray:
	if audio_event.positional != AudioEvent.Positional.Off:
		if not positional_parent:
			return PackedStringArray(["Positional parent is required to be set on this node."])
		return PackedStringArray()
	else:
		return PackedStringArray()
