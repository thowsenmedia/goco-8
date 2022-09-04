class_name CoderTreeItem extends Control

signal focus_next()
signal focus_previous()
signal selected()
signal file_renamed(old_path, new_path)

onready var button = $Button
onready var lineEdit = $LineEdit

enum TYPE {
	FILE,
	DIRECTORY
}

var type = TYPE.FILE
var path:String = ""

var time_last_click:int = 0

var is_saved:bool = false

func _ready():
	button.text = path
	lineEdit.text = path
	button.connect("button_down", self, "_on_button_down")
	lineEdit.connect("text_entered", self, "_on_text_entered")
	lineEdit.connect("gui_input", self, "_on_line_edit_input")

func _on_line_edit_input(input:InputEvent):
	if input.is_action("ui_cancel"):
		cancel_edit()

func start_edit():
	button.hide()
	lineEdit.show()
	lineEdit.grab_focus()
	lineEdit.grab_click_focus()

func cancel_edit():
	lineEdit.hide()
	button.show()
	button.grab_focus()
	button.grab_click_focus()

func _on_text_entered(text):
	var old_path = path
	
	var p = Array(path.trim_prefix("user://").split("/"))
	p.pop_back()
	p = "user://" + ES.join(p, "/") + "/" + text
	p = p.replace("user:///", "user://")
	path = p
	print("new path=" + str(path))
	button.text = text
	lineEdit.hide()
	button.show()
	emit_signal("file_renamed", old_path, path)
	

func _on_button_down():
	var time = OS.get_ticks_msec()
	if time - time_last_click <= 400:
		button.hide()
		lineEdit.show()
		lineEdit.grab_focus()
		lineEdit.grab_click_focus()
	else:
		emit_signal("selected")
	time_last_click = OS.get_ticks_msec()
