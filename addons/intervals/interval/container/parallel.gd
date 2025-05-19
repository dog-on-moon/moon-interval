@icon("res://addons/intervals/icons/interval_container.png")
extends IntervalContainer
class_name Parallel
## An IntervalContainer that plays all of its elements simultaneously.

func _onto_tween(_owner: Node, tween: Tween):
	if not intervals:
		return
	var subtween := _owner.create_tween()
	subtween.set_parallel(true)
	intervals[0]._onto_tween(_owner, subtween)
	for ival in intervals.slice(1):
		ival._onto_tween(_owner, subtween)
	tween.tween_subtween(subtween)

func get_duration() -> float:
	return intervals.map(func(x: Interval): return x.get_duration()).max() if intervals else 0.0
