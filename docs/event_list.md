# Event List

This document lists information about all built-in Events within the addon.

## Animate

- `AnimationPlayer`
  - Targets an AnimationPlayer in the scene and plays an Animation defined on it.
  - Emits done once the animation is complete.
- `Wait`
  - Waits a certain amount of time, then emits done.

## Control

- `Await Event`
  - Accepts another Event as input (copy the target event and set it by reference).
  - Will not emit done until that Event has emitted done (the target Event can also emit done in advance).
    - I've run into strange deadlocking issues with this Event on occasion -- try resetting the target Event if there are issues.
- `Await Signal`
  - Will not emit done until a target signal is received.
- `Modify State`
  - Modifies the state dictionary of the Event.
- `Router: FuncBool`
  - Calls a function on a node in the scene. Splits between two branches depending on if the function returns TRUE or FALSE.
- `Router: Plays`
  - Splits between different branches depending on how many times the EventPlayer has been called.
- `Router: Random`
  - Selects a random branch.
- `Router: Signal Multiplex`
  - A multiplex version of Await Signal, chooses the branch of the first signal to be emitted.
- `Router: Signal Result`
  - Selects a branch based on an integer result of a signal.
- `Router: State`
  - Selects a branch based on values defined in the Event's state dictionary.

## Meta

- `Comment`
  - Displays a RichTextLabel in the editor.
  - Has no I/O ports.
- `Event`
  - An event which does nothing except emit done instantly.
  - Can be used to organize connections.
- `Event Reference`
  - Calls an event by reference, inheriting its interval and possible branches.
  - Can be useful to avoid duplicating implemented events.
- `MultiEvent`
  - You can nest MultiEvents inside of other MultiEvents.
  - Has branches depending on the unfulfilled output branches of internal Events.
- `MultiEvent End`
  - Forces the current MultiEvent to emit done immediately.
- `Print to Console`
  - Prints a rich message to the console.

## Script

- `Callable`
  - Calls a function on any Node in the scene.
  - Has a state equivalent, which calls a function from the state dictionary (set externally).
- `Property`
  - Changes a property on any Node in the scene.
  - Can lerp between two values.
  - Has a state equivalent, which sets a property on a node from the state dictionary (set externally).
- `Signal`
  - Emits a signal on any Node in the scene.
  - Has a state equivalent, which emits a signal on a node from the state dictionary (set externally).
