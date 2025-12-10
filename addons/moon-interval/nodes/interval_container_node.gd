@tool
@abstract
@icon("res://addons/moon-interval/icons/interval_container.png")
extends IntervalNode
class_name IntervalContainerNode

## Flags for overriding child interval properties.
## If these are set, then certain Interval children will infer their properties
## from this parent IntervalContainer.
@export_flags("Duration:1", "Ease:2", "Trans:4") var overrides := 0:
	set(x):
		overrides = x
		notify_property_list_changed()

## Overridden duration for all children IntervalNodes.
@export_range(0.0, 8.0, 0.01, "or_greater") var duration_override := 0.0

## Overridden easing for all children IntervalNodes.
@export var ease_override := Tween.EASE_IN_OUT

## Overridden transition for all children IntervalNodes.
@export var trans_override := Tween.TRANS_LINEAR


@export var propagate_parent_override := true

@abstract func as_interval() -> Interval

func reset():
	for n in _get_children_interval_nodes():
		if n.reset_in_editor:
			n.reset()

func replace_node(old: Node, new: Node):
	for c in _get_children_interval_nodes():
		c.replace_node(old, new)

func globalize_transforms(local_transform_parent: Node, checknode: Node = null):
	for c in _get_children_interval_nodes():
		c.globalize_transforms(local_transform_parent, checknode)

@abstract func get_interval_node_start_time(interval_node: IntervalNode) -> float

func _get_children_intervals() -> Array[Interval]:
	var intervals: Array[Interval] = []
	for child in _get_children_interval_nodes():
		intervals.append(child.as_interval())
	return intervals

func _get_children_interval_nodes() -> Array[IntervalNode]:
	var children_nodes: Array[IntervalNode] = []
	for child in get_children():
		if is_instance_of(child, IntervalNode):
			var _in: IntervalNode = child
			if Engine.is_editor_hint() and not _in.preview_in_editor:
				continue
			if _in.active:
				children_nodes.append(_in)
	return children_nodes

func has_duration_override(include_parent := true) -> bool:
	if propagate_parent_override and include_parent:
		var p := get_parent()
		if p is IntervalContainerNode:
			if p.has_duration_override():
				return true
	return overrides & 1

func get_duration_override() -> float:
	if has_duration_override(false):
		return duration_override
	elif has_duration_override(true):
		return get_parent().duration_override
	return 0.0

func has_ease_override(include_parent := true) -> bool:
	if propagate_parent_override and include_parent:
		var p := get_parent()
		if p is IntervalContainerNode:
			if p.has_ease_override():
				return true
	return overrides & 2

func get_ease_override() -> float:
	if has_ease_override(false):
		return ease_override
	elif has_ease_override(true):
		return get_parent().ease_override
	return 0.0

func has_trans_override(include_parent := true) -> bool:
	if propagate_parent_override and include_parent:
		var p := get_parent()
		if p is IntervalContainerNode:
			if p.has_trans_override():
				return true
	return overrides & 4

func get_trans_override() -> float:
	if has_trans_override(false):
		return trans_override
	elif has_trans_override(true):
		return get_parent().trans_override
	return 0.0

func _validate_property(property: Dictionary) -> void:
	super(property)
	if not Engine.is_editor_hint(): return
	match property.name:
		&"duration_override":
			if not has_duration_override(false):
				property.usage = 0
		&"ease_override":
			if not has_ease_override(false):
				property.usage = 0
		&"trans_override":
			if not has_trans_override(false):
				property.usage = 0
		&"propagate_parent_override":
			if get_parent() is not IntervalContainerNode:
				property.usage = 0

static func _get_editor_category() -> String:
	return "Containers"
