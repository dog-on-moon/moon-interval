@tool
@icon("res://addons/moon-interval/icons/sequence_node.png")
extends IntervalContainerNode
class_name SequenceNode

func as_interval() -> Interval:
	return Sequence.new(_get_children_intervals())

func get_interval_node_start_time(interval_node: IntervalNode) -> float:
	var curr := 0.0
	for child in _get_children_interval_nodes():
		if child == interval_node:
			return curr
		curr += child.get_duration()
	return curr

static func _get_editor_button_tint() -> Color:
	return Color(0.5963, 0.8362, 0.89, 1.0)
