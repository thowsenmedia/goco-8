class_name Packer extends Reference

var games_dir_checked:bool = false

func _check_games_dir():
	var dir = Directory.new()
	var err = dir.open("user://")
	if err:
		ES.error("Cannot open user://. Err: " + str(err))
		return
	
	if not dir.dir_exists("games"):
		err = dir.make_dir("games")
		if err:
			ES.error("Failed to create user://games directory. Err: " + str(err))
		else:
			ES.echo("Created user://games directory.")
	games_dir_checked = true


# pack a project
func pack(project:Project):
	if not games_dir_checked:
		_check_games_dir()
	
	var project_directory
	
	var packed_project = project.pack()
	
	var file = "user://projects/" + project.name + "/" + project.name + ".g8"
	
	var f = File.new()
	var err = f.open(file, File.WRITE)
	if err:
		ES.error("Failed to open " + file + ". Err: " + str(err))
	else:
		f.store_var(packed_project, true)
		f.close()
		ES.echo("Project packed to " + file + ".")


func unpack(game_file: String):
	var f = File.new()
	
	if not f.file_exists(game_file):
		ES.error("Game file not found: " + game_file)
		return
	
	var err = f.open(game_file, File.READ)
	if err:
		ES.error("Failed to open game_file at " + str(game_file) + ". Err: " + str(err))
		return
	
	var packed_project = f.get_var(true)
	
	f.close()
	return packed_project
