@tool
extends VBoxContainer

signal request_reload

@onready var parent_containers: HBoxContainer = %ParentContainers
@onready var current_container_icon: TextureRect = %CurrentContainerIcon
@onready var current_container_edit: LineEdit = %CurrentContainerEdit
@onready var duration_edit: LineEdit = %DurationEdit
@onready var play_start: Button = %PlayStart
@onready var play_pause: Button = %PlayPause
@onready var toggle_loop: Button = %ToggleLoop
@onready var lock_current: Button = %LockCurrent
@onready var add_event: MenuButton = %AddEvent
@onready var toggle_zoom: Button = %ToggleZoom
@onready var tools: MenuButton = %Tools
@onready var reload_button: Button = %ReloadButton
@onready var time_label: Label = %TimeLabel
@onready var duration_label: Label = %DurationLabel
@onready var seek_slider: HSlider = %SeekSlider
@onready var event_boxes: Control = %EventBoxes

var icn: IntervalContainerNode:
	set(x):
		if icn == x or icn_locked:
			return
		if icn:
			icn.renamed.disconnect(_update_container_edit_text)
			icn.reset()
		icn = x
		if icn:
			icn.renamed.connect(_update_container_edit_text)
			icn.reset()
		update_current_icn()

var undo_redo #: EditorUndoRedoManager

var icn_locked := false

func _ready() -> void:
	reload_button.pressed.connect(request_reload.emit)
	current_container_edit.text_changed.connect(_container_edit_text_changed)
	lock_current.toggled.connect(_update_pc_lock.unbind(1))
	seek_slider.value_changed.connect(_perform_seek)
	visibility_changed.connect(_visibility_changed)
	_visibility_changed()
	play_start.pressed.connect(_on_play_start)
	play_pause.toggled.connect(_on_play_pause)
	_update_add_interval()
	tools.get_popup().id_pressed.connect(_tool_selected)
	
	#_update_icons()

func _visibility_changed():
	if not is_visible_in_tree():
		lock_current.button_pressed = false
	set_process(is_visible_in_tree())
	_update_seek_bar()

func _process(delta: float) -> void:
	_update_seek_bar()
	_rebuild_edit_buttons()

func _update_icons():
	var t: Theme = Engine.get_singleton(&"EditorInterface").get_editor_theme()
	play_start.icon = t.get_icon(&"PlayStart", &"EditorIcons")
	play_pause.icon = t.get_icon(&"Play", &"EditorIcons")
	toggle_loop.icon = t.get_icon(&"Loop", &"EditorIcons")
	lock_current.icon = t.get_icon(&"Lock", &"EditorIcons")
	add_event.icon = t.get_icon(&"Add", &"EditorIcons")
	toggle_zoom.icon = t.get_icon(&"Zoom", &"EditorIcons")
	tools.icon = t.get_icon(&"GuiTabMenuHl", &"EditorIcons")
	reload_button.icon = t.get_icon(&"Reload", &"EditorIcons")

#region Interval Refresh

func update_current_icn():
	#play_pause.button_pressed = false
	_update_parent_containers()
	_update_interval(true)
	_update_seek_bar()
	_rebuild_edit_buttons()

#endregion

#region Parent Containers Update

func _update_parent_containers():
	if self == get_tree().edited_scene_root:
		return
	
	# Remove all children.
	for c in parent_containers.get_children():
		parent_containers.remove_child(c)
		c.queue_free()
	
	if not icn:
		return
	
	# Populate with new ones.
	var pcs: Array[IntervalContainerNode] = []
	var n: Node = icn
	while true:
		n = n.get_parent()
		if n is IntervalContainerNode:
			pcs.append(n)
		else:
			break
	pcs.reverse()
	for pc in pcs:
		var b := Button.new()
		b.text = pc.name if pc.name else pc.get_script().get_global_name()
		b.pressed.connect(_jump_to_parent_icn.bind(pc))
		b.disabled = icn_locked
		b.icon = IntervalEditButton.extract_script_icon(pc.get_script())
		b.add_theme_constant_override(&"icon_max_width", 16)
		var l := Label.new()
		l.text = "=>"
		parent_containers.add_child(b)
		parent_containers.add_child(l)
	
	_update_container_edit_text()

