@tool
extends GraphEdit2

const MultiEventEditor = preload("uid://2337ws3vaecv")

@onready var multi_event_editor: MultiEventEditor = get_parent()

@export var multi_event: MultiEvent:
	set(x):
		multi_event = x
		resource = multi_event.editor_data if multi_event else null

static func get_element_resource_classes() -> Array:
	var events := load_scripts_of_base_class(&"Event")
	# events.erase(Event)
	return events
