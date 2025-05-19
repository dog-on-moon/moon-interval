@tool
extends Event
class_name RouterBase
## Base class for routers.
## Ensure you override is_in_graph_dropdown for subclasses.

var chosen_branch := 0

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(func (): chosen_branch = 0),
		Func.new(done.emit)
	])

func get_branch_count() -> int:
	return 1

static func get_graph_node_title() -> String:
	return "Router: Base"

static func is_in_graph_dropdown() -> bool:
	return false

#region Branching Logic
func get_branch_names() -> Array:
	var base_list := super()
	for i in get_branch_count():
		base_list.append("Choice #%s" % (i + 1))
	return base_list

func get_branch_index() -> int:
	return chosen_branch
#endregion

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Control"

static func get_graph_node_color() -> Color:
	return Color.CORNFLOWER_BLUE

func _editor_make_node_controls() -> bool:
	return false

func _editor_flatten_default_label() -> bool:
	return false
#endregion
