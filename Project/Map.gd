class_name Map extends Reference

var name:String = "new_map"
var layers := []
var size := Vector2(256, 256)
var tile_size:int = 8


func _init(map_name:String = "", w: int = 1, h: int = 1, tilesize: int = 1):
	name = map_name
	size.x = w
	size.y = h
	tile_size = tilesize


func is_grid_pos_in_bounds(x: int, y: int):
	if x < 0: return false
	if y < 0: return false
	if x >= size.x: return false
	if y >= size.y: return false
	return true


func serialize() -> Dictionary:
	var data = {
		"name": name,
		"layers": [],
		"size": size,
		"tile_size": tile_size
	}
	
	for layer in layers:
		data["layers"].append(layer.serialize())
	
	return data


func unserialize(data:Dictionary, project):
	name = data.name
	size = data.size
	tile_size = data.tile_size
	
	layers = []
	for layer_data in data.layers:
		var layer = MapLayer.new()
		layer.unserialize(layer_data, project)
		layers.append(layer)


func layer_name_exists(name:String) -> bool:
	for layer in layers:
		if layer.name == name:
			return true
	
	return false


func get_layer(name:String):
	for layer in layers:
		if layer.name == name:
			return layer
	
	return null

func get_unique_name(name:String) -> String:
	if layer_name_exists(name):
		var new_name = name
		var i = 0
		while layer_name_exists(new_name):
			if i > 10:
				new_name = name + "_0" + str(i)
			else:
				new_name = name + "_" + str(i)
			i += 1
		return new_name
	
	return name


func add_layer(name:String):
	name = get_unique_name(name)
	var layer = MapLayer.new(name, tile_size, size)
	layers.append(layer)
	
	return layer
