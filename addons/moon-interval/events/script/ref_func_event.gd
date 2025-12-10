@tool
extends Event
class_name RefFuncEvent
## Calls a function on a node stored in state.

@export var node_name_in_state := &""

## If the reference stored in State is an array, then you can reference
## a specific node to call the function name on with an index.
## Otherwise, the function will be called on every node in the inventory.
@export var use_indexing := false:
	set(x):
		use_indexing = x
		notify_property_list_changed()

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
			elif value is NodePath:
				nodes.append(_state['EventPlayer'].get_node(value))
		else:
			nodes.append_array(value)
	elif value is NodePath:
		nodes.append(_state['EventPlayer'].get_node(value))
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

func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint(): return
	if property.name == &"node_index":
		if not use_indexing:
			property.usage ^= PROPERTY_USAGE_EDITOR
