@tool
@icon("res://addons/moon-interval/icons/sequence_node.png")
extends IntervalContainerNode
class_name SequenceNode

func as_interval() -> Interval:
	return Sequence.new(_get_children_intervals())
