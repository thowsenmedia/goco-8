tool class_name TilesetControl extends GridContainer

signal clipboard_set(data)

const TilesetTileScene = preload("res://Spriter/Tileset/TilesetTile.tscn")

signal tile_selected(tile_id)
signal tile_changed(tile_id)

var tileset:Tileset
var tile_display_size:int = 24
var selected_tile:int = -1


func set_tileset(tileset:Tileset):
	self.tileset = tileset
	tile_display_size = tileset.tile_size * 3
	columns = tileset.image.get_size().x / tileset.tile_size
	clear()
	create_tiles()
	select_tile(0)


func update_texture():
	tileset.update_texture()
	update()


func clear():
	for child in get_children():
		remove_child(child)
		child.free()


func create_tiles():
	var img_size = tileset.image.get_size()
	var tiles_x = img_size.x / tileset.tile_size
	var tiles_y = img_size.y / tileset.tile_size
	
	var id = 0
	for y in tiles_y:
		for x in tiles_x:
			var tile = TilesetTileScene.instance()
			tile.tileset = tileset
			tile.region = Rect2(x * tileset.tile_size, y * tileset.tile_size, tileset.tile_size, tileset.tile_size)
			tile.render_size = tile_display_size
			tile.connect("button_up", self, "_on_tile_pressed", [id])
			tile.connect("changed", self, "_on_tile_changed", [id])
			add_child(tile)
			id += 1

func _on_tile_changed(id):
	var tile = get_child(id)
	emit_signal("tile_changed", tile)

func _on_tile_pressed(id: int, emit_event:bool = true):
	if selected_tile != -1:
		var t = get_child(selected_tile)
		if t:
			t.pressed = false
	get_child(id).pressed = true
	selected_tile = id
	
	if emit_event:
		emit_signal("tile_selected", id)


func select_tile(id):
	_on_tile_pressed(id, false)


func get_selected_region() -> Rect2:
	var i = selected_tile
	var x = i % columns
	var y = i / columns
	
	return Rect2(x * tileset.tile_size, y * tileset.tile_size, tileset.tile_size, tileset.tile_size)
