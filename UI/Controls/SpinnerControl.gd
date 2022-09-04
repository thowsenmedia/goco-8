tool class_name SpinnerControl extends Control

signal value_changed(value)

export(int) var min_value = 0
export(int) var max_value = 255
export(int) var value = 0 setget set_value, get_value
export(String) var prefix = ""
export(String) var suffix = ""

export(bool) var ensure_digit_length = false

export(Color) var value_bg = Color(0.1, 0.1, 0.1)
export(Color) var font_color = Color(0.1, 0.1, 0.1)
export(Color) var font_color_hover = Color(0.1, 0.1, 0.1)

var back_rect := Rect2()
var value_rect := Rect2()
var forward_rect := Rect2()

var back_pressed:bool = false
var value_pressed:bool = false
var forward_pressed:bool = false

func _ready():
	_recalculate_sizes()
	update()

func _gui_input(event):
	if event is InputEventMouseMotion:
		if back_rect.has_point(event.position):
			pass
		elif value_rect.has_point(event.position):
			pass
		elif forward_rect.has_point(event.position):
			pass
	elif event is InputEventMouseButton:
		if back_rect.has_point(event.position):
			back_pressed = event.pressed
			if not event.pressed:
				back()
		elif value_rect.has_point(event.position):
			value_pressed = event.pressed
			if not event.pressed:
				if event.button_index == BUTTON_LEFT:
					forward()
				elif event.button_index == BUTTON_RIGHT:
					back()
		elif forward_rect.has_point(event.position):
			forward_pressed = event.pressed
			if not event.pressed:
				forward()


func forward():
	value += 1
	if value > max_value:
		value = max_value
	else:
		emit_signal("value_changed", value)
		update()


func back():
	value -= 1
	if value < min_value:
		value = min_value
	else:
		emit_signal("value_changed", value)
		update()


func set_value(v):
	value = clamp(v, min_value, max_value)

	_recalculate_sizes()
	
	update()


func get_value():
	return value


func _recalculate_sizes():
	var font = get_theme_default_font()
	var descent = font.get_descent()
	var font_height = font.get_height()
	
	back_rect.size = font.get_string_size("<")
	back_rect.position = Vector2(0, 0)
	
	value_rect.position = Vector2(back_rect.size.x + 2, 0)
	var value_text = ""
	if ensure_digit_length:
		var needed_length = str(max_value).length()
		var i = str(value).length()
		while i < needed_length:
			value_text += "0"
			i += 1
	value_text += str(value)
	value_rect.size = font.get_string_size(prefix + value_text + suffix)
	
	forward_rect.position.x = back_rect.size.x + 4 + value_rect.size.x
	forward_rect.position.y = 0
	forward_rect.size = font.get_string_size(">")
	
	rect_min_size.y = font_height + 2
	rect_min_size.x = 0
	rect_min_size.x += font.get_string_size("<").x + 2
	rect_min_size.x += font.get_string_size(prefix).x
	rect_min_size.x += font.get_string_size("000").x + 2
	rect_min_size.x += font.get_string_size(">").x


func _draw():
	var font = get_theme_default_font()
	var descent = font.get_descent()
	var font_height = font.get_height() - descent
	
	# draw back
	draw_string(font, Vector2(back_rect.position.x, font_height), "<")
	
	# draw value BG and value
	var text = prefix
	
	if ensure_digit_length:
		var needed_length = str(max_value).length()
		var i = str(value).length()
		while i < needed_length:
			text += "0"
			i += 1
	
	text += str(value)
	text += suffix
	
	# draw value_bg
	draw_rect(Rect2(Vector2(value_rect.position.x, 0), value_rect.size + Vector2(0, 2)), value_bg, true)
	
	# draw value
	draw_string(font, Vector2(value_rect.position.x, font_height), text)
	
	# draw forward
	draw_string(font, Vector2(forward_rect.position.x, font_height), ">")
