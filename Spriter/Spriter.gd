extends Control

export(bool) var testing:bool = false

onready var tilesetSelector = $VBoxContainer/Tilesets/Panel/TilesetSelector
onready var tilesetControl:TilesetControl = $VBoxContainer/Tilesets/TilesetContainer/TilesetControl
onready var canvas:Canvas = $VBoxContainer/Main/Painter/VBoxContainer/Canvas
onready var palette:PaletteSelector = $VBoxContainer/Main/Tools/PaletteSelector
onready var newTilesetPopup = $NewTilesetPopup
onready var addTilesetButton = $VBoxContainer/Tilesets/Panel/TilesetSelector/AddTilesetButton

var project:Project

var clipboard = null

func _ready():
	addTilesetButton.connect("pressed", newTilesetPopup, "popup_centered")
	newTilesetPopup.connect("request_add", self, "add_tileset")
	tilesetControl.connect("tile_selected", self, "_on_tile_selected")
	tilesetControl.connect("tile_changed", self, "_on_tile_changed")
	canvas.connect("image_changed", self, "_on_canvas_image_changed")
	tilesetSelector.connect("tileset_selected", self, "_show_tileset")
	
	# testing
	if testing:
		project = Project.new("dev")
		project.load_data()
		_open_project(project)


func set_clipboard(data):
	clipboard = data

func get_clipboard():
	return clipboard

func clipboard_empty() -> bool:
	return clipboard == null

func _close_project():
	tilesetControl.clear()
	canvas.clear()
	tilesetSelector.clear()
	
	project = null


func _open_project(p:Project):
	project = p
	for tileset in project.tilesets.values():
		tilesetSelector.add_tileset_button(tileset)
		tilesetSelector.select_tileset(tileset)
		_show_tileset(tileset)


func _show_tileset(tileset:Tileset):
	print("Showing tileset " + tileset.title)
	tilesetControl.set_tileset(tileset)
	canvas.set_image(tileset.image)
	tilesetControl.select_tile(0)
	canvas.set_image_region(tilesetControl.get_selected_region())

func _on_tile_selected(tile):
	canvas.set_image_region(tilesetControl.get_selected_region())
	$VBoxContainer/Main/Painter/TileID.text = "#" + str(tile)

func _on_tile_changed(tile:TilesetTile):
	canvas.update_image_texture()
	canvas.update()

func _on_canvas_image_changed():
	tilesetControl.update_texture()

func add_tileset(name:String, width:int, height:int, tilesize:int):
	ES.echo("adding tileset with size " + str(width) + "x" + str(height) + " and a tilesize of " + str(tilesize))
	var tileset = project.create_tileset(name, width, height, tilesize)
	tilesetSelector.add_tileset_button(tileset)
	tilesetSelector.select_tileset(tileset)
	_show_tileset(tileset)
