@tool
@icon("res://addons/moon-interval/icons/interval.png")
extends Node
class_name IntervalNode
## A base class for nodes that compile into intervals.

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

@warning_ignore("unused_private_class_variable")
@export_tool_button("Preview", "Play") var _p = _preview

var _ival: ActiveInterval

func _ready() -> void:
	if not Engine.is_editor_hint() and autoplay:
		start(self, false, looping)

## Creates an ActiveInterval using this node.
## Note that if the owner is not this node, it is the responsibility of the
## caller to hold a reference to the ActiveInterval so it does not clean up!!
func start(_owner: Node = null, autofinish := false, loop := false) -> ActiveInterval:
	if not active:
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
		if reset_in_editor:
			reset()

func _validate_property(property: Dictionary) -> void:
	if Engine.is_editor_hint() and is_instance_of(get_parent(), IntervalContainerNode):
		if property.name == &"autoplay" or property.name == &"looping":
			property.usage ^= PROPERTY_USAGE_READ_ONLY
		elif property.name == &"Preview":
			pass
