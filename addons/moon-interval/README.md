![screen-shot](https://github.com/fauxhaus/godot-intervals/blob/main/readme/banner.png)

# Godot Intervals

Intervals is a lightweight animation plugin for Godot 4.3 designed to supplement both Tweens and AnimationPlayer by providing powerful, dynamic alternatives.
This plugin is created based on what I felt was lacking from Godot in regards to efficient animation development, and I hope it will serve your purposes too.

The plugin features two separate, powerful libraries for animations: **Intervals** and **Events**.

## Intervals

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
		Func.new(func (): can_continue = true),
	]).as_tween(self)
```

The complete list of built-in Intervals are listed below (note that it is easy to extend the base Interval and create your own):
1. **Func** - Performs a function call. Equivalent to `tween.tween_callback(callable)`.
2. **LerpFunc** - Calls a method with a singular argument, lerping between two values. Equivalent to `tween.tween_method(...)`.
3. **LerpProperty** - Lerps a property between two values on a given object. Equivalent to `tween.tween_property(...)`.
4. **Wait** - Waits a certain amount of time. Equivalent to `tween.tween_interval(time)`.
5. **Connect** - Connects a method to a signal.
6. **Sequence** - Performs all of its sub-tweens in order.
7. **Parallel** - Performs all of its sub-tweens simultaneously. *NOTE: A bug prevents us from nesting Sequences or Parallels inside other Parallels :(*
8. **SequenceRandom** - Performs all of its sub-tweens in a random order.

## Events

Events are an Interval resource with playback logic for dynamic cutscenes. They can be used to describe and build clusters of timed actions together. These actions can be blocking, and can be use to build complex, dynamic cutscenes.
While an AnimationPlayer is ideal for creating small, previewable animations, an EventPlayer is ideal for dynamic, branching cutscenes.

Several Event flavors are provided out of the box, but you can extend Event directly to add any kind of complex action for your project.
This pattern allows developers to use Events as the basis for a custom dialogue system, a visual novel engine, or something generally useful for creating dynamic cutscenes in your projects.

Events are contained within a MultiEvent, which can be created by placing an EventPlayer node and adding a new MultiEvent resource. The plugin comes built-in with a MultiEvent editor, the main interface for orchestrating Events together. 

![screen-shot](https://github.com/fauxhaus/godot-intervals/blob/main/readme/pic01.png)

## Documentation

Figure it out yourself! That's part of the fun of Intervals! 💗💐🌸 (Kidding, I'll get to this later...)

The repository does come with a couple of demos.

## Installation

Copy the contents of the `addons` folder into the `addons` folder in your own Godot project. Both `intervals` and `graphedit2` are required. Be sure to enable both plugins from Project Settings.
