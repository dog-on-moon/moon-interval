@tool
extends Event
class_name EventRef
## Performs an event by reference.

@export var event: Event

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	event.done.connect(done.emit, CONNECT_ONE_SHOT)
	return event._get_interval(_owner, _state)

#region Branching Logic
func get_branch_names() -> Array[String]:
	return event.get_branch_names() if event else super()

func get_branch_index() -> int:
	return event.get_branch_index() if event else super()
#endregion

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Meta"

static func get_graph_node_title() -> String:
	return "Event Reference"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return (
		"[b]%s[/b]\n%s" % [event.to_string(), event.get_graph_node_description(_edit, _element)]
	) if event else ("[color=red]No Reference")

static func get_graph_node_color() -> Color:
	return Color.DIM_GRAY
#endregion
