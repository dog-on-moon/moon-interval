@icon("res://addons/intervals/icons/interval_container.png")
extends IntervalContainer
class_name Sequence
## An IntervalContainer that plays all of its elements ordered, one by one.

func _onto_tween(_owner: Node, tween: Tween):
	if not intervals:
		return
	var subtween := _owner.create_tween()
	intervals[0]._onto_tween(_owner, subtween)
	for ival in intervals.slice(1):
		ival._onto_tween(_owner, subtween)
	tween.tween_subtween(subtween)
