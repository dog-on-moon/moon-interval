@icon("res://addons/intervals/icons/interval_container.png")
extends IntervalContainer
class_name SequenceRandom
## An IntervalContainer that plays its contents in a random order.

func _onto_tween(_owner: Node, tween: Tween):
	if not intervals:
		return
	var subtween := _owner.create_tween()
	var ivals := intervals.duplicate()
	ivals.shuffle()
	ivals[0]._onto_tween(_owner, subtween)
	for ival in ivals.slice(1):
		ival._onto_tween(_owner, subtween)
	tween.tween_subtween(subtween)
