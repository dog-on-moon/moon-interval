@tool
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
	return Projectile3DMove.new(node, duration, _start, end, gravity, ease, trans)

func reset():
	if node:
		node.position = _start
