class_name MapEditor extends Control

const LayerItem = preload("res://Mapper/LayerItem.tscn")

onready var mapRenderer = $Map/MapRenderer
onready var layersList = $MapOptions/LayersList

var layersListButtonGroup = ButtonGroup.new()

var current_map
var selected_layer

var selected_tileset:Tileset
var selected_tileset_tile:int

func open_map(map):
	current_map = map
	mapRenderer.map = current_map
	mapRenderer.update()
	
	for layer in map.layers:
		var layerItem = LayerItem.instance()
		layerItem.group = layersListButtonGroup
		layerItem.text = layer.name
		layerItem.connect("toggled", self, "_on_layer_item_toggled", [layerItem])
		layersList.add_child(layerItem)

func clear():
	current_map = null
	selected_layer = null
	selected_tileset = null
	selected_tileset_tile = -1
	mapRenderer.map = null
	mapRenderer.update()
	
	for child in layersList.get_children():
		layersList.remove_child(child)
		child.queue_free()


func select_layer(layer):
	selected_layer = layer
	mapRenderer.layer = layer


func select_tile(tileset:Tileset, tile:int):
	selected_tileset = tileset
	selected_tileset_tile = tile
	mapRenderer.selected_tileset = tileset
	mapRenderer.selected_tileset_tile = tile


func _on_layer_item_toggled(toggled:bool, layerItem):
	if toggled:
		selected_layer = current_map.get_layer(layerItem.text)
		mapRenderer.layer = selected_layer
