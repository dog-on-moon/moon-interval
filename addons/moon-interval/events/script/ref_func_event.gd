@tool
extends Event
class_name RefFuncEvent
## Calls a function on a node stored in state.

@export var node_name_in_state := &""
@export var use_indexing := false
@export var node_index := 0
@export var function_name: String = ""
@export var args: Array = []

@export var blocking := false

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
	
	if blocking:
		var remaining := nodes.size()
		var ivals: Array[Interval] = []
		for node: Node in nodes:
			assert(node.has_method(function_name))
			var c: Callable = node[function_name]
			ivals.append(Func.new(
				func ():
					await c.callv(args)
					remaining -= 1
					if remaining == 0:
						done.emit()
			))
		return Parallel.new(ivals)
	else:
		var ivals: Array[Interval] = []
		for node: Node in nodes:
			assert(node.has_method(function_name))
			var c: Callable = node[function_name]
			ivals.append(Func.new(c.bindv(args)))
		
		return Sequence.new([
			Parallel.new(ivals),
			Func.new(done.emit)
		])

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Script"

static func get_graph_node_title() -> String:
	return "(State) Callable"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	var displayed_name := node_name_in_state + "[%s]" % node_index if use_indexing else node_name_in_state
	return ("%s.%s(%s)%s" % [
		displayed_name, function_name,
		str(args).trim_prefix('[').trim_suffix(']'),
		"\n(Blocking)" if blocking else ""
		]
	)

static func get_graph_node_color() -> Color:
	return FuncEvent.get_graph_node_color()
#endregion
