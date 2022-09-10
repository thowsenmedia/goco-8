extends RichTextLabel

func _ready():
	install_effect(RainbowTextEffect.new())

func write(string: String):
	append_bbcode(string)

func clear():
	text = ""

