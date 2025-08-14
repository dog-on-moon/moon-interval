@tool
@icon("res://addons/moon-interval/icons/track_node.png")
extends IntervalContainerNode
class_name TrackNode

func as_interval() -> Interval:
	var ivals := []
	for inode in _get_children_interval_nodes():
		ivals.append([inode.track_position, inode.as_interval()])
	return TrackInterval.new(ivals)

func get_interval_node_start_time(interval_node: IntervalNode) -> float:
	return interval_node.track_position

static func _get_editor_button_tint() -> Color:
	return Color(0.89, 0.5963, 0.5963, 1.0)
