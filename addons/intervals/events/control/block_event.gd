@tool
extends Event
class_name BlockEvent
## Given an event by reference,
## blocks until that event's done is emitted.

## An external event (by reference). Should be present elsewhere in the cutscene.
## Does not emit done until or unless that event has emitted done.
@export var event: Event:
	set(x):
		event = x
		if _inspect_node_button:
			_inspect_node_button.visible = event != null

var is_done := false
var is_reached := false

var _inspect_node_button: Button = null

func _init() -> void:
	if not Engine.is_editor_hint():
		setup.call_deferred()

func setup():
	event.done.connect(on_done)

## Returns the interval for this specific event.
## Must be implemented by event subclasses.
func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Func.new(on_reached)

func reset():
	is_done = false
	is_reached = false

func on_done():
	is_done = true
	if is_reached:
		reset()
		done.emit()

func on_reached():
	is_reached = true
	if is_done:
		reset()
		done.emit() 

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Control"

static func get_graph_node_title() -> String:
	return "Await Event"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return  ("Awaiting %s" % event.to_string()) if event else "[color=red][b]Event Undefined"

static func get_graph_node_color() -> Color:
	return SignalEvent.get_graph_node_color()

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_inspect_node_button = _element._add_titlebar_button(1, "", preload("uid://dogu5nl2t0e3o"))
	_inspect_node_button.pressed.connect(_on_inspect)
	_inspect_node_button.visible = event != null

func _on_inspect():
	if event:
		EditorInterface.inspect_object(event)
#endregion
