extends WindowDialog

signal request_add(name, width, height, tilesize)

onready var nameField = $MarginContainer/VBoxContainer/NameAndTileSize/name
onready var tilesize = $MarginContainer/VBoxContainer/NameAndTileSize/Tilesize
onready var rows = $MarginContainer/VBoxContainer/size/rows
onready var columns = $MarginContainer/VBoxContainer/size/columns
onready var info = $MarginContainer/VBoxContainer/Info
onready var addButton = $MarginContainer/VBoxContainer/Buttons/Add
onready var cancelButton = $MarginContainer/VBoxContainer/Buttons/Cancel

var valid_tilesizes = [4,8,16,32]

var tilesize_value:int = 4

func _ready():
	cancelButton.connect("pressed", self, "cancel")
	connect("about_to_show", self, "_about_to_show")
	nameField.connect("text_changed", self, "_name_changed")
	tilesize.connect("item_selected", self, "_on_tilesize_changed")
	rows.connect("value_changed", self, "_on_rows_changed")
	columns.connect("value_changed", self, "_on_columns_changed")
	addButton.connect("pressed", self, "_request_add")
	
	for size in valid_tilesizes:
		tilesize.add_item(str(size) + "x" + str(size) + " px")

func _on_tilesize_changed(id):
	tilesize_value = valid_tilesizes[id]
	update_info()

func _on_rows_changed(rows):
	update_info()

func _on_columns_changed(columns):
	update_info()

func update_info():
	var width = columns.value * tilesize_value
	var height = rows.value * tilesize_value
	info.text = "(" + str(width) + "x" + str(height) + "px image size.)"

func _about_to_show():
	nameField.text = ""
	addButton.disabled = true

func _name_changed(name):
	addButton.disabled = name.length() == 0

func cancel():
	nameField.text = ""
	hide()

func _request_add():
	var width = columns.value * tilesize_value
	var height = rows.value * tilesize_value
	emit_signal("request_add", nameField.text, width, height, tilesize_value)
	hide()
