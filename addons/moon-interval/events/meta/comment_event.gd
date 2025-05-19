@tool
extends Event
class_name CommentEvent
## Displays a comment in the event editor, but otherwise has no logic.

@export_multiline var msg := ""

static func get_graph_dropdown_category() -> String:
	return "Meta"

static func get_graph_node_title() -> String:
	return "Comment"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return msg

func get_input_connections() -> int:
	return 0

func get_output_connections() -> int:
	return 0
