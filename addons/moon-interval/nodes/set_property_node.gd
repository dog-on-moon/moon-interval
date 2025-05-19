@tool
@icon("res://addons/moon-interval/icons/set_property_node.png")
extends IntervalNode
class_name SetPropertyNode
## Sets a property on a node.

## The target node to set a property on.
@export var node: Node:
	set(x):
		node = x
		notify_property_list_changed()

## The property to modify on the ascribed node.
@export var property: StringName:
	set(x):
		property = x
		
		if is_node_ready() and Engine.is_editor_hint():
			value = node.get_indexed(NodePath(property))
		
		notify_property_list_changed()

@export_custom(PROPERTY_HINT_NONE, "") var value

@warning_ignore("unused_private_class_variable")
@export_tool_button("Set Property", "MemberProperty") var _editor_set := _editor_property

func as_interval() -> Interval:
	return SetProperty.new(node, StringName(NodePath(property).get_subname(0)), value)

#region Editor API

func _editor_property():
	if not node:
		EditorInterface.popup_node_selector(_editor_node_result, [&"Node"], self)
		return
	
	EditorInterface.popup_property_selector(node, _editor_property_result)

func _editor_property_result(np: NodePath):
	if node:
		property = StringName(":" + String(np.get_subname(0)))

func _editor_node_result(np: NodePath):
	node = get_tree().edited_scene_root.get_node_or_null(np)
	if not node:
		EditorInterface.get_editor_toaster().push_toast("Can not pop up property editor (node is unset)", EditorToaster.SEVERITY_ERROR)
	else:
		_editor_property()

#endregion

func _validate_property(p: Dictionary) -> void:
	super(p)
	
	if node and property and p.name == &"value":
		p.type = typeof(node.get_indexed(NodePath(property)))
	
	if Engine.is_editor_hint():
		if p.name == &"property":
			p.usage ^= PROPERTY_USAGE_READ_ONLY
		
		if p.name == &"value":
			if not (node and property):
				p.usage ^= PROPERTY_USAGE_EDITOR

func _property_can_revert(p: StringName) -> bool:
	return p == &"value"

func _property_get_revert(p: StringName) -> Variant:
	if node and property and p == &"value":
		return node.get_indexed(NodePath(property))
	return null
