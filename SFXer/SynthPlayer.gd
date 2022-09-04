class_name SynthPlayer extends AudioStreamPlayer

export(Resource) var pattern setget set_pattern, get_pattern

var _playback:AudioStreamGeneratorPlayback
export(float) var sample_rate:float = 11025
export(float) var buffer_length:float = 0.1

# the current audio frame
var playhead_frames:int = 0

# the frame in the pattern
var pattern_position_frames := 0

# the current note index
var pattern_note_index:int = -1

# the current note
var current_note:Note

# length of the notes (in frames)
var note_length:int

# length of the pattern (in frames)
var pattern_length:int

# attack time (in seconds)
var attack_time:float = 0.1
var decay_time:float = 0
var decay_value:float = 1
var release_time:float = 0.1

func _ready():
	stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = buffer_length
	_playback = get_stream_playback()
	
	if pattern:
		_init_pattern()


func set_pattern(p):
	if pattern:
		pattern.disconnect("length_changed", self, "_on_pattern_length_changed")
		pattern.disconnect("speed_changed", self, "_on_pattern_speed_changed")
	
	pattern = p
	_init_pattern()


func _init_pattern():
	note_length = seconds_to_frames(pattern.get_note_length())
	pattern_length = note_length * pattern.length
	
	if pattern:
		pattern.connect("length_changed", self, "_on_pattern_length_changed")
		pattern.connect("speed_changed", self, "_on_pattern_speed_changed")


func get_pattern() -> SFXPattern:
	return pattern

func _on_pattern_length_changed(length:int):
	pattern_length = note_length * pattern.length

func _on_pattern_speed_changed(speed:int):
	note_length = seconds_to_frames(pattern.get_note_length())
	pattern_length = note_length * pattern.length

func _process(delta):
	if playing:
		_fill_buffer()

func play(from:float = 0.0):
	if not pattern:
		return
	playhead_frames = 0
	pattern_position_frames = 0
	pattern_note_index = -1
	_playback.clear_buffer()
	.play(from)

# get the playhead position, in seconds.
# this is the current frame position / hertz
# for example, 22050 / 22055 = 1 second
func get_playhead_seconds() -> float:
	return frames_to_seconds(playhead_frames)


func frames_to_seconds(frames:int) -> float:
	return float(frames) / sample_rate


func seconds_to_frames(seconds:float) -> int:
	return int(seconds * sample_rate)


# get the next frame according to the current_frame
func get_next_frame() -> float:
	# the pattern_position, in frames:
	pattern_position_frames = playhead_frames % pattern_length
	
	# get the note index
	var index:int = pattern_position_frames / note_length
	
	if pattern_note_index != index:
		pattern_note_index = index
	
	var note = pattern.notes[pattern_note_index]
	
	if note != current_note:
		current_note = note
	
	playhead_frames += 1
	return current_note.frame()


func get_frame_volume() -> float:
	var note_position = pattern_position_frames % note_length
	
	var attack_length_frames:int = seconds_to_frames(attack_time)
	
	var decay_length_frames:int = seconds_to_frames(decay_time)
	
	var sustain_start:int = attack_length_frames + decay_length_frames
	
	var release_length_frames:int = seconds_to_frames(release_time)
	var release_start:int = note_length - release_length_frames
	
	# attack_time_frames = 10
	# note_length = 100 frames
	if note_position < attack_length_frames:
		# attack
		return lerp(0.0, 1.0, float(note_position) / attack_length_frames)
	elif note_position < sustain_start:
		# decay
		var decay_pos = note_position - attack_length_frames
		return lerp(1.0, decay_value, float(decay_pos) / decay_length_frames)
	elif note_position < release_start:
		return decay_value
	else:
		# release
		var release_pos = note_position - release_start
		return lerp(decay_value, 0.0, float(release_pos) / release_length_frames)


# fills the buffer for the next X available frames
func _fill_buffer():
	for frame_index in _playback.get_frames_available():
		var frame = get_next_frame()
		var volume = get_frame_volume()
		_playback.push_frame((Vector2.ONE * frame) * volume)
