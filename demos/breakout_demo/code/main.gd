extends ESNode2D

var screen

func _start():
	goto("menu.gd")

func goto(script_name, arg = null):
	if screen:
		remove_child(screen)
		screen.queue_free()
	
	screen = script(script_name)
	screen.main = self
	screen.arg = arg
	add_child(screen)

func _draw():
	pass
	