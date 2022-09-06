class_name SFXPattern extends Resource

signal length_changed(length)
signal speed_changed(speed)

export(int, 4, 32, 1) var length = 8 setget set_length, get_length
export(Array, Resource) var notes := []

# 1 = 1 note per second
export(int, 1, 32) var speed = 1 setget set_speed, get_speed


func _init():
	set_length(length)


func get_note_length() -> float:
	return 1.0 / speed


func set_length(l:int):
	length = l
	notes.resize(length)
	for i in length:
		if notes[i] == null:
			notes[i] = Note.new()
	
	emit_signal("length_changed", l)


func get_length() -> int:
	return length

func set_speed(s:int):
	speed = s
	emit_signal("speed_changed", s)

func get_speed() -> int:
	return speed

func get_length_seconds() -> float:
	return get_note_length() * length
