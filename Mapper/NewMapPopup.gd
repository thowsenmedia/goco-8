extends WindowDialog

signal request_add(name, tilesize, width, height)

const TILE_SIZES = {
	"4x4 px": 4,
	"8x8 px": 8,
	"16x16 px": 16,
	"32x32 px": 32
}

onready var mapName = $MarginContainer/VBoxContainer/MapName/mapNameValue
onready var tileSize = $MarginContainer/VBoxContainer/TileSize/tilesizeValue
onready var mapWidth = $MarginContainer/VBoxContainer/MapSize/HBoxContainer/mapWidthValue
onready var mapHeight = $MarginContainer/VBoxContainer/MapSize/HBoxContainer/mapHeightValue

onready var addButton = $MarginContainer/VBoxContainer/Buttons/AddButton
onready var cancelButton = $MarginContainer/VBoxContainer/Buttons/CancelButton

var tile_size:int = 8

func _ready():
	addButton.connect("pressed", self, "_on_add_pressed")
	cancelButton.connect("pressed", self, "_cancel")
	mapName.connect("text_changed", self, "_on_name_changed")
	tileSize.connect("item_selected", self, "_on_tilesize_selected")
	
	# add available tile sizes
	var i = 0
	var titles = TILE_SIZES.keys()
	for tile_size in TILE_SIZES.values():
		var title = titles[i]
		tileSize.add_item(title, i)
		i += 1
	
	addButton.disabled = true
	

func _on_name_changed(name):
	addButton.disabled = name == ""


func _on_tilesize_selected(id):
	tile_size = TILE_SIZES.values()[id]


func _cancel():
	mapName.text = ""
	mapWidth.value = 10
	mapHeight.value = 10

func _on_add_pressed():
	emit_signal("request_add", mapName.text, tile_size, mapWidth.value, mapHeight.value)
