extends ESNode2D

var menuScreen
var playScreen

var screen

func _start():
	goto_menu()

func goto_menu():
	if screen:
		remove_child(screen)
		screen.queue_free()
	
	screen = get_script("menu.gd")
	screen.main = self
	add_child(screen)

func goto_play():
	if screen:
		remove_child(screen)
		screen.queue_free()
	
	screen = playScreen.new()
