@tool
@icon("res://addons/moon-interval/icons/event.png")
extends GraphNodeResource
class_name Event
## An Interval resource with playback logic for dynamic cutscenes.
##
## Events can be used to describe and build clusters of timed actions together.
## These actions can be blocking, and can be used to build complex, dynamic cutscenes.
## Events emit [signal done] on completion.
## A [MultiEvent] can play back multiple linear or branching events.
##
## Subclasses must implement [method _get_interval].

## Emitted when this event is complete.
signal done()

## Returns the interval for this specific event.
## Must be implemented by event subclasses.
## Remember to emit [signal done].
func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Func.new(done.emit)

#region Branching Logic
## Gets the names of the outgoing branches.
func get_branch_names() -> Array[String]:
	return ["Default"]

## Determines the branch index we're choosing based on internal state. (chosen at runtime)
## 0 is first index of branch name array, 1 is second, etc
func get_branch_index() -> int:
	return 0
#endregion

#region Base Editor Overrides
## The category that the event will belong to.
static func get_graph_dropdown_category() -> String:
	return "Meta"

## The title of the graph node for this Event.
static func get_graph_node_title() -> String:
	return "Event"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return ""

## The color of the graph node for this Event.
static func get_graph_node_color() -> Color:
	return Color.DIM_GRAY

## Called from the GraphNode regarding this Event.
func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	if _editor_flatten_default_label():
		if _element.connection_labels:
			# Remove the initial connection label and replace it with a flat control.
			var default_connection_label: Label = _element.connection_labels.pop_at(0)
			default_connection_label.queue_free()
			var flat_connection_substitute := Control.new()
			flat_connection_substitute.size = Vector2.ZERO
			_element.add_child(flat_connection_substitute)
			_element.move_child(flat_connection_substitute, 0)
			_element.connection_labels.insert(0, flat_connection_substitute)

## Called each frame from the Graphnode regarding this Event.
func _editor_process(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	
	if _element.connection_labels:
		var offset := 1 if _editor_flatten_default_label() else 0
		var branch_names := get_branch_names()
		for i: int in min(_element.connection_labels.size(), branch_names.size()) - offset:
			var label: Label = _element.connection_labels[i + offset]
			if label.text != branch_names[i + offset]:
				label.text = branch_names[i + offset]

## Determines if we should flattern the default label.
func _editor_flatten_default_label() -> bool:
	return true
#endregion

#region GraphElement overrides
## The icon that the element uses in the dropdown.
static func get_graph_dropdown_icon() -> Texture2D:
	return preload("uid://c55jdycqxnso6")
#endregion

#region Helpers
## Returns the scene owner for nodepaths.
static func get_editor_owner(edit: GraphEdit) -> Node:
	return edit.multi_event_editor.event_owner
#endregion

#region GraphNode Overrides -- do not touch
func get_input_connections() -> int:
	## Each Event has one input port.
	return 1

func get_output_connections() -> int:
	## Events have one default input port, and then one for each branch.
	return get_branch_names().size()
#endregion

#region Internal -- do not touch
## Performs the event. When it is finished, [signal done] will be emitted.
func play(_owner: Node, callback: Callable = _do_nothing, _state: Dictionary = {}) -> Tween:
	if callback != _do_nothing:
		done.connect(callback, CONNECT_ONE_SHOT)
	return _get_interval(_owner, _state).as_tween(_owner)

static func get_node_path_string(_owner: Node, np: NodePath) -> String:
	var valid_np := np and _owner and _owner.get_node_or_null(np)
	return _owner.get_node(np).name if valid_np else "[color=red]Invalid NodePath[/color]"

## Prints debugging information on this event.
func print_debug_info():
	print_rich("[b]'%s'[/b]" % self)
	for property in get_property_list():
		if not property['usage'] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		print('[i]%s:[/i] %s' % [property['name'], self[property['name']]])
	print()

# Does nothing. :(
static func _do_nothing():
	pass
#endregion
