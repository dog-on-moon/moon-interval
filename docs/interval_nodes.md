# Interval Nodes

All intervals have a node equivalent, which can be placed and manipulated within the scene tree.

Compared to intervals, they have the following advantages:
1. They can be immediately previewed individually within the editor.
2. Compositing them is more intuitive than Tweens, and much faster than writing code.
3. They can be set to autoplay on ready.
4. Playback can be individually disabled using the active flag.

![video](https://github.com/dog-on-moon/moon-interval/blob/main/docs/images/nodes.gif)

Compositing interval nodes is identical to intervals.
You can use SequenceNodes and ParallelNodes to group them for playback.
