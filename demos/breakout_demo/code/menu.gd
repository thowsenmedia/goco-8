extends ESNode2D

var main
var arg = null

var play_timer = Timer.new()
var next_level = "level1"
var will_play = false

var t = 0.0

func _start():
	play_timer.one_shot = true
	play_timer.wait_time = 1
	play_timer.connect("timeout", self, "play")
	add_child(play_timer)

func play():
	main.goto("play.gd", next_level)

func _tick(delta):
	t += delta
	if btn("a").down:
		play_timer.start()
		will_play = true
		
func _draw():
	var text = "- PRESS [A] TO START -"
	var text_w = text_width(text)
	var text_h = text_height(text)
	var x = 320/2
	var y = 240/2
	
	x -= text_w / 2
	y -= text_h / 2
	
	var col = Color.white
	
	if will_play:
		col = Color(sin(t * 7), cos(t * 9), sin(t*5 - cos(t*5)))
		var cam = get_camera()
		var zoom = cam.zoom.x
		var z = lerp(zoom, 2, play_timer.time_left/2)
		cam.zoom.x = z
		cam.zoom.y = z
	
	draw_text(text, x, y, col)
	
	cls()