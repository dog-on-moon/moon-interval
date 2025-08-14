@tool
@icon("res://addons/moon-interval/icons/interval.png")
extends Node
class_name IntervalNode
## A base class for nodes that compile into intervals.

## The position in the parent track this interval is active in.
## Only available if the parent node is a TrackNode.
@export var track_position := 0.0

## Automatically plays the interval on ready.
@export var autoplay := false

## Determines if the autoplayed interval is looping.
@export var looping := false

## Determines if this interval is active.
## When inactive, it will not playback, or contribute to parent IntervalContainerNodes.
@export var active := true

@export_category("Editor")

## Determines if this node is allowed to perform scene modification
## on editor reset. Typically used for LerpProperty.
@export var reset_in_editor := true

## Determines if this interval is previewed in the editor.
## If false, it is ignored.
@export var preview_in_editor := true

@warning_ignore("unused_private_class_variable")
@export_tool_button("Preview", "Play") var _p = _preview

var _ival: ActiveInterval

func _ready() -> void:
	if not Engine.is_editor_hint() and autoplay:
		start(self, false, looping)

## Creates an ActiveInterval using this node.
##
##	WARNING!!!!!!!!!! WARNING!!!!!!!!!!!!!!!!!!!!!! READ THIS!!!!!!!!!!!!!!!!!!!!!!!!
## 		If _owner is defined, it is the responsibility of the caller
## 		to KEEP A REFERENCE to the ActiveInterval so it does not clean up!!
##
##	I HOPE YOU READ THIS!!!!!!!!!!!
##
func start(_owner: Node = null, autofinish := false, loop := false) -> ActiveInterval:
	if not active:
		return null
	if Engine.is_editor_hint() and not preview_in_editor:
		return null
	var ival: ActiveInterval
	if not _owner:
		_owner = self
	ival = as_interval().start(self, autofinish)
	if loop:
		ival.set_loops()
	if _owner == self:
		_ival = ival
	return ival

func cancel_autoplay():
	_ival = null

# virtual
func as_interval() -> Interval:
	return null

# virtual, reset the animation on editor pre-save
func reset():
	pass

func replace_node(old: Node, new: Node):
	if &"node" in self:
		if get(&"node") == old:
			set(&"node", new)

func get_duration() -> float:
	return as_interval().get_duration()

func _preview():
	start(self, false, looping)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		if is_instance_of(get_parent(), IntervalContainerNode):
			autoplay = false
			looping = false
		notify_property_list_changed()
	elif what == NOTIFICATION_EDITOR_PRE_SAVE:
		_ival = null
		if reset_in_editor and not is_instance_of(self, IntervalContainerNode):
			reset()

func _validate_property(property: Dictionary) -> void:
	if Engine.is_editor_hint():
		var p := get_parent()
		if is_instance_of(p, IntervalContainerNode):
			var pp: IntervalContainerNode = p
			match property.name:
				&"autoplay", &"looping":
					property.usage ^= PROPERTY_USAGE_READ_ONLY
				&"duration":
					if pp.has_duration_override():
						property.usage ^= PROPERTY_USAGE_EDITOR
				&"ease":
					if pp.has_ease_override():
						property.usage ^= PROPERTY_USAGE_EDITOR
				&"trans":
					if pp.has_trans_override():
						property.usage ^= PROPERTY_USAGE_EDITOR
		if property.name == &"track_position":
			if not is_instance_of(p, TrackNode):
				property.usage = 0
			else:
				var duration: float = p.get_duration()
				property.hint = PROPERTY_HINT_RANGE
				property.hint_string = "0,%s,0.001,or_greater" % duration

#region Editor

static func _get_editor_button_tint() -> Color:
	return Color.WHITE

static func _get_editor_category() -> String:
	return ""

#endregion
