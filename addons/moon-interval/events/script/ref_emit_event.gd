@tool
extends Event
class_name RefEmitEvent
## Emits a signal on a node stored in state.

@export var node_name_in_state := &""
@export var use_indexing := false
@export var node_index := 0
@export var signal_name: String = ""
@export var args: Array = []

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var nodes: Array = []
	var value = _state[node_name_in_state]
	if value is Node:
		nodes.append(value)
	elif value is Array:
		if use_indexing:
			value = value[node_index]
			if value is Node:
				nodes.append(value)
			elif value is Array:
				nodes.append_array(value)
		else:
			nodes.append_array(value)
	else:
		assert(false)
	
	var ivals: Array[Interval] = []
	for node: Node in nodes:
		assert(node.has_signal(signal_name))
		var s: Signal = node[signal_name]
		ivals.append(Func.new(s.emit.bindv(args)))
	
	return Sequence.new([
		Parallel.new(ivals),
		Func.new(done.emit)
	])

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Script"

static func get_graph_node_title() -> String:
	return "(State) Signal"

static func get_graph_node_color() -> Color:
	return FuncEvent.get_graph_node_color()

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	var displayed_name := node_name_in_state + "[%s]" % node_index if use_indexing else node_name_in_state
	return "Emitting %s.%s(%s)" % [displayed_name, signal_name, args]
#endregion
