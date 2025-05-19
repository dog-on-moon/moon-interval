@tool
extends Event
class_name RefPropertyEvent
## Sets a property on a node.

## The NodePath grabbed through the state dictionary.
@export var node_name_in_state := &""
@export var use_indexing := false
@export var node_index := 0
@export var property: String = ""
@export var type: Variant.Type = TYPE_NIL:
	set(x):
		type = x
		notify_property_list_changed()

@export_storage var value: Variant

@export_range(0.0, 5.0, 0.01, "or_greater") var duration := 0.0:
	set(x):
		duration = x
		notify_property_list_changed()

@export_storage var ease := Tween.EASE_IN_OUT
@export_storage var trans := Tween.TRANS_LINEAR
@export_storage var flags := 0:  # 1 = relative, 2 = has_initial
	set(x):
		flags = x
		notify_property_list_changed()

@export_storage var initial_value: Variant

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var nodes: Array = []
	var value = _state[node_name_in_state]
	if value is Node:
		nodes.append(value)
	elif value is Array:
		if use_indexing:
			value = value[node_index]
			if value is Node:
				nodes.append(value)
			elif value is Array:
				nodes.append_array(value)
		else:
			nodes.append_array(value)
	else:
		assert(false)
	
	var ivals: Array[Interval] = []
	for node: Node in nodes:
		assert(property in node)
		ivals.append(Sequence.new([
			(
				Func.new(func (): node[property] = value)
			) if not duration else (
				LerpProperty.setup(node, property, duration, value)\
				.values(initial_value if flags & 2 else null, flags & 1)\
				.interp(ease, trans)
			),
			Func.new(done.emit)
		]))
	
	return Sequence.new([
		Sequence.new(ivals),  # would be parallel, but alas, cannot nest yet,
		Func.new(done.emit)
	])

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Script"

static func get_graph_node_title() -> String:
	return "(State) Property"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	var displayed_name := node_name_in_state + "[%s]" % node_index if use_indexing else node_name_in_state
	var string := "[b]%s.%s[/b]\n" % [displayed_name, property]
	if duration and flags & 2:
		string += "%s " % initial_value
	string += "%s %s" % ["+" if flags & 1 else "=>", value]
	if duration:
		string += "\n%s seconds" % duration
	return string

static func get_graph_node_color() -> Color:
	return FuncEvent.get_graph_node_color()
#endregion

#region Property Internal
func _validate_property(p: Dictionary):
	if type == TYPE_NIL:
		return
	
	## Now do logic.
	if p.name == "value":
		p.type = type
		p.usage ^= PROPERTY_USAGE_EDITOR
	elif duration:
		match p.name:
			"initial_value":
				if flags & 2:
					p.type = type
					p.usage ^= PROPERTY_USAGE_EDITOR
			"ease":
				p.usage += PROPERTY_USAGE_EDITOR
				p.class_name = "Tween.EaseType"
				p.type = 2
				p.hint = 2
				p.hint_string = "Ease In:0,Ease Out:1,Ease In Out:2,Ease Out In:3"
				p.usage = 69638
			"trans":
				p.usage += PROPERTY_USAGE_EDITOR
				p.class_name = "Tween.TransitionType"
				p.type = 2
				p.hint = 2
				p.hint_string = "Trans Linear:0,Trans Sine:1,Trans Quint:2,Trans Quart:3,Trans Quad:4,Trans Expo:5,Trans Elastic:6,Trans Cubic:7,Trans Circ:8,Trans Bounce:9,Trans Back:10,Trans Spring:11"
				p.usage = 69638
			"flags":
				p.type = 2
				p.hint = 6
				p.hint_string = "Relative:1,Has Initial:2"
				p.usage = 4102
		

func _property_can_revert(p: StringName) -> bool:
	if p in [&"value", &"initial_value", &"ease", &"flags"]:
		return true
	return false

func _property_get_revert(p: StringName) -> Variant:
	match p:
		&"value", &"initial_value":
			return null
		&"ease":
			return Tween.EASE_IN_OUT
		&"trans":
			return Tween.TRANS_LINEAR
		&"flags":
			return 0
	return null

#endregion
