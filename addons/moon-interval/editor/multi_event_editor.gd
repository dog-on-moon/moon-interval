@tool
extends VSplitContainer
## The editor for MultiEvents.

signal request_reload

const MultiEventGraphEdit = preload("uid://ca8nlkbok27c4")

@onready var header: HBoxContainer = $Header
@onready var graph_edit: MultiEventGraphEdit = $GraphEdit
@onready var label: Label = $Label

@onready var up_event_button: Button = $Header/UpEventButton
@onready var up_event_label: Label = $Header/UpEventLabel
@onready var event_name_edit: TextEdit = $Header/EventNameEdit
@onready var warning_spacing: Label = $Header/WarningSpacing
@onready var reload_button: Button = $Header/ReloadButton

@onready var cycles_box: CheckBox = $Header/CyclesBox
@onready var debug_box: CheckBox = $Header/DebugBox

var multi_event_stack: Array[MultiEvent] = []

@export var multi_event: MultiEvent:
	set(x):
		if multi_event == x:
			return
		
		if multi_event_stack and x == multi_event_stack[-1]:
			multi_event_stack.pop_back()
			_update_event_stack()
		elif multi_event and multi_event.editor_data and x in multi_event.editor_data.resources:
			multi_event_stack.append(multi_event)
			_update_event_stack()
		else:
			multi_event_stack = []
			_update_event_stack()
		
		if x and not x.editor_data:
			x.editor_data = GraphEditResource.new()
		multi_event = x
		
		if is_node_ready():
			graph_edit.multi_event = x
			event_name_edit.text = x.resource_name if x else ""
			header.visible = x != null
			graph_edit.visible = x != null
			label.visible = x == null
			update()

var event_owner: Node:
	get(): return get_tree().edited_scene_root

var undo_redo: EditorUndoRedoManager

func _ready() -> void:
	multi_event = multi_event
	
	cycles_box.pressed.connect(func ():
		undo_redo.create_action("Set %s cycles" % multi_event.to_string())
		undo_redo.add_do_property(multi_event, &"cycles", not multi_event.cycles)
		undo_redo.add_undo_property(multi_event, &"cycles", multi_event.cycles)
		undo_redo.commit_action()
	)
	debug_box.pressed.connect(func ():
		undo_redo.create_action("Set %s debug" % multi_event.to_string())
		undo_redo.add_do_property(multi_event, &"debug", not multi_event.debug)
		undo_redo.add_undo_property(multi_event, &"debug", multi_event.debug)
		undo_redo.commit_action()
	)
	up_event_button.pressed.connect(func (): up_event_stack())
	event_name_edit.text_changed.connect(func (): multi_event.resource_name = event_name_edit.text)
	reload_button.pressed.connect(request_reload.emit)

func up_event_stack():
	if multi_event_stack:
		multi_event = multi_event_stack[-1]

func _update_event_stack():
	if multi_event_stack:
		up_event_button.show()
		up_event_label.show()
		var txt := " "
		for multi_event in multi_event_stack:
			txt += multi_event.to_string() + " > "
		up_event_label.text = txt
	else:
		up_event_button.hide()
		up_event_label.hide()

func _process(delta: float) -> void:
	update()

func update():
	if multi_event and is_node_ready():
		if cycles_box.button_pressed != multi_event.cycles:
			cycles_box.button_pressed = multi_event.cycles
		if debug_box.button_pressed != multi_event.debug:
			debug_box.button_pressed = multi_event.debug
		if event_name_edit.text != multi_event.resource_name:
			event_name_edit.text = multi_event.resource_name
		if event_name_edit.placeholder_text != multi_event.to_string():
			event_name_edit.placeholder_text = multi_event.to_string()

func _get_state():
	return {
		'me': multi_event,
		'me_stack': multi_event_stack,
		'so': graph_edit.scroll_offset,
		'z': graph_edit.zoom,
	}

func _set_state(d: Dictionary):
	multi_event = d['me']
	multi_event_stack = d['me_stack']
	_update_event_stack()
	await get_tree().process_frame
	graph_edit.scroll_offset = d['so']
	graph_edit.zoom = d['z']
