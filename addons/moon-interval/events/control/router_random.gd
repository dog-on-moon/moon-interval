@tool
extends RouterBase
class_name RouterRandom
## A routing event that chooses a random branch.

@export var branches := 2

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(func (): chosen_branch = 1 + randi_range(0, get_branch_count() - 1)),
		Func.new(done.emit)
	])

func get_branch_count() -> int:
	return branches

static func get_graph_node_title() -> String:
	return "Router: Random"

static func is_in_graph_dropdown() -> bool:
	return true
