class_name ESNode2D extends Node2D

const _FONT_DEFAULT = preload("res://UI/fonts/5x7.tres")

var _project:Project
onready var _runner = $"/root/Runner"
onready var _camera = $"/root/Runner/Camera"

var _BUTTON_MAPPING = [
	"a",
	"b",
	"x",
	"y",
	"l",
	"r",
	"select",
	"start"
]

class _ButtonState:
	var just_pressed:bool = false
	var just_released:bool = false
	var down:bool = false

func _ready():
	set_process(false)
	_start()

func _start():
	pass

func _tick(delta):
	pass

func script(script_name) -> ESNode2D:
	return _runner.script(script_name)

func echo(message:String):
	_runner.echo(message)

func btn(action:String, player_id:int = 0) -> _ButtonState:
	action = action.to_lower()
	var joy_button = _BUTTON_MAPPING.find(action.to_lower())
	
	var state = _ButtonState.new()
	
	if player_id == 0:
		state.down = Input.is_joy_button_pressed(player_id, joy_button) or Input.is_action_pressed(action)
	else:
		state.down = Input.is_joy_button_pressed(player_id, joy_button)
	
	return state

func btn_a(player_id:int = 0) -> _ButtonState:
	return btn("a", player_id)

func btn_b(player_id:int = 0) -> _ButtonState:
	return btn("b", player_id)

func btn_x(player_id:int = 0) -> _ButtonState:
	return btn("x", player_id)

func btn_y(player_id:int = 0) -> _ButtonState:
	return btn("y", player_id)

func btn_l(player_id:int = 0) -> _ButtonState:
	return btn("l", player_id)

func btn_r(player_id:int = 0) -> _ButtonState:
	return btn("r", player_id)
	
func btn_select(player_id:int = 0) -> _ButtonState:
	return btn("select", player_id)

func btn_start(player_id:int = 0) -> _ButtonState:
	return btn("start", player_id)
	
func btn_left(player_id:int = 0) -> _ButtonState:
	return btn("left", player_id)

func btn_right(player_id:int = 0) -> _ButtonState:
	return btn("right", player_id)

func btn_up(player_id:int = 0) -> _ButtonState:
	return btn("up", player_id)

func btn_down(player_id:int = 0) -> _ButtonState:
	return btn("down", player_id)

func get_camera() -> Camera2D:
	return _camera

# set camera zoom
func camera(x:float, y:float, zoom = null):
	_camera.position.x = x
	_camera.position.y = y
	
	if zoom != null:
		_camera.zoom.x = zoom
		_camera.zoom.y = zoom

# get tileset
func get_tileset(tileset_name:String) -> Tileset:
	return _project.tilesets[tileset_name]

# get map
func get_map(map_name:String) -> Map:
	if not _project.maps.has(map_name):
		ES.error("unknown map " + map_name)
		return null
	return _project.maps[map_name]

func get_tile(map_name:String, layer_name_or_id, x:int, y:int) -> MapTile:
	return _project.maps[map_name].get_layer(layer_name_or_id).get_tile_v(x, y)

func get_tile_rect_at(map_name: String, world_x:float, world_y:float) -> Rect2:
	var map = get_map(map_name)
	var x = floor(world_x / map.tile_size)
	var y = floor(world_y / map.tile_size)
	return Rect2(x, y, map.tile_size, map.tile_size)

func text_width(text: String) -> float:
	return _FONT_DEFAULT.get_string_size(text).x

func text_height(text: String) -> float:
	return _FONT_DEFAULT.get_string_size(text).y

func draw_text(text: String, pos_x: int, pos_y: int, color:Color = Color.white):
	var h = _FONT_DEFAULT.get_height()
	draw_string(_FONT_DEFAULT, Vector2(pos_x, pos_y + h), text, color)

func draw_map(map_name:String, pos_x:int, pos_y:int):
	var map = get_map(map_name)
	if not map:
		ES.error("Unknown map " + map_name)
		return
	
	for layer in map.layers:
		for x in map.size.x:
			for y in map.size.y:
				var tile = layer.get_tile_g(x, y)
				if not tile.is_empty():
					var rect = Rect2(pos_x + (x * layer.tile_size), pos_y + (y * layer.tile_size), layer.tile_size, layer.tile_size)
					var src_rect = tile.region
					draw_texture_rect_region(tile.tileset.texture, rect, src_rect)


# draw a single sprite tile
func draw_sprite(tileset_name:String, tile_index:int, x:int, y:int, w:int = -1, h:int = -1):
	var tileset:Tileset = _project.tilesets[tileset_name]
	
	if w == -1:
		w = tileset.tile_size
	
	if h == -1:
		h = tileset.tile_size
	
	var rect = Rect2(x, y, w, h)
	
	var src_rect = tileset.get_region(tile_index)
	
	draw_texture_rect_region(tileset.texture, rect, src_rect)


func set_pixel(x:int, y:int, color:Color):
	frect(x,y,1,1, color)

func brect(x:int, y:int, w:int, h:int, color:Color, width:int = 1):
	draw_rect(Rect2(x, y, w, h), color, false, width)

func frect(x:int, y:int, w:int, h:int, color:Color):
	draw_rect(Rect2(x, y, w, h), color, true)

func line(x: int, y: int, to_x:int, to_y:int, width: int = 1, color:Color = Color.white):
	draw_line(Vector2(x, y), Vector2(to_x, to_y), color, width)

func cls():
	get_viewport().render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
