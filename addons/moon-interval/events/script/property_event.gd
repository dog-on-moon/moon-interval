@tool
extends Event
class_name PropertyEvent
## Sets a property on a node.

@export_node_path("Node") var node_path: NodePath = ^"":
	set(x):
		node_path = x
		if _node_button and is_instance_valid(_node_button):
			_node_button.visible = _object_exists()
@export var property: String = "":
	set(x):
		property = x
		if node and (property in node or not property):
			notify_property_list_changed()
		if _node_button and is_instance_valid(_node_button):
			_node_button.visible = _object_exists()

@export_storage var value: Variant

@export_range(0.0, 5.0, 0.01, "or_greater") var duration := 0.0:
	set(x):
		var resets := (is_zero_approx(x) != is_zero_approx(duration)) and _property_valid()
		duration = x
		if resets:
			notify_property_list_changed()

@export_storage var ease := Tween.EASE_IN_OUT
@export_storage var trans := Tween.TRANS_LINEAR
@export_storage var flags := 0:  # 1 = relative, 2 = has_initial
	set(x):
		flags = x
		notify_property_list_changed()

@export_storage var initial_value: Variant

var node: Node:
	get: return _editor_owner.get_node_or_null(node_path) if node_path and _editor_owner and is_instance_valid(_editor_owner) else null

var _node_button: Button = null
var _editor_owner: Node = null

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	assert(property in node)
	return Sequence.new([
		(
			Func.new(func (): node[property] = value)
		) if not duration else (
			LerpProperty.setup(node, property, duration, value)\
			.values(initial_value if flags & 2 else null, flags & 1)\
			.interp(ease, trans)
		),
		Func.new(done.emit)
	])

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Script"

static func get_graph_node_title() -> String:
	return "Property"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	if not _object_exists():
		return "[b][color=red]Invalid Object"
	elif not _property_valid():
		return "[b][color=red]Invalid Property"
	
	var string := "[b]%s.%s[/b]\n" % [get_node_path_string(_editor_owner, node_path), property]
	if duration and flags & 2:
		string += "%s " % _value_to_bbcode(initial_value)
	string += "%s %s" % ["+" if flags & 1 else "=>", _value_to_bbcode(value)]
	if duration:
		string += "\n%s seconds" % duration
	return string

static func get_graph_node_color() -> Color:
	return FuncEvent.get_graph_node_color()

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_editor_owner = get_editor_owner(_edit)
	_node_button = _element._add_titlebar_button(1, "", preload("uid://dogu5nl2t0e3o"))
	_node_button.pressed.connect(_on_inspect)
	_node_button.visible = _object_exists()

func _editor_process(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	# print(get_property_list())
#endregion

#region Property Internal
func _value_to_bbcode(v) -> String:
	if v == null:
		return "null"
	
	## Get the target node's property.
	var node_property: Dictionary = {}
	for p_dict in node.get_property_list():
		if p_dict['name'] == property:
			node_property = p_dict
			break
	if not node_property:
		return "null"
	
	## Do formatting based on expected type.
	match node_property['type']:
		TYPE_COLOR:
			var hex_code: String = v.to_html()
			return "[color=%s]██████[/color]" % hex_code
	return str(v)

func _object_exists() -> bool:
	return node != null

func _property_valid() -> bool:
	return node and property and property in node

func _on_inspect():
	if node:
		EditorInterface.inspect_object(node)

func _validate_property(p: Dictionary):
	if not _property_valid():
		return
	## Get the target node's property.
	var node_property: Dictionary = {}
	for p_dict in node.get_property_list():
		if p_dict['name'] == property:
			node_property = p_dict
			break
	if not node_property:
		return
	
	## Now do logic.
	if p.name == "value":
		p.type = typeof(node[property])
		p.class_name = node_property.class_name
		p.type = node_property.type
		p.hint = node_property.hint
		p.hint_string = node_property.hint_string
		p.usage = node_property.usage
		if not (p.usage & PROPERTY_USAGE_STORAGE):
			p.usage += PROPERTY_USAGE_STORAGE
	elif duration:
		match p.name:
			"initial_value":
				if flags & 2:
					p.type = typeof(node[property])
					p.class_name = node_property.class_name
					p.type = node_property.type
					p.hint = node_property.hint
					p.hint_string = node_property.hint_string
					p.usage = node_property.usage
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
	if not _property_valid():
		return false
	if p in [&"value", &"initial_value", &"ease", &"flags"]:
		return true
	return false

func _property_get_revert(p: StringName) -> Variant:
	if not _property_valid():
		return false
	match p:
		&"value", &"initial_value":
			return node[property]
		&"ease":
			return Tween.EASE_IN_OUT
		&"trans":
			return Tween.TRANS_LINEAR
		&"flags":
			return 0
	return null

#endregion
