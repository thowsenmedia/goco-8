tool class_name TimelineView extends Control

export(Color) var playhead_color = Color.white
var pattern:SFXPattern setget set_pattern, get_pattern

onready var player:SynthPlayer = $SynthPlayer

var selected_wave:int = Note.WAVES.SINE

var is_playing := false
var is_painting := false

func set_pattern(p):
	pattern = p
	$SynthPlayer.pattern = p


func get_pattern() -> SFXPattern:
	return pattern


func _ready():
	if pattern and player:
		player.pattern = pattern


func get_note_height(note:Note) -> float:
	var rect = get_rect()
	var num_keys = (12 * 4) + 1
	
	var note_heights = rect.size.y / num_keys
	
	var key = note.key
	
	var note_height = (key * note_heights)
	return note_height

func get_note_at_y(y:float) -> int:
	var rect = get_rect()
	var num_notes = (12 * 4) + 1
	var note_heights = rect.size.y / num_notes
	
	# given a height of 100, 10 notes
	# note heights of 10
	# y = 50 should be 5
	return int(round((rect.size.y - y) / note_heights))


func get_pattern_note_index_at_x(x: float):
	var rect = get_rect()
	var note_padding = 1
	var note_width = (rect.size.x / pattern.length)
	var index = int(floor(x / note_width))
	index = clamp(index, 0, pattern.length)
	return index


func _gui_input(event):
	if event is InputEventMouseMotion and is_painting:
		paint(event)
		get_tree().set_input_as_handled()
	elif event is InputEventMouseButton:
		if not event.pressed and is_painting:
			is_painting = false
			get_tree().set_input_as_handled()
		else:
			is_painting = true
			paint(event)
			get_tree().set_input_as_handled()
	elif event is InputEventKey:
		var e = event as InputEventKey
		if e.scancode == KEY_SPACE:
			if not e.pressed:
				if is_playing:
					stop()
				else:
					play()
			get_tree().set_input_as_handled()


func paint(event:InputEventMouse):
	var note_index = get_pattern_note_index_at_x(event.position.x)
	var key = get_note_at_y(event.position.y)
	set_pattern_note(note_index, key, selected_wave)
	var hertz = pattern.notes[note_index].pulse_hz
	update()


func set_pattern_note(index:int, key:int, wave:int):
	index = clamp(index, 0, pattern.length - 1)
	key = clamp(key, 0, (12 * 4) + 1)
	pattern.notes[index].key = key
	pattern.notes[index].wave = wave
	#print("setting pattern note " + str(index) + " to " + str(key))
	update()


func play():
	if is_playing:
		return
	player.play(0)
	is_playing = true


func stop():
	if is_playing:
		player.stop()
		is_playing = false
		update()


func _process(delta):
	if is_playing:
		update()


func _draw():
	if not pattern:
		return
	
	var rect = get_rect()
	var note_padding = 1
	var note_width = (rect.size.x / pattern.length)
	var note_thickness = (rect.size.y / (12 * 3) + 2)
	
	var x = 0
	for i in pattern.length:
		var n:Note = pattern.notes[i]
		if n.key > -1:
			# draw the note
			var note_height = get_note_height(n)
			draw_rect(Rect2(x, rect.size.y - note_height, note_width-1, note_thickness), Color.teal)
		
		x += note_width
	
	# draw the playhead
	if is_playing:
		var buffer_length:float = player.stream.buffer_length
		
		var length = pattern.get_length_seconds()
		var pixels_per_second:float = rect.size.x / length
		var frame = player.pattern_position_frames
		var time = player.frames_to_seconds(frame)
		var playhead_x = (time / length) * rect.size.x
		
		playhead_x -= pixels_per_second * buffer_length
		
		if playhead_x < 0:
			playhead_x = rect.size.x - playhead_x
		
		draw_rect(Rect2(playhead_x, 0, 1, rect.size.y), playhead_color)
