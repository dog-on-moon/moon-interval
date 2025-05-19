@tool
extends EditorPlugin
## Intervals by dog.on.moon
## Developer-friendly Tweens packaged with a simple, powerful, expandable cutscene editor.
## [dependent on graphedit2]

const MultiEventEditor = preload("uid://2337ws3vaecv")

var multi_event_editor: MultiEventEditor = null
var multi_event_editor_button: Button = null

func _enter_tree():
	const EVENT_PLAYER := preload("uid://bs7ckj12htwqh")
	const INTERVAL := preload("uid://cr0j7hu3tjk8b")
	const INTERVAL_CONTAINER := preload("uid://6bii5s250feh")
	
	## Intervals
	add_custom_type("Interval", "RefCounted", preload("uid://b17n1b0oicgpl"), INTERVAL)
	
	## Common Intervals
	add_custom_type("Connect", "Interval", preload("uid://d05jrpf7u7s6"), INTERVAL)
	add_custom_type("Func", "Interval", preload("uid://c1ywhkgbfdwxj"), INTERVAL)
	add_custom_type("LerpFunc", "Interval", preload("uid://s1ii5ralvh"), INTERVAL)
	add_custom_type("LerpProperty", "Interval", preload("uid://dmed6bgl2e8wr"), INTERVAL)
	add_custom_type("SetProperty", "Interval", preload("uid://jmqo50w85qjk"), INTERVAL)
	add_custom_type("Wait", "Interval", preload("uid://dc3mxutiufww8"), INTERVAL)
	
	## Container Intervals
	add_custom_type("IntervalContainer", "Interval", preload("uid://c1hfin7e7dwgs"), INTERVAL_CONTAINER)
	add_custom_type("Parallel", "IntervalContainer", preload("uid://b2d4d4n78umny"), INTERVAL_CONTAINER)
	add_custom_type("Sequence", "IntervalContainer", preload("uid://bf2mu7m4iycy1"), INTERVAL_CONTAINER)
	add_custom_type("SequenceRandom", "IntervalContainer", preload("uid://dcjdodbw8jfj1"), INTERVAL_CONTAINER)
	add_custom_type("TrackInterval", "IntervalContainer", preload("uid://4j3c3kkplxlk"), INTERVAL_CONTAINER)

	## Nodes
	add_custom_type("EventPlayer", "Node", preload("uid://blsus0wox3w7p"), EVENT_PLAYER)
	
	## MultiEvent Editor
	_create_editor()
	
	## Signals
	EditorInterface.get_inspector().property_edited.connect(_property_selected)
	EditorInterface.get_inspector().property_selected.connect(_property_selected)
	EditorInterface.get_inspector().edited_object_changed.connect(_edited_object_changed)

func _exit_tree():
	## Intervals
	remove_custom_type("Interval")
	
	## Common Intervals
	remove_custom_type("Connect")
	remove_custom_type("Func")
	remove_custom_type("LerpFunc")
	remove_custom_type("LerpProperty")
	remove_custom_type("SetProperty")
	remove_custom_type("Wait")
	
	## Container Intervals
	remove_custom_type("IntervalContainer")
	remove_custom_type("Parallel")
	remove_custom_type("Sequence")
	remove_custom_type("SequenceRandom")
	remove_custom_type("TrackInterval")
	
	## Nodes
	remove_custom_type("EventPlayer")
	
	## MultiEvent Editor
	_cleanup_editor()
	
	## Signals
	EditorInterface.get_inspector().property_edited.disconnect(_property_selected)
	EditorInterface.get_inspector().property_selected.disconnect(_property_selected)
	EditorInterface.get_inspector().edited_object_changed.disconnect(_edited_object_changed)

var _stored_object: WeakRef = null
var _stored_property: String = ""

func _property_selected(property: String):
	var object := EditorInterface.get_inspector().get_edited_object()
	var value := object.get(property)
	if value is MultiEvent:
		_show_editor(value)
	
	# If the property we were observing to clears out, close the editor.
	if _stored_object and _stored_object.get_ref() == object \
		and property == _stored_property and value == null:
		_hide_editor()
	
	_stored_object = weakref(object)
	_stored_property = property

func _edited_object_changed():
	var object := EditorInterface.get_inspector().get_edited_object()
	if object:
		if object is EventPlayer and object.multi_event:
			_show_editor(object.multi_event)
			_stored_object = weakref(object)
			_stored_property = "multi_event"
		elif object is MultiEvent:
			_show_editor(object)
			_stored_object = null
			_stored_property = ""
		elif object is not Event:
			pass
			# _hide_editor()
	else:
		_hide_editor()

func _show_editor(multi_event: MultiEvent):
	multi_event_editor.multi_event = multi_event
	if not multi_event_editor_button.visible:
		multi_event_editor_button.visible = true
		multi_event_editor_button.button_pressed = true

func _hide_editor():
	multi_event_editor_button.button_pressed = false
	multi_event_editor_button.visible = false
	multi_event_editor.multi_event = null
	_stored_object = null
	_stored_property = ""

func _create_editor():
	assert(not multi_event_editor)
	multi_event_editor = load("uid://denrfwms0xkc7").instantiate()
	multi_event_editor.undo_redo = get_undo_redo()
	multi_event_editor_button = add_control_to_bottom_panel(multi_event_editor, "MultiEvent")
	multi_event_editor_button.visible = false
	multi_event_editor.request_reload.connect(_reload_editor)

func _cleanup_editor():
	assert(multi_event_editor)
	remove_control_from_bottom_panel(multi_event_editor)
	multi_event_editor.queue_free()
	multi_event_editor = null

func _reload_editor():
	var state: Dictionary = multi_event_editor._get_state()
	_cleanup_editor()
	_create_editor()
	multi_event_editor._set_state(state)
	if not multi_event_editor_button.visible:
		multi_event_editor_button.visible = true
		multi_event_editor_button.button_pressed = true
		multi_event_editor.graph_edit.recenter()
