class_name Painter extends Control

onready var canvas = $VBoxContainer/Canvas
onready var status_pixel_pos = $VBoxContainer/Canvas/PixelPos

func _ready():
	canvas.connect("mouse_position_changed", self, "_on_mouse_position_changed")
	canvas.connect("mouse_entered", status_pixel_pos, "show")
	canvas.connect("mouse_exited", status_pixel_pos, "hide")

func _on_mouse_position_changed(position):
	status_pixel_pos.text = str(canvas.mouse_pixel_position)
