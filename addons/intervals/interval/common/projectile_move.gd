extends Interval
class_name Projectile3DMove
## Moves a Node3D in a vertical arc from a start to an end point.
## The start and end point are guaranteed, the vertical velocity is automatically
## determined based on the gravity defined (pixels per second).

var node_3d: Node3D
var duration: float
var _start: Vector3
var end: Vector3
var gravity: float
var ease: Tween.EaseType
var trans: Tween.TransitionType

var initial_velocity: float

func _init(p_node_3d: Node3D,
		p_duration: float,
		p_start: Vector3,
		p_end: Vector3,
		p_gravity: float = 100.0,
		p_ease := Tween.EASE_IN_OUT,
		p_trans := Tween.TRANS_LINEAR) -> void:
	node_3d = p_node_3d
	duration = p_duration
	_start = p_start
	end = p_end
	gravity = p_gravity
	ease = p_ease
	trans = p_trans

func _onto_tween(_owner: Node, tween: Tween):
	## Determine the initial velocity.
	## Shoutouts to google!!
	var displacement := end.y - _start.y
	initial_velocity = (displacement / duration) - (0.5 * gravity * duration)
	
	## Perform the tween.
	tween.tween_method(_update_pos, 0.0, 1.0, duration).set_ease(ease).set_trans(trans)

func _update_pos(t: float):
	var time := lerpf(0.0, duration, t)
	var xpos := lerpf(_start.x, end.x, t)
	var ypos := _start.y + (initial_velocity * time) + (0.5 * gravity * pow(time, 2))
	var zpos := lerpf(_start.z, end.z, t)
	node_3d.position = Vector3(xpos, ypos, zpos)

static func calculate_pos(t: float, d: float, s: Vector3, e: Vector3, g: float) -> Vector3:
	var dp := e.y - s.y
	var iv := (dp / d) - (0.5 * g * d)
	
	var time := lerpf(0.0, d, t)
	var _xpos := lerpf(s.x, e.x, t)
	var _ypos := s.y + (iv * time) + (0.5 * g * pow(time, 2))
	var _zpos := lerpf(s.z, e.z, t)
	return Vector3(_xpos, _ypos, _zpos)

func get_duration() -> float:
	return duration

static func determine_end_velocity(DURATION: float, START: Vector3, END: Vector3, GRAVITY: float):
	const THETA := 0.001
	var t := inverse_lerp(0.0, DURATION, DURATION - THETA)
	var a := calculate_pos(t, DURATION, START, END, GRAVITY)
	var b := calculate_pos(1.0, DURATION, START, END, GRAVITY)
	return (b - a) / THETA
