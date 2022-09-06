tool extends Control

signal button_down()
signal button_up()

var tileset:Tileset
export(Rect2) var region:Rect2 setget set_region, get_region
export(int) var render_size:int = 16 setget set_render_size, get_render_size

var pressed:bool = false setget set_pressed, get_pressed

func set_pressed(p:bool):
	pressed = p
	update()

func get_pressed() -> bool:
	return pressed

func set_region(r:Rect2):
	region = r

func get_region() -> Rect2:
	return region

func set_render_size(s: int):
	render_size = s
	rect_min_size.x = render_size + 4
	rect_min_size.y = render_size + 4

func get_render_size() -> int:
	return render_size

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("button_down")
		elif event.button_index == BUTTON_LEFT and not event.pressed:
			emit_signal("button_up")

func _draw():
	var border_color = Color.black
	if pressed:
		border_color = Color.white
	
	draw_rect(Rect2(0, 0, render_size + 2, render_size + 2), border_color, false, 2.0)
	draw_texture_rect_region(tileset.texture, Rect2(1, 1, render_size, render_size), region)
