@tool
extends Event
class_name StateEvent
## An event which sets the value of internal state.

@export_enum("Set:0", "Remove:1", "Add:2") var operation := 0:
	set(x):
		operation = x
		notify_property_list_changed()

@export var key := &""

@export_storage var value := 0

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Func.new(func ():
		match operation:
			0:
				_state[key] = value
			1:
				_state.erase(key)
			2:
				_state.get_or_add(key, 0)
				_state[key] += value
		done.emit()
	)

#region Base Editor Overrides
## The category that the event will belong to.
static func get_graph_dropdown_category() -> String:
	return "Control"

## The title of the graph node for this Event.
static func get_graph_node_title() -> String:
	return "Modify State"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	match operation:
		0:
			return "[b]Setting '%s' = %s" % [key, value]
		1:
			return "[b]Removing '%s'" % [key]
		2:
			return "[b]Adding '%s' %s= %s" % [key, "+" if value >= 0 else "-", abs(value)]
	return ""
#endregion

func _validate_property(property: Dictionary) -> void:
	if property.name == "value" and operation != 1:
		property.usage += PROPERTY_USAGE_EDITOR
