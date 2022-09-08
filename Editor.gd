extends HBoxContainer

var escript
var console
var coder
var spriter
var mapper
var sfxer
var musicer

var windows = []

var current_window_number:int = 0
var target_offset = 0
var is_sliding = false

var project:Project

func _init():
	escript = EScript.new()
	console = load("res://Console/Console.tscn").instance()
	coder = load("res://Coder/Coder.tscn").instance()
	spriter = load("res://Spriter/Spriter.tscn").instance()
	mapper = load("res://Mapper/Mapper.tscn").instance()
	sfxer = load("res://SFXer/SFXer.tscn").instance()
	ES.editor = self


func _ready():
	add_window("Console", console)
	add_window("Coder", coder)
	add_window("Spriter", spriter)
	add_window("Mapper", mapper)
	add_window("SFXer", sfxer)
	
	get_viewport().render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS
	
	if ES.scene_arguments.has("launched_by_runner"):
		ES.push_log_to_console()
		ES.clear_log_file()
	
	if ES.scene_arguments.has("open"):
		open_project(ES.scene_arguments.open)
	
	get_window().grab_focus()


func _input(event: InputEvent):
	if event.is_action("save") and event.pressed:
		save_project()
	elif event.is_action("run") and event.pressed:
		run_project()


func close_project():
	# just reload the scene - simple :)
	ES.goto_scene("res://Editor.tscn")
#
#	for window_name in windows:
#			var window = get_node(window_name)
#			if window.has_method("_close_project"):
#				window._close_project()


func open_project(name:String):
	if project:
		close_project()
	
	project = Project.new(name)
	project.load_data()
	
	for window_name in windows:
		var window = get_node(window_name)
		if window.has_method("_open_project"):
			window._open_project(project)
	
	if project.has_meta("editor_window"):
		go_to_window(project.get_meta("editor_window"))
	
	ES.echo("Project '" + project.name + "' opened.")


func save_project():
	if project:
		print("saving project...")
		for window_name in windows:
			var window = get_node(window_name)
			if window.has_method("_before_save_project"):
				window._before_save_project(project)
		
		project.save_data()
		
		for window_name in windows:
			var window = get_node(window_name)
			if window.has_method("_save_project"):
				window._save_project(project)
		
		notify("Project saved.")


func notify(text, time:float = 3):
	$CanvasLayer/Notification.notify(text, time)


func run_project():
	if project:
		print("running project...")
		
		save_project()
		ES.echo("Running project...")
		ES.goto_scene("res://Runner/Runner.tscn", {
			"project": project.name,
			"launched_by_editor": true
		})


func echo(message:String):
	print(message)
	console.write(message)


func add_window(name, control):
	windows.append(name)
	control.rect_min_size = Vector2(320, 240)
	control.name = name
	add_child(control)


func get_window() -> Node:
	return get_node(windows[current_window_number])


func go_to_window(name:String):
	var window = get_window()
	window.release_focus()
	
	var num = windows.find(name)
	current_window_number = num
	target_offset = -320 * num
	is_sliding = true
	get_window().grab_focus()
	project.put_meta("editor_window", name)


func next_window():
	var next = current_window_number + 1
	if next > windows.size() - 1:
		next = 0
	
	var name = windows[next]
	go_to_window(name)


func prev_window():
	var prev = current_window_number - 1
	if prev < 0:
		prev = windows.size() - 1
	
	var name = windows[prev]
	go_to_window(name)


func _process(delta):
	if project:
		if Input.is_action_just_released("window_next"):
			next_window()
		elif Input.is_action_just_released("window_previous"):
			prev_window()
		
	if rect_position.x != target_offset:
		rect_position.x = lerp(rect_position.x, target_offset, 0.1)
	else:
		if is_sliding:
			get_window().grab_focus()
			get_window().grab_click_focus()
			is_sliding = false
