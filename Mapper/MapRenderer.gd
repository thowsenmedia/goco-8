tool class_name MapRenderer extends Control

export(Color) var background_color = Color.black
export(Color) var grid_color = Color.gray
export(bool) var show_grid := false

onready var status_mouse = $mouse
onready var status_camera = $camera

var map:Map
var layer:MapLayer

var selected_tileset:Tileset setget set_selected_tileset, get_selected_tileset
var selected_tileset_tile:int = -1 setget set_selected_tileset_tile, get_selected_tileset_tile

var camera := Vector2(0, 0)
var zoom := 1.0

var mouse := Vector2()
var mouse_tile_pos := Vector2()

var is_painting:bool = false
var last_paint_tile_pos := Vector2()

var is_panning:bool = false
var pan_start_mouse := Vector2()
var pan_start_camera := Vector2()

func _ready():
	rect_clip_content = true

func set_selected_tileset(ts:Tileset):
	selected_tileset = ts

func get_selected_tileset():
	return selected_tileset

func set_selected_tileset_tile(tile:int):
	selected_tileset_tile = tile

func get_selected_tileset_tile() -> int:
	return selected_tileset_tile

func _gui_input(event):
	if map and event is InputEventMouse:
		_set_mouse_pos(event.position)
		
		if event is InputEventMouseMotion and is_painting:
			update_paint()
		elif event is InputEventMouseMotion and is_panning:
			update_pan()
		elif event is InputEventMouseButton:
			if event.pressed and event.button_index == BUTTON_WHEEL_UP:
				set_zoom(zoom + 1)
			elif event.pressed and event.button_index == BUTTON_WHEEL_DOWN:
				set_zoom(zoom - 1)
			elif event.button_index == BUTTON_LEFT:
				if not event.pressed and is_painting:
					is_painting = false
				elif event.pressed and not is_painting:
					start_paint()
			elif event.button_index == BUTTON_MIDDLE:
				if not event.pressed and is_panning:
					is_panning = false
				elif event.pressed and not is_panning:
					start_pan()


func set_zoom(z:float):
	z = clamp(z, 0, 10)
	if z == 0:
		z = 0.5
	
	if zoom != z:
		zoom = z
		update()


func start_paint():
	is_painting = true
	update_paint()


func update_paint():
	if layer and mouse_tile_pos != last_paint_tile_pos:
		var x = mouse_tile_pos.x
		var y = mouse_tile_pos.y
		if map.is_grid_pos_in_bounds(x, y):
			layer.set_tile_g(x, y, selected_tileset, selected_tileset_tile)
			update()
			last_paint_tile_pos = mouse_tile_pos.round()


func start_pan():
	print("pan started at mouse " + str(mouse))
	is_panning = true
	pan_start_camera = camera
	pan_start_mouse = get_local_mouse_position()


func update_pan():
	var offset = get_local_mouse_position() - pan_start_mouse
	camera = (pan_start_camera - (offset / zoom)).round()
	
	status_camera.text = str(camera)
	update()


func _set_mouse_pos(pos:Vector2):
	if map:
		#mouse = pos + camera * zoom
		mouse = pos
		mouse /= zoom
		mouse += camera
		mouse_tile_pos = (mouse.round() / map.tile_size).floor()
		
		status_mouse.text = str(mouse_tile_pos)


func _draw():
	var rect = get_rect()
	
	# draw background
	draw_rect(rect, Color(0.1, 0.1, 0.1), true)
	
	if map:
		for layer in map.layers:
			_draw_layer(layer)
	
		if show_grid:
			_draw_grid()


func _draw_layer(layer:MapLayer):
	var control_size = get_rect().size
	var visible_area = Rect2(camera, control_size)
	
	var tilesize = layer.tile_size
	
	var rect = get_rect()
	rect.position -= Vector2(tilesize * 2, tilesize * 2)
	
	# loop through tiles
	for x in layer.size.x:
		for y in layer.size.y:
			var map_pos = Vector2(x * tilesize * zoom, y * tilesize * zoom)
			var screen_pos = map_pos - camera * zoom
			var screen_rect = Rect2(screen_pos, Vector2(tilesize, tilesize) * zoom)
			if rect.has_point(screen_pos):
				var tile = layer.get_tile_g(x, y)
				if not tile.is_empty():
					var tileset = tile.tileset
					var tileset_region = tile.region
					draw_texture_rect_region(tileset.texture, screen_rect, tileset_region)
				else:
					draw_rect(screen_rect, Color(0.02, 0.02, 0.02), true)
	

func _draw_grid():
	var pos = Vector2(0, 0)
	var size = get_rect().size
