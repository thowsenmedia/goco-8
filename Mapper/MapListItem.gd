class_name MapListItem extends HBoxContainer

signal selected()

onready var button = $Button

var map

func _ready():
	button.connect("pressed", self, "_on_button_pressed")
	
	if map:
		button.text = map.name


func _on_button_pressed():
	emit_signal("selected")
