@tool
extends Event
class_name EndMultiEvent
## A special event that instantly terminates a MultiEvent.

#region Branching Logic
func get_branch_names() -> Array[String]:
	return []
#endregion

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Meta"

static func get_graph_node_title() -> String:
	return "MultiEvent End"

static func get_graph_node_color() -> Color:
	return MultiEvent.get_graph_node_color()
#endregion
