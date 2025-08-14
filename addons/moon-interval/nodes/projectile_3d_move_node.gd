@tool
@icon("res://addons/moon-interval/icons/projectile_3d_move_node.png")
extends IntervalNode
class_name Projectile3DMoveNode
## Moves a node as a projectile.

@export var node: Node3D
@export var _start: Vector3
@export var end: Vector3
@export_range(0.0, 8.0, 0.01, "or_greater") var duration := 0.0
@export var gravity := 0.0
@export var ease := Tween.EASE_IN_OUT
@export var trans := Tween.TRANS_LINEAR

func as_interval() -> Interval:
	var d := duration
	var e := ease
	var t := trans
	var p := get_parent()
	if p is IntervalContainerNode:
		if p.has_duration_override():
			d = p.duration_override
		if p.has_ease_override():
			e = p.ease_override
		if p.has_trans_override():
			t = p.trans_override
	return Projectile3DMove.new(node, d, _start, end, gravity, e, t)

func reset():
	if node:
		node.position = _start

static func _get_editor_category() -> String:
	return "3D"
