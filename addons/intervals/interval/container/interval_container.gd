@icon("res://addons/intervals/icons/interval_container.png")
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
	return DogUtils.sum_array(intervals.map(func(x: Interval): return x.get_duration())) if intervals else 0.0
