class_name MapLayer extends Reference

var name:String = "Unknown Layer"
var tile_size:int = 8
var size := Vector2(256, 256)

var tiles:Array = []

func _init(_name:String = "", tileSize:int = 0, layer_size:Vector2 = Vector2()):
	name = _name
	size = layer_size
	tile_size = tileSize
	
	# initialize tiles
	_init_tiles()

func pack(project) -> Dictionary:
	var packed = {
		"name": name,
		"tile_size": tile_size,
		"size": size,
		"tiles": []
	}
	
	for tile in tiles:
		packed.tiles.append(tile.pack(project))
	
	return packed


func unpack(project, data:Dictionary):
	name = data.name
	tile_size = data.tile_size
	size = data.size
	
	tiles = []
	
	for tile_data in data.tiles:
		var tile = MapTile.new()
		tile.unpack(project, tile_data)
		tiles.append(tile)


func _init_tiles():
	tiles.resize(size.x * size.y * tile_size)
	for i in tiles.size():
		tiles[i] = MapTile.new()


func serialize(project) -> Dictionary:
	var data = {
		"name": name,
		"tile_size": var2str(tile_size),
		"size": var2str(size),
		"tiles": []
	}
	
	for tile in tiles:
		data["tiles"].append(tile.serialize(project))
	
	return data


func unserialize(project, data:Dictionary):
	name = data.name
	tile_size = int(data.tile_size)
	size = str2var(data.size)
	
	# initialize tiles
	_init_tiles()
	
	var i = 0
	for tile in tiles:
		tile.unserialize(project, data.tiles[i])
		i += 1


func set_tile(index, tileset:Tileset, tile_id:int):
	var t = get_tile(index)
	
	if t:
		t.set_tile(tileset, tile_id)


func get_tile(index:int):
	if index < 0 or index >= tiles.size():
		return null
	
	return tiles[index]

func get_tile_index(x:int, y:int) -> int:
	return x + int(size.x) * y

func get_tile_g(x:int, y:int):
	var index = get_tile_index(x, y)
	return get_tile(index)

func get_tile_v(x:int, y:int):
	return get_tile_g(x / tile_size, y / tile_size)

func set_tile_g(x: int, y: int, tileset:Tileset, tile_id: int):
	var index = get_tile_index(x, y)
	return set_tile(index, tileset, tile_id)
