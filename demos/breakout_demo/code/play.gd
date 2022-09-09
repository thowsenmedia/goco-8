extends ESNode2D

enum STATE {
	PLAYING,
	WON,
	LOST
}

var state = STATE.PLAYING

var main
var arg = null

var level
var map

const p_w = 32
const p_h = 4
const p_speed = 164

const ball_speed = 128

var p_x = 320/2 - (p_w/2)
var p_vel

var p_has_ball = false
var p_balls = 3

var ball_pos = Vector2()
var ball_vel = Vector2()

var t = 0.0

func _start():
	level = arg
	map = get_map(level)
	init_ball()

func init_ball():
	ball_pos.x = p_x + (p_w/2)
	ball_pos.y = 240 - 12
	ball_vel *= 0
	p_has_ball = true

func loose_ball():
	p_balls -= 1
	if p_balls < 0:
		state = STATE.LOST

func _tick(delta):
	t += delta
	var p_x_old = p_x
	
	if btn("left").down:
		p_x -= p_speed * delta
	if btn("right").down:
		p_x += p_speed * delta
	
	# clamp to screen
	if p_x < 0:
		p_x = 0
	
	if p_x + p_w > 320:
		p_x = 320 - (p_w)
	
	p_vel = p_x - p_x_old
	
	
	if p_has_ball:
		# ball follows paddle
		ball_pos.x = p_x + (p_w/2)
		
		if btn("a").down:
			# shoot the ball
			p_has_ball = false
			ball_vel.y = -ball_speed
			ball_vel.x = p_vel * p_speed
			p_has_ball = false
	
	# ball moves
	print(ball_vel)
	ball_pos += ball_vel * delta
	
	# check collisions
	if not p_has_ball:
		var brick_tile = process_brick_collisions()
		if not brick_tile:
			process_ball_paddle_collision()


func process_ball_paddle_collision():
	var ball_rect = Rect2(ball_pos.x, ball_pos.y, 4, 4)
	var paddle_rect = Rect2(p_x, 240-14, p_w, p_h)
	
	if ball_pos.y < 20:
		ball_vel.y = abs(ball_vel.y)
	elif ball_pos.y > 228:
		# bounce on paddle?
		if ball_rect.position.x >= paddle_rect.position.x and ball_rect.position.x <= paddle_rect.end.x:
			ball_vel.y = -abs(ball_vel.y)
			ball_vel.x += p_vel * p_speed * 0.5
		elif ball_pos.y > 240:
			loose_ball()
			init_ball()
			print("init ball!")
	elif ball_pos.x < 2:
		ball_vel.x = abs(ball_vel.x)
	elif ball_pos.x > 320-2:
		ball_vel.x = -abs(ball_vel.x)


# returns a tile or null
func process_brick_collisions():
	var layer = get_map(level).layers[0]
	var ball_rect = Rect2(ball_pos.x, ball_pos.y, 4, 4)
	var ball_center = ball_rect.get_center()
	
	for y in layer.size.y:
		for x in layer.size.x:
			var tile = layer.get_tile_g(x, y)
			if tile.tile_id != -1:
				var tile_rect = get_tile_rect(x, y)
				var tile_center = tile_rect.get_center()
				
				if tile_rect.intersects(ball_rect, true):
				
					# collision detected
					tile.tile_id = -1

					var within_x = ball_center.x > tile_rect.position.x and ball_center.x < tile_rect.end.x
					var within_y = ball_center.y > tile_rect.position.y and ball_center.y < tile_rect.end.y
					var below = ball_center.y > tile_rect.position.y
					var above = ball_center.y < tile_rect.position.y
					var left = ball_center.x < tile_rect.end.x
					var right = ball_center.x > tile_rect.end.x
					
					if within_x and above:
						ball_vel.y = -abs(ball_vel.y)
					elif within_x and below:
						ball_vel.y = abs(ball_vel.y)
					elif within_y and left:
						ball_vel.x = -abs(ball_vel.y)
					elif within_y and right:
						ball_vel.x = abs(ball_vel.x)
					
					return tile
		
	return null
	

func _draw():
	draw_map(level, 0, 0)
	draw_paddle()
	draw_ball()
	draw_hud()
	cls()

func draw_paddle():
	var x = p_x
	var y = 240 - 10
	frect(x, y, p_w, p_h, Color(0.9, 0.9, 0.9))
	brect(x, y, p_w, p_h, Color(0.2, 0.2, 0.2))

func draw_ball():
	var x = ball_pos.x
	var y = ball_pos.y
	frect(x-2, y-2, 4, 4, Color.white)


func get_tile_rect(x, y):
	x *= 8
	y *= 8
	var map = get_map(level)
	return Rect2(x, y, 8, 8)

func draw_hud():
	#frect(0, 0, 320, 10)
	var x = 320/2
	var y = 5
	
	var s = "Balls: " + str(p_balls) + " / 3"
	var w = text_width(s)
	var h = text_height(s)
	x -= w/2
	y -= h/2
	#outline
	draw_text(s, x+1, y+1, Color.gray)
	draw_text(s, x, y, Color.white)