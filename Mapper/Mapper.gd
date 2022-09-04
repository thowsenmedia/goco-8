class_name Mapper extends Control

var MapListItem = load("res://Mapper/MapListItem.tscn")

export(bool) var testing = false

onready var mapEditor = $VBoxContainer/VBoxContainer/MapEditor
onready var tilesetControl = $VBoxContainer/VBoxContainer/MapEditor/Map/Tilesets/TilesetScroller/TilesetControl
onready var tilesetSelector = $VBoxContainer/VBoxContainer/MapEditor/Map/Tilesets/TilesetSelector

onready var mapListButtons = $VBoxContainer/VBoxContainer/MapList/MapListButtons
onready var addMapButton = $VBoxContainer/VBoxContainer/MapList/AddMapButton

onready var newMapPopup = $NewMapPopup

var project:Project

var selected_map
var selected_layer

var selected_tileset:Tileset

func _ready():
	# show new map popup
	addMapButton.connect("pressed", newMapPopup, "popup_centered")
	
	# adding a map
	newMapPopup.connect("request_add", self, "create_map")
	
	# selecting a tileset
	tilesetSelector.connect("tileset_selected", self, "_on_tileset_selected")
	
	# selecting a tile
	tilesetControl.connect("tile_selected", self, "_on_tile_selected")
	
	if testing:
		print("opening test project")
		var p = Project.new("dev")
		p.load_data()
		_open_project(p)


func _open_project(p):
	project = p
	for tileset in project.tilesets.values():
		tilesetSelector.add_tileset_button(tileset)
	
	if project.tilesets.size() > 0:
		var ts = project.tilesets.values()[0]
		tilesetSelector.select_tileset(ts)
		tilesetControl.set_tileset(ts)
		selected_tileset = ts
		mapEditor.select_tile(ts, tilesetControl.selected_tile)
	
	if project.maps.size() > 0:
		selected_map = project.maps.values()[0]


func _close_project():
	project = null
	tilesetSelector.clear()
	tilesetControl.clear()
	mapEditor.clear()


func grab_focus():
	if project:
		refresh_tilesets()
		refresh_maps()


func refresh_tilesets():
	for tileset in project.tilesets.values():
		if not tilesetSelector.has_button_for(tileset):
			tilesetSelector.add_tileset_button(tileset)


func has_button_for_map(map:Map):
	for mapButton in mapListButtons.get_children():
		if mapButton.map == map:
			return true
	
	return false


func refresh_maps():
	for map in project.maps.values():
		if not has_button_for_map(map):
			_add_map_button(map)


func _add_map_button(map:Map):
	var mapListItem = MapListItem.instance()
	mapListItem.map = map
	mapListButtons.add_child(mapListItem)
	mapListItem.connect("selected", self, "select_map_by_name", [map.name])


func create_map(map_name:String, tile_size: int, width: int, height: int):
	var map = project.create_map(map_name, width, height, tile_size)
	var layer = map.add_layer("new_layer")
	
	_add_map_button(map)
	
	newMapPopup.hide()
	select_map_by_name(map_name)
	select_layer_by_name(layer.name)


func select_map_by_name(map_name:String):
	var map = project.get_map(map_name)
	_set_selected_map(map)
	select_layer_by_name(map.layers[0].name)


func select_layer_by_name(name:String):
	selected_layer = selected_map.get_layer(name)
	mapEditor.select_layer(selected_layer)


func _set_selected_map(map:Object):
	print("selecting map")
	selected_map = map
	mapEditor.open_map(map)
	
	mapEditor.select_tile(selected_tileset, tilesetControl.selected_tile)

func _on_tileset_selected(tileset:Tileset):
	selected_tileset = tileset
	tilesetControl.set_tileset(tileset)
	if selected_map:
		mapEditor.select_tile(tileset, tilesetControl.selected_tile)

func _on_tile_selected(tile_id:int):
	if selected_map:
		mapEditor.select_tile(selected_tileset, tile_id)
