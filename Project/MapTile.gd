class_name MapTile extends Reference

var tileset:Tileset
var tile_id:int = -1
var region:Rect2

func set_tile(ts:Tileset, id:int = -1):
	tileset = ts
	tile_id = id
	region = tileset.get_region(tile_id)

func is_empty() -> bool:
	return tile_id == -1

func pack(project) -> Dictionary:
	var packed = {
		"tileset": null,
		"tile_id": tile_id,
		"region": region
	}
	
	if tileset:
		packed.tileset = tileset.title
	
	return packed


func unpack(project, data: Dictionary):
	if data.tileset != null:
		tileset = project.tilesets[data.tileset]
	
	tile_id = data.tile_id
	region = data.region


func serialize(project) -> Dictionary:
	var data = {
		"tileset": "",
		"tile_id": tile_id
	}
	
	if tileset:
		data.tileset = tileset.title
	
	return data

func unserialize(project, data:Dictionary):
	tile_id = data.tile_id
	
	if data.tileset != "":
		tileset = project.tilesets[data.tileset]
		region = tileset.get_region(tile_id)
