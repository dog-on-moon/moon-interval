@tool
@icon("res://addons/moon-interval/icons/parallel_node.png")
extends IntervalContainerNode
class_name ParallelNode

func as_interval() -> Interval:
	return Parallel.new(_get_children_intervals())
