@tool
extends RouterBase
class_name RouterState
## A routing event that picks branches based on state.

enum Operation {
	IS_SET = 0,
	UNSET = 1,
	GREATER_THAN = 2,
	LESS_THAN = 3,
	EQUAL_TO = 4,
	UNEQUAL_TO = 5
}

@export var states := 1:
	set(x):
		var old_s := states
		states = x
		state_names.resize(states)
		operations.resize(states)
		values.resize(states)
		if x > old_s and x > 0:
			state_names[x - 1] = &""
			operations[x - 1] = Operation.IS_SET
			values[x - 1] = 0
		notify_property_list_changed()

@export_storage var state_names: Array[StringName] = [&""]
@export_storage var operations: Array[Operation] = [Operation.IS_SET]
@export_storage var values: Array[int] = [0]

var old_ops: Array[Operation] = []

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(func ():
			## Find the first trigger that passes the check.
			for i in state_names.size():
				var result := false
				var state_value = _state.get(state_names[i], null)
				match operations[i]:
					Operation.IS_SET:
						result = state_value != null
					Operation.UNSET:
						result = state_value == null
					Operation.GREATER_THAN:
						result = (state_value != null) and state_value > values[i]
					Operation.LESS_THAN:
						result = (state_value != null) and state_value < values[i]
					Operation.EQUAL_TO:
						result = (state_value != null) and state_value == values[i]
					Operation.UNEQUAL_TO:
						result = (state_value != null) and state_value != values[i]
				if result:
					chosen_branch = i + 1
					return
			
			## No trigger branches chosen, go with default.
			chosen_branch = 0
			),
		Func.new(done.emit)
	])

func get_branch_count() -> int:
	return states

static func get_graph_node_title() -> String:
	return "Router: State"

static func is_in_graph_dropdown() -> bool:
	return true

#region Branching Logic
func get_branch_names() -> Array:
	var base_list: Array[String] = ["Default"]
	for idx in range(1, get_branch_count() + 1):
		var state_name = get(&"state_name_%s" % idx)
		var operation = get(&"operation_%s" % idx)
		var value = get(&"value_%s" % idx)
		match operation:
			Operation.IS_SET:
				base_list.append('\'%s\' is set' % state_name)
			Operation.UNSET:
				base_list.append('\'%s\' is not set' % state_name)
			Operation.GREATER_THAN:
				base_list.append('\'%s\' > %s' % [state_name, value])
			Operation.LESS_THAN:
				base_list.append('\'%s\' < %s' % [state_name, value])
			Operation.EQUAL_TO:
				base_list.append('\'%s\' == %s' % [state_name, value])
			Operation.UNEQUAL_TO:
				base_list.append('\'%s\' != %s' % [state_name, value])
	return base_list

func get_branch_index() -> int:
	return chosen_branch

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	old_ops = operations.duplicate()

func _editor_process(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	if old_ops != operations:
		old_ops = operations.duplicate()
		notify_property_list_changed()
#endregion

#region Property Logic
func _get_property_list() -> Array[Dictionary]:
	var ret_list: Array[Dictionary] = []
	
	for i in states:
		var idx := i + 1
		ret_list.append({
			"name": "State #%s" % idx, "type": 0,
			"usage": 64
		})
		ret_list.append({
			"name": "state_name_%s" % idx, "type": 21,
			"usage": 4102
		})
		ret_list.append({
			"name": "operation_%s" % idx, "type": 2,
			"class_name": &"RouterState.Operation",
			"hint": 2, "hint_string": "Is Set:0,Unset:1,Greater Than:2,Less Than:3,Equal To:4,Unequal To:5",
			"usage": 69638
		})
		
		var check_op = get(&"operation_%s" % idx)
		if check_op != null and check_op not in [Operation.IS_SET, Operation.UNSET]:
			ret_list.append({
				"name": "value_%s" % idx, "type": 2,
				"usage": 4102
			})
	
	"""
	{ "name": "state_name_", "class_name": &"", "type": 21, "hint": 0, "hint_string": "", "usage": 4102 },
	{ "name": "operation_", "class_name": &"RouterState.Operation", "type": 2, "hint": 2, "hint_string": "Is Set:0,Unset:1,Greater Than:2,Less Than:3,Equal To:4,Unequal To:5", "usage": 69638 },
	{ "name": "value_", "class_name": &"", "type": 2, "hint": 0, "hint_string": "", "usage": 4102 },
	"""
	
	return ret_list

func _property_can_revert(property: StringName) -> bool:
	return property.begins_with("state_name_") \
		or property.begins_with("operation_") \
		or property.begins_with("value_")

func _property_get_revert(property: StringName) -> Variant:
	if property.begins_with("state_name_"):
		return &""
	if property.begins_with("operation_"):
		return Operation.IS_SET
	if property.begins_with("value_"):
		return 0
	return null

func _get(property):
	if property.begins_with("state_name_"):
		var index = property.get_slice("_", 2).to_int() - 1
		return state_names[index]
	if property.begins_with("operation_"):
		var index = property.get_slice("_", 1).to_int() - 1
		return operations[index]
	if property.begins_with("value_"):
		var index = property.get_slice("_", 1).to_int() - 1
		return values[index]

func _set(property, value):
	if property.begins_with("state_name_"):
		var index = property.get_slice("_", 2).to_int() - 1
		state_names[index] = value
		return true
	if property.begins_with("operation_"):
		var index = property.get_slice("_", 1).to_int() - 1
		operations[index] = value
		return true
	if property.begins_with("value_"):
		var index = property.get_slice("_", 1).to_int() - 1
		values[index] = value
		return true
	return false
#endregion
