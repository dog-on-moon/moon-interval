@tool
@icon("res://addons/moon-interval/icons/projectile_2d_move_node.png")
extends IntervalNode
class_name Projectile2DMoveNode
## Moves a node as a projectile.

@export var node: Node2D
@export var _start: Vector2
@export var end: Vector2
@export_range(0.0, 8.0, 0.01, "or_greater") var duration := 0.0
@export var gravity := 0.0
@export var ease := Tween.EASE_IN_OUT
@export var trans := Tween.TRANS_LINEAR

func as_interval() -> Interval:
	return Projectile2DMove.new(node, duration, _start, end, gravity, ease, trans)

func reset():
	if node:
		node.position = _start
