@tool
extends Event
class_name PrintEvent
## Prints out a message into the output.

@export_multiline var msg := ""
@export var enabled := true

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(print_rich.bind(msg)),
		Func.new(done.emit)
	]) if enabled else Func.new(done.emit)

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Meta"

static func get_graph_node_title() -> String:
	return "Print to Console"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return ("[color=ff6666][s]" if not enabled else "") + (msg if msg else "[color=red][b][No Message]")
#endregion
