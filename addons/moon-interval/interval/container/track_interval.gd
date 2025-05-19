@icon("res://addons/moon-interval/icons/interval_container.png")
extends IntervalContainer
class_name TrackInterval
## An IntervalContainer that plays all of its elements based on a supplied time value.
## TrackIntervals should be created in the following format:
## TrackInterval.new([
##     [1.0, Func.new(print.bind("Hello world")],
##     [2.0, Func.new(print.bind("Goodbye world")],
## ])

func _init(p_intervals: Array = []) -> void:
	super(p_intervals)
	for entry: Array in p_intervals:
		assert(entry.size() == 2, "Track entry %s must contain exactly 2 elements." % [entry])
		assert((typeof(entry[0]) in [TYPE_INT, TYPE_FLOAT]) and entry[1] is Interval, "Track entry %s must contain exactly one int/float and one Interval." % [entry])

func _onto_tween(_owner: Node, tween: Tween):
	if not intervals:
		return
	var entries := []
	for ival_arr: Array in intervals:
		entries.append(Sequence.new([Wait.new(ival_arr[0]), ival_arr[1]]))
	var parallel := Parallel.new(entries)
	parallel._onto_tween(_owner, tween)

func get_duration() -> float:
	var largest_dur := 0.0
	for ival_arr: Array in intervals:
		var arr_dur: float = ival_arr[0] + ival_arr[1].get_duration()
		if arr_dur > largest_dur:
			largest_dur = arr_dur

	return largest_dur
