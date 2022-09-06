class_name HelpPanel extends MarginContainer

var is_visible:bool = false


func show():
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	
	$AnimationPlayer.play("show")
	is_visible = true


func hide():
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	
	$AnimationPlayer.play_backwards("show")
	is_visible = false


func toggle():
	if is_visible:
		hide()
	else:
		show()
