@tool
extends GraphNode
class_name GraphNode2

## The node resource associated with the GraphNode.
## Must be a GraphNodeResource or otherwise implement its traits.
@export var resource: GraphNodeResource:
	set(x):
		resource = x
		_has_called_resource_ready = false
		_update_appearance()

@onready var graph_edit: GraphEdit2 = get_parent()

var connection_labels: Array[Control] = []

var inspect_button: Button
var close_button: Button

var _has_called_resource_ready := false

func _ready() -> void:
	# Set header label to fill real quick
	#var title_bar := get_titlebar_hbox()
	#var header_label: Label = get_titlebar_hbox().get_child(0)
	#header_label.size_flags_horizontal = SIZE_FILL + SIZE_EXPAND
	
	inspect_button = _add_titlebar_button(1, "", preload("uid://dd3oguwxhqx81"))
	inspect_button.pressed.connect(func (): EditorInterface.edit_resource(resource))
	close_button = _add_titlebar_button(2, "", preload("uid://b7skhb160qyx0"))
	close_button.pressed.connect(func (): graph_edit.remove_resource(resource))

func _process(delta: float) -> void:
	if resource:
		resource._editor_process(graph_edit, self)
	_update_appearance()

## Adds a button to the titlebar.
func _add_titlebar_button(index: int, text: String = "", icon: Texture2D = null) -> Button:
	# Create button.
	var button := Button.new()
	button.text = text
	button.icon = icon
	
	var stylebox := StyleBoxEmpty.new()
	button.add_theme_stylebox_override(&"focus", stylebox)
	button.add_theme_stylebox_override(&"disabled_mirrored", stylebox)
	button.add_theme_stylebox_override(&"disabled", stylebox)
	button.add_theme_stylebox_override(&"hover_pressed_mirrored", stylebox)
	button.add_theme_stylebox_override(&"hover_pressed", stylebox)
	button.add_theme_stylebox_override(&"hover_mirrored", stylebox)
	button.add_theme_stylebox_override(&"hover", stylebox)
	button.add_theme_stylebox_override(&"pressed_mirrored", stylebox)
	button.add_theme_stylebox_override(&"pressed", stylebox)
	button.add_theme_stylebox_override(&"normal_mirrored", stylebox)
	button.add_theme_stylebox_override(&"normal", stylebox)
	
	# Add to titlebar.
	var title_bar := get_titlebar_hbox()
	button.custom_minimum_size = Vector2(title_bar.size.y, 0)
	title_bar.add_child(button)
	title_bar.move_child(button, index)
	return button

## Called to update the visual properties of our node.
func _update_appearance():
	if resource:
		## Setup node title.
		if title != resource.to_string():
			title = resource.to_string()
			var style_box := _get_title_bar_stylebox()
			style_box.bg_color = resource.get_graph_node_color() * 0.7
			var selected_style_box := _get_title_bar_stylebox()
			selected_style_box.bg_color = resource.get_graph_node_color() * 0.85
			add_theme_stylebox_override(&"titlebar", style_box)
			add_theme_stylebox_override(&"titlebar_selected", selected_style_box)
		
		## Create new connection labels.
		var connection_count := get_connection_count()
		var label_count := connection_labels.size()
		for i in range(connection_count - label_count):
			var idx := label_count + i
			var label := _make_connection_label(idx)
			connection_labels.append(label)
			add_child(label)
		
		## Remove old labels.
		for i in range(connection_labels.size() - connection_count):
			var label := connection_labels.pop_back()
			label.queue_free()
		
		## Update all slots.
		for child in get_children():
			_update_slot(child)
		
		## Setup resource calls here.
		if not _has_called_resource_ready:
			resource._editor_ready(graph_edit, self)
			_has_called_resource_ready = true
		resource._editor_process(graph_edit, self)
	else:
		## Cleanup node title.
		title = ""
		remove_theme_stylebox_override(&"titlebar")
		remove_theme_stylebox_override(&"titlebar_selected")
	size = Vector2.ZERO

## Called to create a connection label.
func _make_connection_label(idx := 0) -> Control:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(0, 15)
	label.text = "#%s" % idx
	return label

## Called to update a connection label.
func _update_slot(control: Control):
	var slot_idx := get_children().find(control)
	if control in connection_labels:
		var input_connections: int = resource.get_input_connections()
		var output_connections: int = resource.get_output_connections()
		var label_idx: int = connection_labels.find(control)
		set_slot(slot_idx,
			label_idx < input_connections, 0, Color.WHITE,
			label_idx < output_connections, 0, Color.WHITE,
			null, null, false
		)
	else:
		set_slot_enabled_left(slot_idx, false)
		set_slot_enabled_right(slot_idx, false)

## Returns the number of connection labels present.
func get_connection_count() -> int:
	if not resource:
		return 0
	return max(resource.get_input_connections(), resource.get_output_connections())

## Returns the stylebox for the title bar.
static func _get_title_bar_stylebox() -> StyleBox:
	return preload("uid://bpo13ng8wfo8w").duplicate()
