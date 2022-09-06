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

func serialize() -> Dictionary:
	var data = {
		"tileset": "",
		"tile_id": tile_id
	}
	
	if tileset:
		data.tileset = tileset.title
	
	return data

func unserialize(data:Dictionary, project):
	tile_id = data.tile_id
	
	if data.tileset != "":
		tileset = project.tilesets[data.tileset]
		region = tileset.get_region(tile_id)
