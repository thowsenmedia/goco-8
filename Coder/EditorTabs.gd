extends TabContainer

func grab_focus():
	if get_child_count() > 0:
		get_child(current_tab).grab_focus()

func clear():
	return
	for child in get_children():
		remove_child(child)
		child.queue_free()
