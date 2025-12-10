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

func append(ival: Interval):
	intervals.append(ival)

func get_duration() -> float:
	var d: float = 0.0
	for i: Interval in intervals:
		d += i.get_duration()
	return d

## Sets the interp of child containers.
func interp(ease := Tween.EASE_IN_OUT, trans := Tween.TRANS_LINEAR) -> IntervalContainer:
	for i: Interval in intervals:
		if i.has_method(&"interp"):
			i.call(&"interp", ease, trans)
	return self
