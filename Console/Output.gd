extends RichTextLabel

func _ready():
	pass

func write(string: String):
	append_bbcode(string)

func clear():
	text = ""

func _gui_input(event):
	if event is InputEventKey:
		return
