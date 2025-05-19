extends Control
class_name CookMaster

signal any_key_pressed

@onready var start_game_sequence: Control = $Control
@onready var music: AudioStreamPlayer = $"../Music"
@onready var color_rect_2: ColorRect = $World/ColorRect2
@onready var light_machine: Node2D = $World/LightMachine
@onready var game_machine: Control = $Control2


func _ready() -> void:
	start_game()

func start_game():
	start_game_sequence.start()
	game_machine.stop()
	color_rect_2.hide()
	music.play()
	light_machine.active = true
	await start_game_sequence.crime
	music.stop()
	color_rect_2.show()
	light_machine.active = false
	await start_game_sequence.complete
	await any_key_pressed
	var label_clone: Label = start_game_sequence.stop()
	add_child(label_clone)
	label_clone.position = Vector2.ONE * 16
	await LerpFunc.new(
		func (x):
			if floori(x) % 2:
				label_clone.visible = [true, false].pick_random()
			else:
				label_clone.visible = true
			, 1.0, 0, 13.0
	).as_tween(self).finished
	label_clone.visible = true
	await get_tree().create_timer(1.0).timeout
	game_machine.show()
	game_machine.start()
	var result: Array = await game_machine.result
	await get_tree().create_timer(1.0).timeout
	var results: Container = game_machine.stop()
	add_child(results)
	results.visible = true
	await any_key_pressed
	label_clone.queue_free()
	results.queue_free()
	start_game()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		any_key_pressed.emit()