func _jump_to_parent_icn(_icn: IntervalContainerNode):
	Engine.get_singleton(&"EditorInterface").inspect_object(_icn)

var _lock_update_container_edit_text := false

func _update_container_edit_text():
	if _lock_update_container_edit_text or not icn:
		return
	current_container_edit.text = icn.name
	current_container_icon.texture = IntervalEditButton.extract_script_icon(icn.get_script())
	current_container_edit.placeholder_text = icn.get_script().get_global_name()

func _container_edit_text_changed(new_text: String):
	if icn and is_instance_valid(icn):
		undo_redo.create_action("Renamed IntervalContainerNode %s" % icn.get_instance_id(), UndoRedo.MERGE_ALL, icn)
		undo_redo.add_do_property(icn, &"name", new_text if new_text else icn.get_script().get_global_name())
		undo_redo.add_undo_property(icn, &"name", icn.name)
		_lock_update_container_edit_text = true
		undo_redo.commit_action()
		_lock_update_container_edit_text = false

func _update_pc_lock():
	icn_locked = lock_current.button_pressed
	for c in parent_containers.get_children():
		if c is Button:
			c.disabled = icn_locked

#endregion

#region Seek Control

var current_t: float:
	get:
		if not active_interval:
			return 0.0
		return active_interval.get_total_elapsed_time()

func _update_seek_bar():
	if not icn or not interval:
		return
	
	var d := icn.as_interval().get_duration()
	duration_label.text = "%.2f" % d
	seek_slider.set_block_signals(true)
	seek_slider.min_value = 0.0
	seek_slider.max_value = d
	seek_slider.value = current_t
	seek_slider.set_block_signals(false)
	_update_current_time_label()

func _perform_seek(t: float):
	play_pause.button_pressed = false
	_update_interval(true)
	active_interval.custom_step(maxf(t, 0.0001))
	_update_current_time_label()

func _update_current_time_label():
	time_label.text = "%.2f" % current_t

#endregion

#region Interval Control

var interval: Interval
var active_interval: ActiveInterval

func _update_interval(reset := false):
	if not icn:
		interval = null
		active_interval = null
		return
	
	icn.reset()
	interval = icn.as_interval()
	var _last_t := current_t if not reset else 0.00001
	active_interval = interval.start(self)
	active_interval.custom_step(_last_t)
	if not play_pause.button_pressed:
		active_interval.pause()
	active_interval.finished.connect(_ival_finished)

func _ival_finished():
	if toggle_loop.button_pressed:
		interval = null
		active_interval = null
		_update_interval()

func _on_play_start():
	play_pause.button_pressed = true
	_update_interval(true)

func _on_play_pause(x: bool):
	var t: Theme = Engine.get_singleton(&"EditorInterface").get_editor_theme()
	if x:
		play_pause.icon = t.get_icon(&"Pause", &"EditorIcons")
	else:
		play_pause.icon = t.get_icon(&"Play", &"EditorIcons")
	_update_interval(false)

#endregion

#region Interval Edit Buttons

const IntervalEditButton = preload("res://addons/moon-interval/editor/interval/interval_edit_button.gd")
const INTERVAL_EDIT_BUTTON = preload("res://addons/moon-interval/editor/interval/interval_edit_button.tscn")

var ival_to_button: Dictionary[IntervalNode, IntervalEditButton] = {}

