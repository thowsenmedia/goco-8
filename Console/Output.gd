extends ScrollContainer

var line:RichTextLabel

var is_asking:bool = false

func _ready():
	get_node("_v_scroll").hide()
	$ScrollDelay.connect("timeout", self, "_scroll_timeout")
	$_v_scroll.self_modulate = Color(0, 0, 0, 0)

func write(string: String):
	if line:
		line.percent_visible = 1
	
	line = RichTextLabel.new()
	line.bbcode_enabled = true
	line.fit_content_height = true
	line.append_bbcode(string)
	line.percent_visible = 1
	line.scroll_active = false
	line.scroll_following = true
	
	$lines.add_child(line)
	$ScrollDelay.start()


func _scroll_timeout():
	ensure_control_visible($lines.get_child($lines.get_child_count() - 1))


func clear():
	for child in $lines.get_children():
		$lines.remove_child(child)

func _process(delta):
	return
	if line and line.percent_visible <= 1:
		line.percent_visible += 1.0 / 50
		if line.percent_visible > 1:
			line.percent_visible = 1
