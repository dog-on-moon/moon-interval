@tool
@icon("res://addons/moon-interval/icons/interval_container.png")
extends IntervalNode
class_name IntervalContainerNode

func as_interval() -> Interval:
	return IntervalContainer.new(_get_children_intervals())

func _get_children_intervals() -> Array[Interval]:
	var children_nodes: Array[Interval] = []
	for child in get_children():
		if is_instance_of(child, IntervalNode):
			var _in: IntervalNode = child
			if _in.active:
				children_nodes.append(_in.as_interval())
	return children_nodes
