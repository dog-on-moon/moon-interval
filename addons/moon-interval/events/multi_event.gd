@tool
@icon("res://addons/moon-interval/icons/event_player.png")
extends Event
class_name MultiEvent
## A MultiEvent contains multiple events and can be used for advanced, dynamic cutscenes.

## The editor data for this MultiEvent.
@export_storage var editor_data: Resource = null

## When true, cycles are allowed in the Multievent.
@export_storage var cycles := false

## When true, all started events will log their properties to the terminal.
@export var debug := false

## Whether or not we have completed this MultiEvent.
var completed := false

## The number of current events that are running.
var active_branches := 0

## All events that have been started.
var started_events: Array = []

## The last event we've finished.
var last_event: Event = null

#region Runtime Logic
func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	## Reset multievent state.
	completed = false
	started_events = []
	last_event = null
	
	## Create multievent start function.
	return Func.new(_start.bind(_owner, _state))

## Called to begin performing the MultiEvent.
func _start(_owner: Node, _state: Dictionary):
	## Get all open-facing branches.
	var unresolved_int_events: Array = editor_data.get_unresolved_input_resources()
	if not unresolved_int_events:
		_finish()
		return
	
	## Start each one.
	active_branches = unresolved_int_events.size()
	for event in unresolved_int_events:
		_start_branch(event, _owner, _state, false)

## Begins an event branch.
func _start_branch(event: Event, _owner: Node, _state: Dictionary, count_branch := true):
	if count_branch:
		active_branches += 1
	if debug:
		print('--- START "%s"' % event)
		# event.print_debug_info()
	started_events.append(event)
	event.play(_owner, _end_branch.bind(event, _owner, _state), _state)

## Called when an event branch is complete.
func _end_branch(event: Event, _owner: Node, _state: Dictionary):
	last_event = event
	
	if debug:
		print('--- END "%s"' % event)
	
	## Perform all connecting branches.
	for connected_event: Event in get_event_connections(event):
		if connected_event not in started_events or cycles:
			_start_branch(connected_event, _owner, _state)
	
	## Update active branch state.
	active_branches -= 1
	if active_branches == 0 or event is EndMultiEvent:
		_finish()

## Determines the events that comes after a given event.
func get_event_connections(event: Event) -> Array:
	## Get connection information about the event.
	var ret_events: Array = []
	var branch_idx := event.get_branch_index()
	var event_outputs: Dictionary = editor_data.get_resource_outputs(event)
	## Use the requested branch index if defined.
	if branch_idx in event_outputs:
		ret_events.assign(event_outputs[branch_idx])
	## Otherwise, try and use the default branch index.
	elif 0 in event_outputs:
		ret_events.assign(event_outputs[0])
	## No good.
	return ret_events

func _finish():
	if not completed:
		done.emit()
		completed = true
#endregion

#region Branching Logic
## A MultiEvent's output is based on whatever the
## last completed event's output port is.
## Returns Dict[Event, Array[int]]
func _get_output_dict() -> Dictionary:
	var output := {}
	
	## Review each event.
	for event in editor_data.resources:
		var empty_ports: Array[int] = []
		var current_outputs: Dictionary = editor_data.get_resource_outputs(event)
		
		## Check each output ID on the event.
		for branch_idx: int in event.get_output_connections():
			## If it has a defined output, skip.
			if branch_idx in current_outputs:
				continue
			empty_ports.append(branch_idx)
		
		## If we have empty ports, declare it in the output.
		if empty_ports:
			output[event] = empty_ports
	
	## Return our output.
	return output

func get_branch_names() -> Array:
	var base_names := super()
	
	## Iterate over each available output port.
	var output_dict := _get_output_dict()
	for event: Event in output_dict:
		var event_name := event.to_string()
		var branch_names := event.get_branch_names()
		for branch_idx: int in output_dict[event]:
			## Add the branch name.
			var branch_name: String = branch_names[branch_idx]
			base_names.append('[%s]: %s' % [event_name, branch_name])
	
	## Return base names.
	return base_names

func get_branch_index() -> int:
	## If we have a last event defined, review our output dictionary
	## to determine what our true branch index should be.
	if last_event:
		var last_event_branch := last_event.get_branch_index()
		var output_dict := _get_output_dict()
		var return_branch_idx := 0
		## We have to do a linear search through the output dict,
		## because we need the branch_idx to properly match the names.
		for event: Event in output_dict:
			for branch_idx: int in output_dict[event]:
				return_branch_idx += 1
				
				## If the event and branch matches, we use this index.
				if event == last_event and last_event_branch == branch_idx:
					return return_branch_idx
		
		## No branch found (perhaps ended on a branchless node)
		return super()
	else:
		## No last event, so we just rely on the default branch.
		return super()
#endregion

#region Event Overrides
func _enter():
	if not editor_data:
		editor_data = GraphEditResource.new()

func _editor_ready(edit: GraphEdit, element: GraphElement):
	super(edit, element)
	## Inspecting a MultiEvent = ensure that we open it in the editor
	var node: GraphNode2 = element
	node.inspect_button.pressed.connect(func (): edit.multi_event_editor.multi_event = self)
	node.inspect_button.icon = preload("uid://dogu5nl2t0e3o")

static func get_graph_node_title() -> String:
	return "MultiEvent"

static func get_graph_node_color() -> Color:
	return Color.WEB_MAROON

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return "[b][center]Sub-Events: %s" % (editor_data.resources.size() if editor_data.resources else 0)
#endregion

func clone(deep := false) -> MultiEvent:
	var copy: MultiEvent = duplicate(true)
	copy.editor_data = editor_data.clone(deep)
	return copy
