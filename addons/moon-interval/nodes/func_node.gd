@tool
@icon("res://addons/moon-interval/icons/func_node.png")
extends IntervalNode
class_name FuncNode
## Calls a func on a node.

## The target node to set a property on.
@export var node: Node:
	set(x):
		node = x
		notify_property_list_changed()

## The property to modify on the ascribed node.
@export var function: StringName:
	set(x):
		function = x
		notify_property_list_changed()

@export var arguments: Array

@warning_ignore("unused_private_class_variable")
@export_tool_button("Set Function", "MemberProperty") var _editor_set := _editor_callback

func as_interval() -> Interval:
	if not node or not node.has_method(function):
		return Wait.new()
	
	# don't queue_free in the editor ...
	# you probably won't like this
	if Engine.is_editor_hint():
		if function == &"queue_free":
			return Wait.new(0.0)
	
	var f: Callable = node[function]
	return Func.new(f.bindv(arguments))

func get_auto_name() -> String:
	return "Func-%s-%s" % [node.name, function]

#region Editor API

func _editor_callback():
	if not node:
		Engine.get_singleton(&"EditorInterface").popup_node_selector(_editor_node_result, [&"Node"], self)
		return
	
	Engine.get_singleton(&"EditorInterface").popup_method_selector(node, _editor_callback_result)

func _editor_callback_result(f: String):
	if node:
		function = StringName(f)

func _editor_node_result(np: NodePath):
	node = get_tree().edited_scene_root.get_node_or_null(np)
	if not node:
		Engine.get_singleton(&"EditorInterface").get_editor_toaster().push_toast("Can not pop up function editor (node is unset)", Engine.get_singleton(&"EditorInterface").get_editor_toaster().SEVERITY_ERROR)
	else:
		_editor_callback()

#endregion

func _validate_property(p: Dictionary) -> void:
	super(p)
	
	if Engine.is_editor_hint():
		if p.name == &"function":
			p.usage ^= PROPERTY_USAGE_READ_ONLY
