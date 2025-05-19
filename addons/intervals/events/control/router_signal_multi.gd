@tool
extends RouterBase
class_name RouterSignalMulti
## A signal multiplexor for routers.
## The first emitted signal will use that branch.

@export var signal_count := 2:
	set(x):
		signal_count = x
		node_paths.resize(signal_count)
		signal_names.resize(signal_count)
		notify_property_list_changed()

@export_storage var node_paths: Array[NodePath] = [^"", ^""]
@export_storage var signal_names: Array[StringName] = [&"", &""]

var _editor_owner: Node

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(_clear_signals.bind(_owner)),
		Func.new(_setup_signals.bind(_owner))
	])

func _setup_signals(_owner: Node):
	for idx in range(1, get_branch_count() + 1):
		var np = get(&"node_path_%s" % idx)
		var signal_name = get(&"signal_name_%s" % idx)
		if np:
			var node: Node = _owner.get_node_or_null(np)
			if node:
				if node.has_signal(signal_name) or node.has_user_signal(signal_name):
					node.connect(signal_name, _on_signal.bind(_owner, idx), CONNECT_ONE_SHOT)

func _clear_signals(_owner: Node):
	for idx in range(1, get_branch_count() + 1):
		var np = get(&"node_path_%s" % idx)
		var signal_name = get(&"signal_name_%s" % idx)
		if np:
			var node: Node = _owner.get_node_or_null(np)
			if node:
				var callable := _on_signal.bind(_owner, idx)
				if node.is_connected(signal_name, callable):
					node.disconnect(signal_name, callable)

func _on_signal(_owner: Node, idx: int):
	_clear_signals(_owner)
	chosen_branch = idx
	done.emit()

func get_branch_count() -> int:
	return signal_count

static func get_graph_node_title() -> String:
	return "Router: Signal Multiplex"

static func is_in_graph_dropdown() -> bool:
	return true

#region Branching Logic
func get_branch_names() -> Array:
	var base_list: Array[String] = ["Default"]
	for idx in range(1, get_branch_count() + 1):
		var np = get(&"node_path_%s" % idx)
		var signal_name = get(&"signal_name_%s" % idx)
		var branch_name := "node undefined-%s" % idx
		if np:
			var node: Node = _editor_owner.get_node_or_null(np)
			if node:
				if not node.has_signal(signal_name) and not node.has_user_signal(signal_name):
					branch_name = "signal undefined-%s" % idx
				else:
					branch_name = "On %s.%s()" % [node.name, signal_name]
		base_list.append(branch_name)
	return base_list

func get_branch_index() -> int:
	return chosen_branch

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_editor_owner = get_editor_owner(_edit)
	# print(get_property_list())
#endregion

#region Property Logic
func _get_property_list() -> Array[Dictionary]:
	var ret_list: Array[Dictionary] = []
	
	for i in signal_count:
		var idx := i + 1
		ret_list.append({
			"name": "Signal #%s" % idx,
			"class_name": &"",
			"type": 0,
			"hint": 0,
			"hint_string": "",
			"usage": 64
		})
		ret_list.append({
			"name": "node_path_%s" % idx,
			"class_name": &"",
			"type": 22,
			"hint": 0,
			"hint_string": "",
			"usage": 4102
		})
		ret_list.append({
			"name": "signal_name_%s" % idx,
			"class_name": &"",
			"type": 21,
			"hint": 0,
			"hint_string": "",
			"usage": 4102
		})
	
	"""
	{ "name": "Signal #1", "class_name": &"", "type": 0, "hint": 0, "hint_string": "", "usage": 128 }
	{ "name": "node_path_1", "class_name": &"", "type": 22, "hint": 0, "hint_string": "", "usage": 4102 },
	{ "name": "signal_name_1", "class_name": &"", "type": 21, "hint": 0, "hint_string": "", "usage": 4102 }
	"""
	
	return ret_list

func _property_can_revert(property: StringName) -> bool:
	return property.begins_with("node_path_") or property.begins_with("signal_name_")

func _property_get_revert(property: StringName) -> Variant:
	if property.begins_with("node_path_"):
		return ^""
	if property.begins_with("signal_name_"):
		return &""
	return null

func _get(property):
	if property.begins_with("node_path_"):
		var index = property.get_slice("_", 2).to_int() - 1
		return node_paths[index]
	if property.begins_with("signal_name_"):
		var index = property.get_slice("_", 2).to_int() - 1
		return signal_names[index]

func _set(property, value):
	if property.begins_with("node_path_"):
		var index = property.get_slice("_", 2).to_int() - 1
		node_paths[index] = value
		return true
	if property.begins_with("signal_name_"):
		var index = property.get_slice("_", 2).to_int() - 1
		signal_names[index] = value
		return true
	return false
#endregion
