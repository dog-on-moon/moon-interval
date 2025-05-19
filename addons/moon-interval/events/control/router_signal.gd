@tool
extends RouterBase
class_name RouterSignal
## A routing event that chooses a branch based on an ID a signal emits.

@export_node_path("Node") var node_path: NodePath = ^"":
	set(x):
		node_path = x
		if _script_button and is_instance_valid(_script_button):
			_script_button.visible = _editor_script_exists()
@export var signal_name: StringName = &"":
	set(x):
		signal_name = x
		if _script_button and is_instance_valid(_script_button):
			_script_button.visible = _editor_script_exists()

@export var branches := 2

var _script_button: Button = null
var _editor_owner: Node = null

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	return Connect.new(node[signal_name], func (x):
		chosen_branch = x
		done.emit()
	, CONNECT_ONE_SHOT)

func get_branch_count() -> int:
	return branches

static func get_graph_node_title() -> String:
	return "Router: Signal Result"

static func is_in_graph_dropdown() -> bool:
	return true

#region Base Editor Overrides
func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return ("Awaiting %s.%s()" % [
		get_node_path_string(_editor_owner, node_path), signal_name
	]) if _editor_script_exists() else ("[b][color=red]Invalid Signal")

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_editor_owner = get_editor_owner(_edit)
	_script_button = FuncEvent._editor_make_script_button(
		func (): return FuncEvent._editor_get_target_node(node_path, _editor_owner),
		func (): return _editor_get_substring(),
		_element,
		preload("uid://bu4w8hqwh8h3m"),
		SignalEvent._editor_find_node_script
	)

func _editor_make_node_controls() -> bool:
	return true
#endregion

#region Script Search Logic
func _editor_script_exists() -> bool:
	return SignalEvent._editor_find_node_script(
		_editor_get_substring(),
		FuncEvent._editor_get_target_node(node_path, _editor_owner)
	)

func _editor_get_substring():
	return "signal %s" % signal_name
#endregion
