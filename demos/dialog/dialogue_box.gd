@tool
extends Control
class_name DialogueBox

const DIALOGUE_SIZE := Vector2(400, 30)
const DIALOGUE_GROW := 23
const DURATION_PER_CHAR := 0.02

signal on_confirm()

@onready var panel: Panel = $Panel
@onready var rich_text_label: RichTextLabel = $Panel/RichTextLabel
@onready var continue_label: Label = $ContinueLabel

@export_multiline var text := "":
	set(x):
		if text == x:
			return
		text = x
		if is_node_ready():
			rich_text_label.text = x
		custom_minimum_size = calculate_minimum_size()

@export var can_continue := false:
	set(x):
		can_continue = x
		if is_node_ready():
			continue_label.visible = x

func _ready() -> void:
	continue_label.visible = false

func start():
	# Setup dialogue box.
	custom_minimum_size = calculate_minimum_size()
	rich_text_label.visible_characters = 0
	continue_label.hide()
	
	# Perform appear interval.
	Parallel.new([
		# The height of the box rises in over time.
		LerpProperty.setup(
			self, ^"custom_minimum_size:y", 0.6,
			custom_minimum_size.y
		).values(0).interp(Tween.EASE_OUT, Tween.TRANS_EXPO),
		
		# The box's panel slides in from the right.
		LerpProperty.setup(
			self, ^"position:x", 0.6, -custom_minimum_size.x - continue_label.size.x
		).interp(Tween.EASE_OUT, Tween.TRANS_EXPO)
	]).as_tween(self)
	
	custom_minimum_size.y = 0
	size = custom_minimum_size
	
	# Setup character readout sequence.
	var character_count := rich_text_label.get_total_character_count()
	Sequence.new([
		# Read off all of the characters.
		LerpProperty.setup(
			rich_text_label, ^"visible_characters",
			DURATION_PER_CHAR * character_count,
			character_count
		),
		
		# Set can continue flag.
		SetProperty.new(self, &"can_continue", true),
	]).as_tween(self)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not can_continue:
		return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Z:
			can_continue = false
			on_confirm.emit()
			accept_event()

func calculate_minimum_size() -> Vector2:
	if not is_node_ready():
		return DIALOGUE_SIZE
	return Vector2(
		rich_text_label.get_content_width() + 20,
		DIALOGUE_SIZE.y + DIALOGUE_GROW * text.count('\n')
	)
