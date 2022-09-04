tool extends Control

signal tile_selected(tile)

export(Texture) var source
var image:Image
var image_texture:ImageTexture

export(int) var tile_size = 8
export(int) var tile_render_size:int = 24
var rows:int = 1
var columns:int = 1
var render_scale:float = 1.0

var tiles:Array = []

var selected_tile_index:int = 0

var mouse_position := Vector2()
var mouse_pixel_pos := Vector2()




func _ready():
	if source:
		set_image(source.get_data())

func create(tiles_x:int, tiles_y:int, tile_size:int):
	self.tile_size = tile_size
	self.tile_render_size = tile_size * 3
	var img = Image.new()
	img.create(tiles_x * tile_size, tiles_y * tile_size, false, Image.FORMAT_RGBA8)
	set_image(img)

func update_texture():
	image_texture.set_data(image)
	update()

func set_image(img:Image):
	image = img
	image_texture = ImageTexture.new()
	image_texture.create_from_image(image, 0)
	image.lock()
	
	# calculate sizes
	columns = image.get_size().x / tile_size
	rows = image.get_size().y / tile_size
	
	# calculate control size
	rect_min_size.x = columns * tile_render_size
	rect_min_size.y = rows * tile_render_size
	
	render_scale = tile_render_size / tile_size
	
	for y in rows:
		for x in columns:
			var t = Tile.new()
			t.grid_pos = Vector2(x, y)
			t.source_rect = Rect2(t.grid_pos * tile_size, Vector2(tile_size, tile_size))
			tiles.append(t)


func _gui_input(event:InputEvent):
	if event is InputEventMouse:
		set_mouse_position(event.position)
		
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == BUTTON_LEFT:
				var grid_pos = (mouse_pixel_pos / tile_size).floor()
				var tile_index = get_tile_index(grid_pos)
				select_tile(tile_index)


func select_tile(tile_index:int):
	selected_tile_index = tile_index
	emit_signal("tile_selected", get_selected_tile())


func get_selected_tile() -> Tile:
	return tiles[selected_tile_index]


func get_tile_index(grid_pos:Vector2) -> int:
	return int(floor(grid_pos.x + columns * grid_pos.y));


func set_mouse_position(mouse:Vector2):
	mouse_position = mouse
	mouse_pixel_pos = (mouse / (tile_render_size / tile_size)).floor()


func _draw():
	var rect = get_rect()
	var size = rect.size
	
	# draw background
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.1, 0.1, 0.1), true, 1.0, false)
	
	# draw tiles
	var padding_x = columns - 1
	var padding_y = rows - 1
	for tile in tiles:
		var pos = (tile.grid_pos * tile_size * render_scale)
		
		draw_texture_rect_region(image_texture, Rect2(pos, Vector2(tile_render_size, tile_render_size)), tile.source_rect)
