class_name CoderTreeItem extends Control

signal focus_next()
signal focus_previous()
signal selected()
signal file_renamed(old_path, new_path)
signal edit_cancelled()

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

var is_editing:bool = false

func _ready():
	button.text = path
	lineEdit.text = path
	button.connect("button_down", self, "_on_button_down")
	lineEdit.connect("gui_input", self, "_on_line_edit_input")
	lineEdit.connect("focus_exited", self, "_on_line_edit_focus_exited")

func _on_line_edit_focus_exited():
	if is_editing:
		cancel_edit()


func _on_line_edit_input(input:InputEvent):
	if input.is_action("ui_cancel"):
		cancel_edit()
	elif input.is_action("ui_accept"):
		_on_text_entered(lineEdit.text)

func start_edit():
	button.hide()
	lineEdit.show()
	lineEdit.grab_focus()
	lineEdit.grab_click_focus()
	is_editing = true


func cancel_edit():
	if path == "":
		queue_free()
	else:
		lineEdit.hide()
		button.show()
		button.grab_focus()
		button.grab_click_focus()
	emit_signal("edit_cancelled")
	is_editing = false
	

func set_path(p):
	path = p
	button.text = Array(path.split("/")).pop_back()
	lineEdit.text = path
	

func _on_text_entered(text):
	if text == "":
		cancel_edit()
	
	if not text.ends_with(".gd"):
		text = text + ".gd"
	
	var old_path = path
	
	var p = Array(path.trim_prefix("user://").split("/"))
	p.pop_back()
	p = ES.join(p, "/") + "/" + text
	path = p.trim_prefix("/")
	
	button.text = text
	lineEdit.hide()
	button.show()
	emit_signal("file_renamed", old_path, path)
	

func _on_button_down():
	var time = OS.get_ticks_msec()
	if time - time_last_click <= 400:
		start_edit()
	else:
		emit_signal("selected")
	time_last_click = OS.get_ticks_msec()
