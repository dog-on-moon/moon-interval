@tool
extends RouterBase
class_name RouterFuncBool
## A routing event that calls a function and routes based on a boolean result.

@export_node_path("Node") var node_path: NodePath = ^"":
	set(x):
		node_path = x
		if _script_button and is_instance_valid(_script_button):
			_script_button.visible = _editor_script_exists()
@export var function_name: String = "":
	set(x):
		function_name = x
		if _script_button and is_instance_valid(_script_button):
			_script_button.visible = _editor_script_exists()
@export var args: Array = []

var _script_button: Button = null
var _editor_owner: Node = null

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	assert(function_name in node)
	var callable: Callable = node[function_name]
	
	return Sequence.new([
		Func.new(func ():
			if callable.call():
				chosen_branch = 0
			else:
				chosen_branch = 1
			),
		Func.new(done.emit)
	])

func get_branch_count() -> int:
	return 2

static func get_graph_node_title() -> String:
	return "Router: FuncBool"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return ("%s.%s(%s)" % [
		get_node_path_string(_editor_owner, node_path), function_name,
		str(args).trim_prefix('[').trim_suffix(']')]
	) if _editor_script_exists() else ("[b][color=red]Invalid Callable")

static func is_in_graph_dropdown() -> bool:
	return true

func _editor_make_node_controls() -> bool:
	return true

#region Branching Logic
func get_branch_names() -> Array:
	var base_list: Array[String] = ["True", "False"]
	return base_list

func get_branch_index() -> int:
	return chosen_branch
#endregion

#region Base Editor Overrides

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_editor_owner = get_editor_owner(_edit)
	_script_button = FuncEvent._editor_make_script_button(
		func (): return FuncEvent._editor_get_target_node(node_path, _editor_owner),
		func (): return _editor_get_substring(),
		_element,
		preload("uid://bjbo1hnbusobl")
	)
#endregion

#region Script Search Logic
func _editor_script_exists() -> bool:
	return FuncEvent._editor_find_node_script(
		_editor_get_substring(),
		FuncEvent._editor_get_target_node(node_path, _editor_owner)
	)

func _editor_get_substring():
	return "func %s(" % function_name

#endregion
