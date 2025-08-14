@tool
extends Button

signal seek_requested

@export var ival_node: IntervalNode

var start_time := 0.0
var total_duration := 1.0
var overlap := 0

var active := false:
	set(x):
		active = x
		_update_pressed_state()

func _ready() -> void:
	if self == get_tree().edited_scene_root or not ival_node:
		return
	icon = extract_script_icon(ival_node.get_script())
	text = _get_node_name()
	ival_node.renamed.connect(_update_name)
	Engine.get_singleton(&"EditorInterface").get_inspector().edited_object_changed.connect(_update_pressed_state)
	self_modulate = ival_node._get_editor_button_tint()

func _update_name():
	text = _get_node_name()

func _pressed() -> void:
	Engine.get_singleton(&"EditorInterface").inspect_object(null)
	Engine.get_singleton(&"EditorInterface").inspect_object(ival_node)

func _update_pressed_state():
	if active:
		set_pressed_no_signal(true)
		return
	else:
		set_pressed_no_signal(false)
		return
	
	#var inspector = Engine.get_singleton(&"EditorInterface").get_inspector()
	#var curr_obj: Object = inspector.get_edited_object()
	#set_pressed_no_signal(curr_obj == ival_node)

func _get_node_name():
	var base := "Unknown"
	if ival_node.name:
		base = ival_node.name
	elif ival_node.get_script():
		base = ival_node.get_script().get_global_name()
	
	if is_instance_of(ival_node, IntervalContainerNode):
		base += " (%s)" % ival_node._get_children_interval_nodes().size()
	
	return base

func _input(event: InputEvent) -> void:
	if is_visible_in_tree():
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				if get_global_rect().has_point(get_global_mouse_position()):
					seek_requested.emit()

#region Icons

static var _ival_node_icon_cache: Dictionary[Script, Texture2D] = {}

static func extract_script_icon(script: Script, limiter: int = 50) -> Texture2D:
	if not script:
		return null
	if script not in _ival_node_icon_cache:
		var icon_idx: int = script.source_code.find("@icon(")
		var _icon: Texture2D
		if icon_idx != -1 and icon_idx < limiter:
			var modified := script.source_code.substr(icon_idx)
			_icon = load(modified.get_slice(")", 0).replace("@icon(", "").replace("\"", ""))

		while _icon == null and script.get_base_script():
			script = script.get_base_script()
			_icon = extract_script_icon(script, limiter)
		_ival_node_icon_cache[script] = _icon
	return _ival_node_icon_cache[script]

#endregion
