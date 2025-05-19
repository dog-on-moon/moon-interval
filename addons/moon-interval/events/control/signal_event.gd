@tool
extends Event
class_name SignalEvent
## An event that emits done after a node's signal has been raised.
## Easy to mix up with EmitEvent (sorry!)

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

var _script_button: Button = null
var _editor_owner: Node = null

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	return Connect.new(node[signal_name], done.emit, CONNECT_ONE_SHOT)

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Control"

static func get_graph_node_title() -> String:
	return "Await Signal"

func _get_editor_description_prefix() -> String:
	return "Awaiting"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return ("%s %s.%s()" % [
		_get_editor_description_prefix(),
		get_node_path_string(_editor_owner, node_path), signal_name
	]) if _editor_signal_exists() else ("[b][color=red]Invalid Signal")

static func get_graph_node_color() -> Color:
	return Color(0.8, 0.545, 0.376, 1.0)

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_editor_owner = get_editor_owner(_edit)
	_script_button = FuncEvent._editor_make_script_button(
		func (): return FuncEvent._editor_get_target_node(node_path, _editor_owner),
		func (): return _editor_get_substring(),
		_element,
		preload("uid://bu4w8hqwh8h3m"),
		_editor_find_node_script
	)
#endregion

#region Script Search Logic
func _editor_script_exists(node: Node = null) -> bool:
	if not _editor_owner or not is_instance_valid(_editor_owner):
		return false
	return _editor_find_node_script(
		_editor_get_substring(),
		node if node else FuncEvent._editor_get_target_node(node_path, _editor_owner)
	)

func _editor_signal_exists() -> bool:
	if not _editor_owner or not is_instance_valid(_editor_owner):
		return false
	var node := FuncEvent._editor_get_target_node(node_path, _editor_owner)
	return node and node.has_signal(signal_name) or _editor_script_exists(node)

func _editor_get_substring():
	return "signal %s" % signal_name

# custom script search function to look for signals more cleanly
static func _editor_find_node_script(substr: String, node: Node, open := false) -> bool:
	if node and node.get_script():
		var lines: PackedStringArray = node.get_script().source_code.split('\n')
		for i in lines.size():
			var line: String = lines[i]
			if line == substr or line.find(substr + "(") != -1:
				if open:
					EditorInterface.set_main_screen_editor("Script")
					EditorInterface.edit_script(node.get_script(), i + 1)
				return true
	return false
#endregion
