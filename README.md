![screen-shot](https://github.com/dog-on-moon/moon-interval/blob/main/readme/banner.png)

# moon-interval

moon-interval is an animation plugin for Godot 4.4 designed to supplement both Tweens and AnimationPlayer by providing powerful, dynamic alternatives.
This plugin is created based on what I felt was lacking from Godot in regards to efficient animation development, and I hope it will serve your purposes too.

The plugin features three separate, powerful libraries for animations:
1. **Intervals**, for complex, animated sequences within GDScript
2. **Interval Nodes**, for  complex animated sequences within the Scene Tree
3. **Events**, for dynamic, blocking, and branching visual scripting.

## ⏳ Intervals - developer-friendly Tweens

Intervals are an object representation of a Tween action. They provide a more expressive syntax for Tweens that can be used to more easily develop, arrange, and comprehend complex Tweens via GDScript.
Calling `Interval.as_tween(self)` compiles down any interval into its equivalent Tween.

```gdscript
func start():
	# Setup dialogue box.
	custom_minimum_size = calculate_minimum_size()
	rich_text_label.visible_characters = 0
	continue_label.hide()
	
	# Perform appear interval.
	# Parallels will perform all of their sub-intervals simultaneously.
	Parallel.new([
		# The height of the box rises in over time.
		LerpProperty.setup(
			self, ^"custom_minimum_size:y", 0.6,
			custom_minimum_size.y
		).values(0).interp(Tween.EASE_OUT, Tween.TRANS_EXPO),
		
		# The box's panel slides in from the right.
		LerpProperty.setup(
			self, ^"position:x", 0.6, -custom_minimum_size.x - continue_label.size.x
		).interp(Tween.EASE_OUT, Tween.TRANS_EXPO)
	]).as_tween(self)
	
	custom_minimum_size.y = 0
	size = custom_minimum_size
	
	# Setup character readout sequence.
	var character_count := rich_text_label.get_total_character_count()
	# Sequences will perform all of their sub-intervals in order.
	Sequence.new([
		# Read off all of the characters.
		LerpProperty.setup(
			rich_text_label, ^"visible_characters",
			DURATION_PER_CHAR * character_count,
			character_count
		),
		
		# Set can continue flag.
		SetProperty.new(self, &"can_continue", true),
	]).as_tween(self)
```

The complete list of built-in intervals are listed below (note that it is easy to extend the base Interval and create your own):
1. **Func** - Performs a function call. Equivalent to `tween.tween_callback(callable)`.
2. **LerpFunc** - Calls a method with a singular argument, lerping between two values. Equivalent to `tween.tween_method(...)`.
3. **LerpProperty** - Lerps a property between two values on a given object. Equivalent to `tween.tween_property(...)`.
4. **SetProperty** - Sets a property on a given object.
5. **Wait** - Waits a certain amount of time. Equivalent to `tween.tween_interval(time)`.
6. **Connect** - Connects a method to a signal.
7. **ProjectileMove2D** - Moves a Node2D between two points, simulating gravity in between.
8. **ProjectileMove3D** - Moves a Node3D between two points, simulating gravity in between.
9. **Sequence** - Performs all of its sub-intervals in order.
10. **Parallel** - Performs all of its sub-intervals simultaneously.
11. **SequenceRandom** - Performs all of its sub-intervals in a random order.
12. **TrackInterval** - Performs all of its sub-intervals at designated times.

## 🛠️ Interval Nodes - verbose scene-tree animation

Interval Nodes are another alternative to the AnimationPlayer, providing a verbose view of a complicated animation within the Scene Tree.

Each node maps onto an existing tween function, and allows the animation of any node in the scene.
They can also be individually controlled and previewed. Their playback is organized using Sequence and Parallel nodes.

![video](https://github.com/dog-on-moon/moon-interval/blob/main/readme/nodes.mp4)

## ⏹️ Events - macroscopic building blocks

Compared to other visual scripting solutions, Events are macroscopic building blocks, allowing you to orchestrate code that you already know works. Where an AnimationPlayer is ideal for creating small, previewable animations, an EventPlayer is ideal for dynamic, branching cutscenes.

Events are a Resource which represent a blocking function call. They can be used to describe and build clusters of timed actions together, with routing logic which supports complex, dynamic cutscenes.

Several Event flavors are provided out of the box, but you can extend Event directly to add any kind of complex action for your project. This pattern allows developers to use Events as the basis for a custom dialogue system, a visual novel engine, or (quite literally) anything that demands dynamic scripting.

![screen-shot](https://github.com/dog-on-moon/moon-interval/blob/main/readme/pic01.png)

## Documentation

For more information, check out my documentation here:
- [Intervals](https://github.com/dog-on-moon/moon-interval/tree/main/docs/intervals.md) - developer-friendly tweens
- [Interval Nodes](https://github.com/dog-on-moon/moon-interval/tree/main/docs/interval_nodes.md) - verbose scene-tree animation
- [Events](https://github.com/dog-on-moon/moon-interval/tree/main/docs/events.md) - macroscopic building blocks
- [List of Events](https://github.com/dog-on-moon/moon-interval/tree/main/docs/event_list.md) - all default Events
- [EventPlayer](https://github.com/dog-on-moon/moon-interval/tree/main/docs/event_player.md) - the node which plays Events
- [Event Editor](https://github.com/dog-on-moon/moon-interval/tree/main/docs/event_editor.md) - the main interface for editing events
- [EventPlayer](https://github.com/dog-on-moon/moon-interval/tree/main/docs/graph_edit_2.md) - some information on the supplementary addon


The Godot project also comes with a couple of demos.

## Installation

This repository contains the plugin for v4.3. Copy the contents of the `addons` folder into the `addons` folder in your own Godot project. Both `intervals` and `graphedit2` are required. Be sure to enable both plugins from Project Settings.

For v4.2.2 support, please install the repository from [vabrador's fork.](https://github.com/vabrador/moon-interval/tree/backport-4.2)
