@tool
extends EditorPlugin
class_name GraphEdit2Plugin
## GraphEdit2 - GraphEdit classes designed for editor plugin usage
## By Mica
## Icons from GodotEngine

static var undo_redo: EditorUndoRedoManager

func _enter_tree():
	undo_redo = get_undo_redo()
	
	add_custom_type("GraphEditResource", 	"Resource", preload("uid://dih7hadp53mog"), preload("uid://1o8lm8tmy1g3"))
	add_custom_type("GraphElementResource", "Resource", preload("uid://cwuh4uhvd1dpo"), preload("uid://cxni0m345urn8"))
	add_custom_type("GraphFrameResource", 	"GraphElementResource", preload("uid://cv7ghpv2yx3u"), preload("uid://ddx3k8ypctye2"))
	add_custom_type("GraphNodeResource", 	"GraphElementResource", preload("uid://d2efhse1dte0t"), preload("uid://dclqykqb882ww"))
	
	add_custom_type("GraphElement2", "GraphElement", preload("uid://ce1u7joxmkjea"), preload("uid://cee5xma7x7pu3"))
	add_custom_type("GraphFrame2", "GraphFrame", preload("uid://bftwbcnvgb6xq"), preload("uid://droet0fnkyykk"))
	add_custom_type("GraphNode2", "GraphNode", preload("uid://w4scwxammmtq"), preload("uid://cgyqcgt0sg0jl"))
	add_custom_type("GraphEdit2PopupMenu", "PopupMenu", preload("uid://bae7o3fnkpo58"), preload("uid://kibi0q0pdx36"))
	add_custom_type("GraphEdit2", "GraphEdit", preload("uid://crb5dxvgrdsgb"), preload("uid://dstod65e7tgm6"))

func _exit_tree():
	remove_custom_type("GraphEdit2")
	remove_custom_type("GraphEdit2PopupMenu")
	remove_custom_type("GraphNode2")
	remove_custom_type("GraphFrame2")
	remove_custom_type("GraphElement2")
	
	remove_custom_type("GraphNodeResource")
	remove_custom_type("GraphFrameResource")
	remove_custom_type("GraphElementResource")
	remove_custom_type("GraphEditResource")
	
	undo_redo = null
