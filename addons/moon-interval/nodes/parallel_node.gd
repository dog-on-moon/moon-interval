@tool
@icon("res://addons/moon-interval/icons/parallel_node.png")
extends IntervalContainerNode
class_name ParallelNode

func as_interval() -> Interval:
	return Parallel.new(_get_children_intervals())

func get_interval_node_start_time(interval_node: IntervalNode) -> float:
	return 0.0

static func _get_editor_button_tint() -> Color:
	return Color(0.7475, 0.6141, 0.89, 1.0)
