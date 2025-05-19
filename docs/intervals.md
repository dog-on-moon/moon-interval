# Intervals

Intervals are an object representation of a Tween action. They can be used with GDScript to quickly prototype simple animations with variables in a way that circumvents the need and overhead of an AnimationPlayer. The syntax for Intervals is based off of [Panda3D's Interval implementation](https://docs.panda3d.org/1.10/python/programming/intervals/sequences-and-parallels).

Intervals are entirely based on Godot's Tween system. You can call `Interval.as_tween(owner: Node)` on any Interval to return an active Tween. This keeps the implementation for Intervals simple while offering the same level of stability and quality as Tweens, and makes them effectively a drop-in replacement for Tweens.

## Interval List

The complete list of built-in Intervals are listed below (note that it is easy to extend the base Interval and create your own):
1. **Func** - Performs a function call. Equivalent to `tween.tween_callback(callable)`.
2. **LerpFunc** - Calls a method with a singular argument, lerping between two values. Equivalent to `tween.tween_method(...)`.
3. **LerpProperty** - Lerps a property between two values on a given object. Equivalent to `tween.tween_property(...)`.
4. **SetProperty** - Sets a property on a given object.
5. **Wait** - Waits a certain amount of time. Equivalent to `tween.tween_interval(time)`.
6. **Connect** - Connects a method to a signal.
7. **Sequence** - Performs all of its sub-intervals in order.
8. **Parallel** - Performs all of its sub-intervals simultaneously. *NOTE: A bug prevents us from nesting Sequences or Parallels inside other Parallels :(*
9. **SequenceRandom** - Performs all of its sub-intervals in a random order.

## ActiveInterval

Instead of calling `Interval.as_tween`, you can call `Interval.start` for an `ActiveInterval` object.

An ActiveInterval is a RefCounted container for a Tween. Upon losing reference, the Tween will automatically be cancelled.

This can be used to automatically prevent multiple of the same kind of Tween from running in code.

```gdscript
## All ActiveIntervals must have a reference to them stored,
## otherwise they will be immediately cleaned up!!
var _flash_tween: ActiveInterval

func add_score(x: int):
	## Setting this value cleans up the last ActiveInterval assigned to _flash_tween,
	## meaning only one flash Tween will ever be active.
	_flash_tween = LerpProperty.setup(self, ^"modulate", 0.5, Color.WHITE).values(Color.YELLOW).start(self)
```

## Interval vs. Tween

The main advantage of Intervals is that they represent a Tween action as an object, making them more compatible with various programming patterns. The syntax of an Interval is easier to interpret than a Tween function call (especially with more complex Tweens), and can support nesting with Sequences and Parallels.

### Color Fades

A common example of an Interval is to fade a CanvasItem's modulate. For individual Intervals, the similarity with Tweens is very apparent.

![demo-gif](https://github.com/dog-on-moon/moon-interval/blob/main/docs/images/fade.gif)

```gdscript
## Interval example
static func make_fade_interval_tween(control: Control, duration := 0.5, alpha := 0.0) -> Tween:
    return LerpProperty.new(control, ^"modulate:a", duration, alpha).as_tween(control)

## Tween example
static func make_fade_tween(control: Control, duration := 0.5, alpha := 0.0) -> Tween:
    return control.create_tween().tween_property(control, ^"modulate:a", alpha, duration)
```

### Batched UI Movement

You can use Tweens to batch dynamic UI movement together. Intervals can be grouped using Sequences and Parallels.

![demo-gif](https://github.com/dog-on-moon/moon-interval/blob/main/docs/images/ui.gif)

```gdscript
## Interval example
func make_spawn_interval_tween() -> Tween:
	var ivals: Array[Interval] = []

	# Iterate over each Control child.
	for control: Control in get_children():
		const SPAWN_POS := Vector2(0, 200)
		const DURATION := 0.25
		
		ivals.append(Parallel.new([
			# Make the control visible
			SetProperty.new(control, &"visible", true),
			
			# Move them into position (moving relative from their current position)
			LerpProperty.setup(control, ^"position", DURATION, -SPAWN_POS)\
				.values(control.position + SPAWN_POS, true)\
				.interp(Tween.EASE_OUT, Tween.TRANS_CIRC),
			
			# Cool spin-in as well
			LerpProperty.setup(control, ^"rotation", DURATION, 0.0)\
				.values(deg_to_rad(-90.0)).interp(Tween.EASE_OUT, Tween.TRANS_CIRC),
		]))

	# Return our interval, spawning each control in sequence.
	return Sequence.new(ivals).as_tween(self)

## Tween example
func make_spawn_tween() -> Tween:
	var tween := create_tween()
	
	# Iterate over each Control child.
	for control: Control in get_children():
		const SPAWN_POS := Vector2(0, 200)
		const DURATION := 0.25
		
		# Make the control visible
		tween.tween_callback(func (): control.set(&"visible", true))
		tween.parallel()
		
		# Move them into position (moving relative from their current position)
		tween.tween_property(control, ^"position", -SPAWN_POS, DURATION)\
			.from(control.position + SPAWN_POS).as_relative()\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.parallel()
		
		# Cool spin-in as well
		tween.tween_property(control, ^"rotation", 0.0, DURATION)\
			.from(deg_to_rad(-90.0))\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.chain()

	# Return our interval, spawning each control in sequence.
	return tween
```

## Custom Intervals

It is possible to create custom Interval classes if you desire common animations for your scripts. Create a class which extends `Interval` and override `Interval._onto_tween(tween: Tween)`.

### Visibility

This is a custom interval which implements the fade example from above as a reusable Interval.

```gdscript
extends Interval
class_name CanvasItemVisibility

var canvas_item: CanvasItem
var duration: float
var visibility: float

func _init(p_canvas_item: CanvasItem = null,
		p_duration := 1.0,
		p_visibility: := 1.0) -> void:
	canvas_item = p_canvas_item
	duration = p_duration
	visibility = p_visibility

func _onto_tween(tween: Tween):
	tween.tween_property(canvas_item, ^"modulate:a", visibility, duration)
```

### Projectile Move

This is a complex custom interval which implements projectile motion on a Node2D between start and end positions. The vertical arc is automatically calculated.

![demo-gif](https://github.com/dog-on-moon/moon-interval/blob/main/docs/images/projectile.gif)

```gdscript
extends Interval
class_name Projectile2DMove
## Moves a Node2D in a vertical arc from a start to an end point.
## The start and end point are guaranteed, the vertical velocity is automatically
## determined based on the gravity defined (pixels per second per second).

var node_2d: Node2D
var duration: float
var start: Vector2
var end: Vector2
var gravity: float

func _init(p_node_2d: Node2D,
		p_duration: float,
		p_start: Vector2,
		p_end: Vector2,
		p_gravity: float = 100.0) -> void:
	node_2d = p_node_2d
	duration = p_duration
	start = p_start
	end = p_end
	gravity = p_gravity

func _onto_tween(tween: Tween):
	## Determine the initial velocity.
	var displacement := end.y - start.y
	var initial_velocity := (displacement / duration) - (0.5 * gravity * duration)
	
	## Perform the tween.
	tween.tween_method(func (t: float): 
		var time := lerpf(0.0, duration, t)
		var xpos := lerpf(start.x, end.x, t)
		var ypos := start.y + (initial_velocity * time) + (0.5 * gravity * pow(time, 2))
		node_2d.global_position = Vector2(xpos, ypos)
	, 0.0, 1.0, duration)
```
