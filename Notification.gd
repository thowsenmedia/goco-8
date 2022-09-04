extends Control

onready var label = $HBoxContainer/Label
onready var anim = $AnimationPlayer

func _ready():
	$Timer.connect("timeout", self, "_on_timeout")


func notify(text, time:float = 2):
	if anim.is_playing():
		anim.stop()
	
	label.text = text
	$Timer.wait_time = time
	$Timer.start()
	anim.play("show")


func _on_timeout():
	anim.play_backwards("show")
