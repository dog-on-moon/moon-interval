@icon("res://addons/moon-interval/icons/interval_container.png")
extends Interval
class_name IntervalContainer
## Base class for interval containers.
## 
## Interval containers store and playback multiple Intervals.
## They can be used to arrange multiple Intervals together.

var intervals: Array

func _init(p_intervals: Array = []) -> void:
	intervals = p_intervals

func get_duration() -> float:
	var d := 0.0
	for x: Interval in intervals:
		d += x.get_duration()
	return d
