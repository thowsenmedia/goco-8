class_name SFXer extends Control

export(bool) var testing = false
export(Resource) var test_pattern

var project:Project

onready var timelineView = $VBoxContainer/Control/MainPanel/TimelineView
onready var SFXSlot = $VBoxContainer/TopBar/MenuBar/SFXSlotValue
onready var speedControl = $VBoxContainer/Control/OptionsPanel/HBoxContainer/SpeedLength/Speed/SpeedValue
onready var lengthControl = $VBoxContainer/Control/OptionsPanel/HBoxContainer/SpeedLength/Length/LengthValue
onready var waveButtons = $VBoxContainer/Control/OptionsPanel/HBoxContainer/Waves/WaveButtons

var waveButtonsGroup:ButtonGroup

var sfx_index:int = 0
var current_pattern:SFXPattern

var selected_wave:int = Note.WAVES.SINE

func _ready():
	speedControl.connect("value_changed", self, "_set_pattern_speed")
	lengthControl.connect("value_changed", self, "_set_pattern_length")
	
	var waveButtonsGroup = waveButtons.get_child(0).group
	waveButtonsGroup.connect("pressed", self, "_on_wave_button_pressed")
	
	if testing:
		open_pattern(test_pattern)
	else:
		var p = SFXPattern.new()
		open_pattern(p)


func _on_wave_button_pressed(button:Button):
	var wave_name = button.name.to_upper()
	selected_wave = Note.WAVES.keys().find(wave_name)
	timelineView.selected_wave = selected_wave


func _gui_input(event):
	if event is InputEventKey:
		var e = event as InputEventKey
		if e.scancode == KEY_SPACE:
			if not e.pressed:
				if timelineView.is_playing:
					timelineView.stop()
				else:
					timelineView.play()


func _set_pattern_speed(speed):
	current_pattern.speed = speed

func _set_pattern_length(length):
	current_pattern.length = length
	timelineView.update()

func _open_project(p):
	project = p

func _close_project(p):
	project = null

func open_pattern(pattern:SFXPattern):
	current_pattern = pattern
	timelineView.set_pattern(pattern)
	speedControl.value = pattern.speed
	lengthControl.value = pattern.length
