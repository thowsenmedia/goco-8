extends WindowDialog

onready var nameField = $MarginContainer/VBoxContainer/layer_name/NameField
onready var addButton = $MarginContainer/VBoxContainer/Buttons/AddButton
onready var cancelButton = $MarginContainer/VBoxContainer/Buttons/CancelButton

func _ready():
	nameField.connect("text_changed", self, "_on_name_changed")
	addButton.disabled = true
	addButton.connect("pressed", self, "_on_add_pressed")
	
	cancelButton.connect("pressed", self, "_on_cancel_pressed")

func _on_name_changed(name):
	addButton.disabled = name != ""

func _on_add_pressed():
	emit_signal("request_add", nameField.text)
	nameField.text = ""

func _on_cancel_pressed():
	nameField.text = ""
	hide()
