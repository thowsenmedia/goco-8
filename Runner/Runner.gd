class_name Runner extends Node2D

var project:Project

var log_messages := ""

# dictionary of ESNode2D-derived classes ready to instance
var scripts := {}

var paused:bool = false

func _ready():
	get_viewport().render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
	
	# load either a packed project, or a project
	
	if ES.scene_arguments.has("packed_project"):
		ES.echo("Running packed project...")
		project = ES.scene_arguments["packed_project"]
	elif ES.scene_arguments.has("project"):
		var project_name = ES.scene_arguments["project"]
		project = Project.new(project_name)
		project.load_data()
	
	# did we load a project?
	if project:
		var scripts = project.get_scripts()
		for script in scripts:
			var clazz = ResourceLoader.load(project.get_code_dir() + "/" + script, "", true)
			self.scripts[script] = clazz

		# autoload certain scripts
		if project.has_meta("autoload"):
			for script_name in project.get_meta("autoload"):
				print("autoloading " + script_name)
				add_child(script(script_name))
	else:
		ES.echo("Runner: no project or packed project is being loaded... there's nothing to do here!")


func script(script_name:String):
	var instance = scripts[script_name].new()
	
	if instance is Node:
		instance.add_to_group("script")
	
	if instance is ESNode2D:
		instance._project = project
		instance._runner = self
	
	return instance


func echo(what:String):
	print(what)
	log_messages += what + "\n"


func _process(delta):
	if not paused:
		for child in get_children():
			if child.is_in_group("script"):
				_tick_scripts(child, delta)


func _tick_scripts(node, delta):
	if not paused:
		node._tick(delta)
		node.update()
		for child in node.get_children():
			if child.is_in_group("script"):
				_tick_scripts(child, delta)


func _input(event):
	if event.is_action("escape") or event.is_action("start"):
		if event.pressed:
			paused = true
			$CanvasLayer/EscapeMenu.show()
			$CanvasLayer/EscapeMenu.grab_focus()


func quit():
	var args = {
		"launched_by_runner": true,
		"console_out": log_messages
	}
	
	if ES.scene_arguments.has("launched_by_editor"):
		if ES.scene_arguments["launched_by_editor"] == true:
			if project:
				args["open"] = project.name
	
	ES.goto_scene("res://Editor.tscn", args)


func resume():
	paused = false
	$CanvasLayer/EscapeMenu.hide()
