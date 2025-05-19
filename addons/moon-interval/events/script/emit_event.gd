@tool
extends SignalEvent
class_name EmitEvent
## An event that emits a signal immediately.

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	return Sequence.new([
		Func.new(node.emit_signal.bind(signal_name)),
		Func.new(done.emit)
	])


#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Script"

static func get_graph_node_title() -> String:
	return "Signal"

static func get_graph_node_color() -> Color:
	return FuncEvent.get_graph_node_color()
#endregion

func _get_editor_description_prefix() -> String:
	return "Emitting"
