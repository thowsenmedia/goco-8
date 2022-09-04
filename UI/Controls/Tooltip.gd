extends Label

var fade_timer:Timer

var is_fading_out:bool = false

func _ready():
	fade_timer = Timer.new()
	fade_timer.one_shot = true
	fade_timer.connect("timeout", self, "_fade_out")
	add_child(fade_timer)
	hide()
	
	# register tooltips
	var nodes = get_tree().get_nodes_in_group("tooltip")
	for node in nodes:
		register_tooltip_from_groups(node)
	
	# listen for newly added nodes
	get_tree().connect("node_added", self, "_on_tree_node_added")


func _on_tree_node_added(node:Node):
	if node.is_in_group("tooltip"):
		register_tooltip_from_groups(node)


func register_tooltip_from_groups(node:Node):
	for group in node.get_groups():
		if group.begins_with("tooltip="):
			var tooltip = group.trim_prefix("tooltip=")
			node.connect("mouse_entered", self, "show_tooltip", [tooltip])


func make_tooltip(node:Node, tooltip:String):
	node.connect("mouse_entered", self, "show_tooltip", [tooltip])


func show_tooltip(tooltip: String, time: float = 2.0):
	text = tooltip
	self_modulate.a = 1.0
	fade_timer.start(time)
	show()


func _fade_out():
	is_fading_out = true


func _process(delta):
	if is_fading_out:
		self_modulate.a = lerp(self_modulate.a, 0, delta)
		
		if self_modulate.a == 0:
			is_fading_out = false
