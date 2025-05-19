@tool
@icon("res://addons/moon-interval/icons/lerp_property_node.png")
extends IntervalNode
class_name LerpPropertyNode
## Interpolates a property, framed as a node.

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
			start_value = node.get_indexed(NodePath(property))
			value = node.get_indexed(NodePath(property))
		
		notify_property_list_changed()

@warning_ignore("unused_private_class_variable")
@export_tool_button("Set Property", "MemberProperty") var _editor_set := _editor_property

@export_category("Animation")
@export_custom(PROPERTY_HINT_NONE, "") var start_value
@export_custom(PROPERTY_HINT_NONE, "") var value
@export_range(0.0, 8.0, 0.01, "or_greater") var duration := 0.0
@export var ease := Tween.EASE_IN_OUT
@export var trans := Tween.TRANS_LINEAR

@export_flags("Has Start:1", "Relative:2") var flags := 0:
	set(x):
		flags = x
		notify_property_list_changed()

func as_interval() -> Interval:
	return LerpProperty.new(node, NodePath(property), duration, value, start_value if flags & 1 else null, flags & 2, ease, trans)

func reset():
	if node and flags & 1:
		node.set_indexed(NodePath(property), start_value)

#region Editor API

func _editor_property():
	if not node:
		EditorInterface.popup_node_selector(_editor_node_result, [&"Node"], self)
		return
	
	EditorInterface.popup_property_selector(node, _editor_property_result)

func _editor_property_result(np: NodePath):
	if node:
		property = StringName(np)

func _editor_node_result(np: NodePath):
	node = get_tree().edited_scene_root.get_node_or_null(np)
	if not node:
		EditorInterface.get_editor_toaster().push_toast("Can not pop up property editor (node is unset)", EditorToaster.SEVERITY_ERROR)
	else:
		_editor_property()

#endregion

func _validate_property(p: Dictionary) -> void:
	super(p)
	
	if node and property:
		if p.name == &"start_value" or p.name == &"value":
			p.type = typeof(node.get_indexed(NodePath(property)))
	else:
		if p.name == &"value" or p.name == &"start_value" or p.name == &"duration" or p.name == &"ease" or p.name == &"trans" or p.name == &"flags" or p.name == &"Animation":
			p.usage = 0
		return
	
	if Engine.is_editor_hint():
		if p.name == &"property":
			p.usage ^= PROPERTY_USAGE_READ_ONLY
		
		if p.name == &"start_value" and not flags & 1:
			p.usage ^= PROPERTY_USAGE_EDITOR

func _property_can_revert(p: StringName) -> bool:
	return p == &"start_value" or p == &"value"

func _property_get_revert(p: StringName) -> Variant:
	if node and NodePath(property):
		if p == &"value":
			return null if flags & 2 else node.get_indexed(NodePath(property))
		elif p == &"start_value":
			return node.get_indexed(NodePath(property))
	return null
