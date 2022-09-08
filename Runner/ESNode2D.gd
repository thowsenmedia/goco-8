class_name ESNode2D extends Node2D

const _FONT_DEFAULT = preload("res://UI/fonts/5x7.tres")

var _project:Project
onready var _runner:Runner = $"/root/Runner"
onready var _camera = $"/root/Runner/Camera"

var _BUTTON_MAPPING = [
	"a",
	"b",
	"x",
	"y",
]

class _ButtonState:
	var just_pressed:bool = false
	var just_released:bool = false
	var down:bool = false

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

func btn_left(player_id:int = 0) -> _ButtonState:
	return btn("left", player_id)

func btn_right(player_id:int = 0) -> _ButtonState:
	return btn("right", player_id)

func btn_up(player_id:int = 0) -> _ButtonState:
	return btn("up", player_id)

func btn_down(player_id:int = 0) -> _ButtonState:
	return btn("down", player_id)

# get camera
func get_camera():
	return _camera


# get tileset
func get_tileset(tileset_name:String) -> Tileset:
	return _project.tilesets[tileset_name]

# get map
func get_map(map_name:String) -> Map:
	return _project.maps[map_name]


func draw_text(text: String, pos_x: int, pos_y: int, color:Color = Color.white):
	var h = _FONT_DEFAULT.get_height()
	draw_string(_FONT_DEFAULT, Vector2(pos_x, pos_y + h), text, color)


func draw_map(map_name:String, pos_x:int, pos_y:int):
	var map = get_map(map_name)
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

func cls():
	get_viewport().render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
