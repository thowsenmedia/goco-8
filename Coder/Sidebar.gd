extends VBoxContainer

var is_visible:bool = false

func show():
	$AnimationPlayer.play("show")
	is_visible = true
	$Tree.grab_focus()
	if $Tree.get_child_count() > 1:
		$Tree.get_child(1).grab_focus()

func hide():
	$AnimationPlayer.play_backwards("show")
	is_visible = false