func _rebuild_edit_buttons():
	if not icn:
		return
	
	var curr_nodes := icn._get_children_interval_nodes()
	
	for existing in ival_to_button.keys():
		if existing not in curr_nodes:
			if is_instance_valid(existing):
				var b = ival_to_button[existing]
				event_boxes.remove_child(b)
				b.queue_free()
			ival_to_button.erase(existing)
	
	for new in curr_nodes:
		if new not in ival_to_button:
			var b: IntervalEditButton = INTERVAL_EDIT_BUTTON.instantiate()
			b.ival_node = new
			event_boxes.add_child(b)
			ival_to_button[new] = b
			b.seek_requested.connect(_request_button_seek.bind(b))
	
	var in_to_start_time: Dictionary[IntervalNode, float] = {}
	
	var event_rect := event_boxes.get_rect()
	var width := event_rect.size.x
	var total_duration := icn.get_duration()
	for ival in ival_to_button:
		if not is_instance_valid(ival):
			ival_to_button.erase(ival)
			continue
		var b := ival_to_button[ival]
		
		var start_time := icn.get_interval_node_start_time(ival)
		var duration := ival.get_duration()
		in_to_start_time[ival] = start_time
		
		b.active = current_t >= start_time and current_t < (start_time + duration)
		b.clip_text = not toggle_zoom.button_pressed
		
		var x_ratio_start := 0.0
		var x_ratio_width := 1.0
		
		if not is_zero_approx(total_duration):
			x_ratio_start = start_time / total_duration
			x_ratio_width = (ival.get_duration() / total_duration) * 0.99
		b.position.x = width * x_ratio_start
		b.custom_minimum_size.x = width * x_ratio_width
		b.size.x = 0.0
		b.position.x = minf(b.position.x, width - b.size.x)
	
	var ordered_ins := in_to_start_time.keys()
	ordered_ins.sort_custom(_sort_ins_by_start.bind(in_to_start_time))
	var ypos_end_dict := {}
	for ival in ordered_ins:
		if not is_instance_valid(ival):
			ival_to_button.erase(ival)
			continue
		var b: Button = ival_to_button[ival]
		var xpos_start := b.position.x
		var xpos_end := b.position.x + b.size.x
		
		for ypos in ypos_end_dict.keys():
			if ypos_end_dict[ypos] < xpos_start:
				ypos_end_dict.erase(ypos)
		
		var ypos := 0
		while ypos in ypos_end_dict:
			ypos += 1
		ypos_end_dict[ypos] = xpos_end
		
		b.position.y = (b.size.y + 1.0) * ypos

static func _sort_ins_by_start(a: IntervalNode, b: IntervalNode, value_dict: Dictionary[IntervalNode, float]) -> bool:
	return value_dict[a] < value_dict[b]

func _request_button_seek(b: IntervalEditButton):
	var start_time := icn.get_interval_node_start_time(b.ival_node)
	var _was_playing := play_pause.button_pressed
	_perform_seek(start_time)
	if _was_playing:
		play_pause.button_pressed = true

#endregion

#region Add Interval

const DELIMITER := "/"

func _update_add_interval():
	var root := add_event.get_popup()
	root.clear(true)
	
	var element_resource_classes := load_scripts_of_base_class(&"IntervalNode")
	
	## Create a dict for mapping all categories.
	var category_dict := {"": {}}  # defining default path for no category
	for resource_class in element_resource_classes:
		var category_path: String = resource_class._get_editor_category()
		var categories := category_path.split(DELIMITER)
		var curr_dict := category_dict
		for category: String in categories:
			curr_dict = curr_dict.get_or_add(category, {})
	
	## Build the header items.
	var category_path_to_popup_menu := {"": root}
	_recusrive_make_category_items(category_dict, category_path_to_popup_menu, root)
	
	## Create all category for events groups.
	var groups := {}
	for resource_class in element_resource_classes:
		if resource_class == IntervalNode:
			continue
		if resource_class == IntervalContainerNode:
			continue
		var category: String = resource_class._get_editor_category()
		groups.get_or_add(category, []).append([resource_class.get_global_name(), resource_class])
	for group_array: Array in groups.values():
		group_array.sort_custom(func (a, b): return a[0] < b[0])
	
	# Build all tree items now.
	for category in groups:
		for event_data: Array in groups[category]:
			## Get menu.
			var item_name: String = event_data[0]
			item_name = item_name.trim_suffix("Node")
			var resource_class: GDScript = event_data[1]
			
			var icon: Texture2D = IntervalEditButton.extract_script_icon(resource_class)
			var _modulate: Color = resource_class._get_editor_button_tint()
			
			## Create menu item.
			var parent_menu: PopupMenu = category_path_to_popup_menu.get(category)
			var id: int = parent_menu.item_count
			parent_menu.add_item(item_name, id)
			if icon:
				parent_menu.set_item_icon(id, icon)
				parent_menu.set_item_icon_modulate(id, _modulate)
				parent_menu.set_item_icon_max_width(id, 16)
			
			parent_menu.id_pressed.connect(func(x):
				if x == id:
					_create_interval(resource_class)
			)

