tool
extends EditorPlugin

var gocoTools

func _enter_tree():
	gocoTools = preload("res://addons/goco/GocoTools.tscn").instance()
	add_control_to_bottom_panel(gocoTools, "Goco Tools")


func _exit_tree():
	remove_control_from_bottom_panel(gocoTools)
	gocoTools.free()
