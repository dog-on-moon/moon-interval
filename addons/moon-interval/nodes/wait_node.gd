@tool
@icon("res://addons/moon-interval/icons/wait_node.png")
extends IntervalNode
class_name WaitNode
## A node that simply waits and does nothing. Awesome

@export_range(0.0, 5.0, 0.01, "or_greater") var time := 1.0

func as_interval() -> Interval:
	return Wait.new(time)
