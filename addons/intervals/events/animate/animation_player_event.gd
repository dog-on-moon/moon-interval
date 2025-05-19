@tool
extends Event
class_name AnimationPlayerEvent
## Plays an animation on an AnimationPlayer.

@export_node_path("AnimationPlayer") var animation_player_np: NodePath = ^"":
	set(x):
		animation_player_np = x
		if _inspect_node_button:
			_inspect_node_button.visible = _node_exists()
@export var animation_name: StringName

var _inspect_node_button: Button = null
var _editor_owner: Node = null

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var animation_player: AnimationPlayer = _owner.get_node(animation_player_np)
	animation_player.animation_finished.connect(done.emit, CONNECT_ONE_SHOT)
	return Func.new(animation_player.play.bind(animation_name))

#region Base Editor Overrides
func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	var owner := get_editor_owner(_edit)
	return (("%s\n[b]Animation:[/b] %s" % [
		get_node_path_string(owner, animation_player_np),
		animation_name if animation_name else "undefined"
	]) if _anim_present() else "[b][color=orange]Animation Not Found"
	) if _node_exists() else "[b][color=red]Invalid AnimationPlayer"

static func get_graph_dropdown_category() -> String:
	return "Animate"

static func get_graph_node_title() -> String:
	return "AnimationPlayer"

static func get_graph_node_color() -> Color:
	return Color(0.765, 0.557, 0.945, 1.0)

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_editor_owner = get_editor_owner(_edit)
	_inspect_node_button = _element._add_titlebar_button(1, "", preload("uid://dogu5nl2t0e3o"))
	_inspect_node_button.pressed.connect(_on_inspect)
	_inspect_node_button.visible = _node_exists()

func _on_inspect():
	if _node_exists():
		EditorInterface.inspect_object(_editor_owner.get_node(animation_player_np))
#endregion

#region Node Finding Logic
func _node_exists() -> bool:
	if not _editor_owner:
		return false
	var node: Node = _editor_owner.get_node_or_null(animation_player_np)
	return node != null and node is AnimationPlayer

func _anim_present() -> bool:
	if not _node_exists():
		return false
	var node: AnimationPlayer = _editor_owner.get_node(animation_player_np)
	return node.has_animation(animation_name)
#endregion
