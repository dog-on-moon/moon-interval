@icon("res://addons/intervals/icons/interval.png")
extends RefCounted
class_name Interval
## An Interval is an object representation of a Tween action.
## 
## Intervals are a more expressive syntax for Tweens that can be used
## to more easily develop and comprehend complex Tweens in code.
## Intervals are based on Godot's Tween system, and will return an active Tween
## from [method as_tween].
## In addition, subclasses must implement [method _onto_tween].

## Implements the interval onto a specified tween.
## Subclasses must implement this function.
func _onto_tween(_owner: Node, tween: Tween):
	assert(false, "Subclasses must implement this function.")

## Converts the Interval into an active Tween.
## [param _owner] is the Node that the Tween is bound to.
func as_tween(_owner: Node) -> Tween:
	var tween := _owner.create_tween()
	_onto_tween(_owner, tween)
	return tween

## Converts the Interval into an active INTERVAL.
## [param _owner] is the Node that the ActiveInterval is bound to.
func start(_owner: Node, autofinish := false) -> ActiveInterval:
	var tween := as_tween(_owner)
	var ai := ActiveInterval.new(_owner, self, tween, autofinish)
	return ai

func get_duration() -> float:
	return 0.0
