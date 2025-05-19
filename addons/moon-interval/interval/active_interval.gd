extends RefCounted
class_name ActiveInterval
## A container that holds a tween generated from an interval and has some helper functions.
## IMPORTANT NOTE: ActiveIntervals must be assigned to a variable (or otherwise kept in scope),
## otherwise their Tween will instantly cleanup.

## Emitted when the Tween has finished all tweening.
## Never emitted when the Tween is set to infinite looping (see set_loops()).
signal finished
## Emitted when a full loop is complete (see set_loops()), providing the loop index.
## This signal is not emitted after the final loop, use finished instead for this case.
signal loop_finished(loop_count: int)
## Emitted when one step of the Tween is complete, providing the step index.
## One step is either a single Tweener or a group of Tweeners running in parallel.
signal step_finished(idx: int)

## Whether or not to custom_step the tween as it is being killed.
## This is useful if the tween should be at the end of its visual when it dies off.
var autofinish := false

## The owner node in charge of the Tween held by the ActiveInterval.
var owner: Node

## The original interval that created this ActiveInterval.
var source_interval: Interval

## The total duration of this interval
var duration: float:
	get: return source_interval.get_duration()

## How much time is remaining in this interval
var time_remaining: float:
	get: return max(duration - tween.get_total_elapsed_time(), 0.0)

## The tween created and contained by this ActiveInterval
var tween: Tween

func _init(_owner: Node, _si: Interval, _tween: Tween, _autofinish := false) -> void:
	owner = _owner
	source_interval = _si
	tween = _tween
	autofinish = _autofinish
	tween.finished.connect(finished.emit)
	tween.loop_finished.connect(loop_finished.emit)
	tween.step_finished.connect(step_finished.emit)

## Destroys the tween and, if autofinish is enabled, calls custom_step()
## to bring it to the end of its animation guaranteed.
## This function is automatically called when the ActiveInterval is killed to clean up
## the tween its tied to.
func _kill_tween(t: Tween, _duration: float) -> void:
	if t and t.is_valid():
		if autofinish:
			t.custom_step(max(0.0, _duration - tween.get_total_elapsed_time()) + 0.01)
		t.kill()

## Forces the tween to finish, skipping to the end.
func finish():
	autofinish = true
	_kill_tween(tween, duration)
	finished.emit()

func set_time(t: float) -> ActiveInterval:
	custom_step(t - tween.get_total_elapsed_time())
	return self

func sync_time() -> ActiveInterval:
	set_time(float(Time.get_ticks_msec()) * 0.001)
	return self

#region Tween Hooks
# The following is here mostly for compatibility purposes with existing code.

## Returns the total time in seconds the Tween has been animating
## (i.e. the time since it started, not counting pauses etc.).
## The time is affected by set_speed_scale(), and stop() will reset it to 0.
## Note: As it results from accumulating frame deltas, the time returned
## after the Tween has finished animating will be slightly greater
## than the actual Tween duration.
func get_total_elapsed_time() -> float:
	return tween.get_total_elapsed_time()

## Returns the number of remaining loops for this Tween (see set_loops()).
## A return value of -1 indicates an infinitely looping Tween, and a return value of 0
## indicates that the Tween has already finished.
func get_loops_left() -> int:
	return tween.get_loops_left()

## Returns whether the Tween is currently running, i.e. it wasn't paused and it's not finished.
func is_running() -> bool:
	return tween.is_running()

## Returns whether the Tween is valid. A valid Tween is a Tween contained by the scene tree
## (i.e. the array from SceneTree.get_processed_tweens() will contain this Tween).
## A Tween might become invalid when it has finished tweening, is killed,
## or when created with Tween.new(). Invalid Tweens can't have Tweeners appended.
func is_valid() -> bool:
	return tween.is_valid()

## Resumes a paused or stopped Tween.
func play() -> void:
	tween.play()

## Pauses the tweening. The animation can be resumed by using play().
## Note: If a Tween is paused and not bound to any node,
## it will exist indefinitely until manually started or invalidated.
## If you lose a reference to such Tween, you can retrieve it using SceneTree.get_processed_tweens().
func pause() -> void:
	tween.pause()

## Stops the tweening and resets the Tween to its initial state.
## This will not remove any appended Tweeners.
## Note: This does not reset targets of PropertyTweeners to their values when the Tween first started.
func stop() -> void:
	tween.stop()

## Processes the Tween by the given delta value, in seconds. This is mostly useful for
## manual control when the Tween is paused. It can also be used to end the Tween
## animation immediately, by setting delta longer than the whole duration of the Tween animation.
## Returns true if the Tween still has Tweeners that haven't finished.
func custom_step(delta: float) -> void:
	tween.custom_step(delta)

## Determines whether the Tween should run after process frames (see Node._process())
## or physics frames (see Node._physics_process()).
## Default value is TWEEN_PROCESS_IDLE.
func set_process_mode(mode: Tween.TweenProcessMode) -> ActiveInterval:
	tween.set_process_mode(mode)
	return self

## Sets the default transition type for PropertyTweeners and MethodTweeners appended after this method.
## Before this method is called, the default transition type is TRANS_LINEAR.
func set_trans(trans: Tween.TransitionType) -> ActiveInterval:
	tween.set_trans(trans)
	return self

## Sets the default ease type for PropertyTweeners and MethodTweeners appended after this method.
## Before this method is called, the default ease type is EASE_IN_OUT.
func set_ease(ease: Tween.EaseType) -> ActiveInterval:
	tween.set_ease(ease)
	return self

## Scales the speed of tweening. This affects all Tweeners and their delays.
func set_speed_scale(speed: float) -> ActiveInterval:
	tween.set_speed_scale(speed)
	return self

## If ignore is true, the tween will ignore Engine.time_scale and update with the real, elapsed time.
## This affects all Tweeners and their delays. Default value is false.
func set_ignore_time_scale(ignore: bool = true) -> ActiveInterval:
	tween.set_ignore_time_scale(ignore)
	return self

## Sets the number of times the tweening sequence will be repeated,
## i.e. set_loops(2) will run the animation twice.
## Calling this method without arguments will make the Tween run infinitely,
## until either it is killed with kill(), the Tween's bound node is freed,
## or all the animated objects have been freed (which makes further animation impossible).
## Warning: Make sure to always add some duration/delay when using infinite loops.
## To prevent the game freezing, 0-duration looped animations
## (e.g. a single CallbackTweener with no delay) are stopped after a small number of loops,
## which may produce unexpected results.
## If a Tween's lifetime depends on some node, always use bind_node().
func set_loops(loops: int = 0) -> ActiveInterval:
	tween.set_loops(loops)
	return self

#endregion

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_kill_tween(tween, duration)
