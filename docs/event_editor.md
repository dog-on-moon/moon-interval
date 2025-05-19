# Event Editor

The Event Editor is a GraphEdit-based editor integrated into Godot which becomes visible whenever any MultiEvent resource is selected. Within the editor, you can create new Events, edit them (via inspector), and connect them together to create dynamic, branching function calls.

## Routing

There are a couple routing rules for MultiEvents that must be kept in mind.

1. When initialized, all Events with an empty input slot will be called. These events represent the start of each branch.
2. Once an Event is completed (i.e. its resource has emitted its `done` signal), each Event on its output slot will begin.
3. Events will only ever execute once -- this restriction can be lifted by enabling `Allow Cycles`.

An example MultiEvent (with routing edge-cases) is shown here:

![screenshot](https://github.com/dog-on-moon/moon-interval/blob/main/docs/images/event_editor.png)

## Creating Events

To create Events, you can right-click anywhere on the grid to open a dropdown menu of each Event category. Selecting one will create an Event of the selected type at your cursor. To modify the Event's properties, click the magnifying glass button on the header. To remove the event, you can press the delete button on the header.

You can also create an Event by dragging and releasing from the input/output port of an existing Event. This will cause the Events created to automatically connect from the original Event. (You can even copy a whole bunch of Events, drag out from an input/output port, and paste them to cause each pasted Event to connect from the original!)

## MultiEvents

You can name the currently selected MultiEvent in the text entry at the top of the Editor (this is also its `resource_name`).

You can create nested MultiEvents within the Meta tab. Nested MultiEvents are treated like any other Event, and can be used to organize clusters of Events together. (Just do not copy/paste them into eachother or you will die a recursive death...). When in a nested MultiEvent, you can elevate one level by pressing the button that appears at the top-left of the editor.
