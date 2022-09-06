tool extends CenterContainer

signal pressed()

var tileset_title:String = "Tileset"
var tileset_path:String

onready var button = $Button
onready var lineEdit = $LineEdit

var button_pressed_last:int = 0

func _ready():
	button.text = tileset_title
	lineEdit.text = tileset_title
	button.connect("button_up", self, "_button_pressed")
	lineEdit.connect("text_entered", self, "_on_text_entered")
	lineEdit.connect("mouse_exited", self, "_on_lineedit_mouse_exited")


func selected(selected:bool):
	button.pressed = selected


func _on_lineedit_mouse_exited():
	stop_edit()

func _button_pressed():
	var time = OS.get_ticks_msec()
	var elapsed = time - button_pressed_last
	if elapsed <= 400:
		start_edit()
	else:
		emit_signal("pressed")
	button_pressed_last = time

func start_edit():
	button.hide()
	lineEdit.show()
	lineEdit.grab_click_focus()

func stop_edit():
	lineEdit.hide()
	button.show()
	button.grab_click_focus()

func _on_text_entered(new_name:String):
	if new_name.length() > 0:
		stop_edit()
