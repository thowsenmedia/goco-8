extends Node

const VERSION := "0.5.1"

enum COLORS {
	
}

var scene_arguments := {}
var current_scene = null

var console
var editor
var escript = EScript.new()
var packer:Packer = Packer.new()

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func project_folder_exists(project:String):
	var dir = Directory.new()
	return dir.dir_exists("user://projects/" + project)

func open_project(project:String):
	editor.open_project(project)
	return true


func echo(what:String, color:String = "white"):
	print(what)
	
	if is_instance_valid(console):
		if color != "white":
			what = "[color=" + color + "]" + what + "[/color]"
		console.write(what)


func error(message:String):
	echo("Error: " + message, "red")
	if is_instance_valid(editor):
		editor.notify("ERROR: " + message)


func push_log_to_console():
	var f = File.new()
	var logfile = "user://logs/godot.log"
	if f.file_exists(logfile):
		var err = f.open(logfile, File.READ)
		if err:
			error("Failed to open logfile at " + str(logfile) + ". Err: " + str(err))
		else:
			var messages:String = f.get_as_text()
			var regex = RegEx.new()
			
			# remove warnings
			regex.compile("\nWARNING: .+")
			var matches:Array = regex.search_all(messages)
			for m in matches:
				for string in m.strings:
					messages = messages.replace(string, "")
			
			# colorize errors
			regex.compile("\nSCRIPT ERROR: .+")
			matches = regex.search_all(messages)
			for m in matches:
				for string in m.strings:
					messages = messages.replace(string, "[color=red]" + string + "[/color]")
			
			echo(messages)
			
			if editor and matches.size() > 0:
				var errors = matches.size()
				error(str(errors) + " Errors occured.")
			
			f.close()


func clear_log_file():
	var file = "user://logs/godot.log"
	var f = File.new()
	var err = f.open(file, File.WRITE)
	if err:
		error("Failed to clear log file. Err: " + str(err))
	else:
		f.close()


func goto_scene(path, arguments := {}):
	scene_arguments = arguments.duplicate(true)
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().current_scene = current_scene


#-----------------------#
#  UTILS
#-----------------------#
func join(array:Array, separator:String = ""):
	var string = ""
	var i = 0
	for element in array:
		string += element
		if i < array.size() - 1:
			string += separator
		i += 1
	return string