func _create_interval(ival_script: GDScript):
	var ival_node: IntervalNode = ival_script.new()
	
	var parent := icn
	#var curr_selected: Node = Engine.get_singleton(&"EditorInterface").get_inspector().get_edited_object()
	#if is_instance_of(curr_selected, IntervalContainerNode):
		#parent = curr_selected
	
	parent.add_child(ival_node)
	ival_node.owner = get_tree().edited_scene_root
	ival_node.name = ival_script.get_global_name()
	Engine.get_singleton(&"EditorInterface").inspect_object(ival_node)

func _recusrive_make_category_items(category_dict: Dictionary, out: Dictionary, parent: PopupMenu, path: String = ""):
	## Get all of the headers for this dictionary.
	var categories: Array = category_dict.keys()
	categories.sort()
	
	## Create a tree item for each header.
	for category: String in categories:
		var category_path := category if not path else path + DELIMITER + category
		var category_menu := parent
		if category_path:
			category_menu = PopupMenu.new()
			parent.add_submenu_node_item(category, category_menu)
			out[category_path] = category_menu
		
		_recusrive_make_category_items(category_dict[category], out, category_menu, category_path)

## Helper function to nab all scripts of a given base class
static func load_scripts_of_base_class(base_class: StringName) -> Array:
	var global_class_list := ProjectSettings.get_global_class_list()
	var ret_dict := {}
	var last_result := -1
	while last_result != ret_dict.size():
		last_result = ret_dict.size()
		for item in global_class_list:
			if item['base'] in ret_dict or item['class'] == base_class:
				ret_dict[item['class']] = load(item['path'])
	return ret_dict.values()

#endregion

#region Refresh Save/Load

func _get_state() -> Dictionary:
	return {
		icn = icn,
		icn_locked = icn_locked,
		current_t = current_t
	}

func _set_state(d: Dictionary):
	icn = d.icn
	lock_current.button_pressed = d.icn_locked
	current_t = d.current_t
	_update_seek_bar()
	_perform_seek(current_t)

#endregion

#region Tools

func _tool_selected(id: int):
	match id:
		0:
			# Offset Selected Track Positions
			# Which odes do we have selected?
			var selected_nodes: Array[IntervalNode] = []
			var ei = Engine.get_singleton(&"EditorInterface")
			
			for n: Node in ei.get_selection().get_selected_nodes():
				if is_instance_of(n, IntervalNode):
					if is_instance_of(n.get_parent(), TrackNode):
						selected_nodes.append(n)
			
			if not selected_nodes:
				var w := AcceptDialog.new()
				w.title = "Offset Selected Track Positions"
				w.dialog_text = "No IntervalNodes with a TrackNode parent were selected.\nPlease reselect nodes and try the tool again."
				ei.popup_dialog_centered(w)
			else:
				var in_substr := ""
				for n in selected_nodes:
					in_substr += "- %s\n" % n.name
				
				# Create the dialogue.
				var w := ConfirmationDialog.new()
				w.title = "Offset Selected Track Positions"
				w.dialog_text = "This operation will affect the following nodes:\n%sType the time offset below and press OK to shift times.\n\n" % in_substr
				
				var offset_container := Control.new()
				var offset_entry := LineEdit.new()
				offset_entry.custom_minimum_size.y = 16
				offset_entry.placeholder_text = "0.00"
				w.register_text_enter(offset_entry)
				offset_container.add_child(offset_entry)
				offset_entry.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
				w.add_child(offset_container)
				
				#w.add_child(contents)
				ei.popup_dialog_centered(w)
				
				w.confirmed.connect(func ():
					var amount := float(offset_entry.text)
					for n in selected_nodes:
						n.track_position = maxf(n.track_position + amount, 0.0)
				)

#endregion
