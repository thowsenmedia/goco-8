class_name MapEditor extends Control

onready var mapRenderer = $Map/MapRenderer

var current_map
var selected_layer

var selected_tileset:Tileset
var selected_tileset_tile:int

func open_map(map):
	current_map = map
	mapRenderer.map = current_map
	mapRenderer.update()

func clear():
	current_map = null
	selected_layer = null
	selected_tileset = null
	selected_tileset_tile = -1
	mapRenderer.map = null
	mapRenderer.update()


func select_layer(layer):
	selected_layer = layer
	mapRenderer.layer = layer


func select_tile(tileset:Tileset, tile:int):
	selected_tileset = tileset
	selected_tileset_tile = tile
	mapRenderer.selected_tileset = tileset
	mapRenderer.selected_tileset_tile = tile
