@tool
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

func as_interval() -> Interval:
	return IntervalContainer.new(_get_children_intervals())

func reset():
	for n in _get_children_interval_nodes():
		if n.reset_in_editor:
			n.reset()

func replace_node(old: Node, new: Node):
	for n in _get_children_interval_nodes():
		n.replace_node(old, new)

# virtual
func get_interval_node_start_time(interval_node: IntervalNode) -> float:
	return 0.0

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

func has_duration_override() -> bool:
	return overrides & 1

func has_ease_override() -> bool:
	return overrides & 2

func has_trans_override() -> bool:
	return overrides & 4

func _validate_property(property: Dictionary) -> void:
	super(property)
	if not Engine.is_editor_hint(): return
	match property.name:
		&"duration_override":
			if not has_duration_override():
				property.usage = 0
		&"ease_override":
			if not has_ease_override():
				property.usage = 0
		&"trans_override":
			if not has_trans_override():
				property.usage = 0

static func _get_editor_category() -> String:
	return "Containers"
