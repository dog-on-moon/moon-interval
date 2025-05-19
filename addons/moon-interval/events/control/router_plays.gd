@tool
extends RouterBase
class_name RouterPlays
## Routing based on number of times the EventPlayer has been played.

@export_range(1, 8, 1, "or_greater") var play_branches := 3

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(func (): chosen_branch = mini(_state["PLAYS"], play_branches) - 1),
		Func.new(done.emit)
	])

func get_branch_count() -> int:
	return play_branches

static func get_graph_node_title() -> String:
	return "Router: Plays"

static func is_in_graph_dropdown() -> bool:
	return true

func get_branch_names() -> Array:
	var base_list: Array[String] = []
	for i in get_branch_count():
		if i < (get_branch_count() - 1):
			base_list.append("Play #%s" % (i + 1))
		else:
			base_list.append("otherwise,")
	return base_list

func get_branch_index() -> int:
	return chosen_branch
