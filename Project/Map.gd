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


func pack(project) -> Dictionary:
	var packed = {
		"name": name,
		"layers": [],
		"size": size,
		"tile_size": tile_size
	}
	
	var i = 0
	for layer in layers:
		packed.layers.append(layer.pack(project))
		i += 1
	
	return packed


func unpack(project, packed:Dictionary):
	name = packed.name
	size = packed.size
	tile_size = packed.tile_size
	layers = []
	
	for layer_data in packed.layers:
		var layer = MapLayer.new()
		layer.unpack(project, layer_data)
		layers.append(layer)


func serialize(project) -> Dictionary:
	var data = {
		"name": name,
		"layers": [],
		"size": var2str(size),
		"tile_size": var2str(tile_size)
	}
	
	for layer in layers:
		data["layers"].append(layer.serialize(project))
	
	return data


func unserialize(project, data:Dictionary):
	name = data.name
	size = str2var(data.size)
	tile_size = int(data.tile_size)
	
	layers = []
	for layer_data in data.layers:
		var layer = MapLayer.new()
		layer.unserialize(project, layer_data)
		layers.append(layer)


func layer_name_exists(name:String) -> bool:
	for layer in layers:
		if layer.name == name:
			return true
	
	return false

func get_tile(layer_name_or_id, x:int, y:int):
	var layer = get_layer(layer_name_or_id)
	return layer.get_tile_g(x, y)

func get_layer(name_or_id):
	if name_or_id is String:
		for layer in layers:
			if layer.name == name_or_id:
				return layer
	else:
		if name_or_id < 0 or name_or_id >= layers.size():
			return null
		
		return layers[name_or_id]
	
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
