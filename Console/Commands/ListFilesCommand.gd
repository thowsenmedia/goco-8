class_name ListFilesCommand extends ConsoleCommand

func run(args:Array = []):
	write("Showing files in " + ES.console.dir)
	
	var dir = Directory.new()
	if dir.open(ES.console.dir) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				write("[color=yellow]/" + file_name + "[/color]")
			else:
				write(file_name)
			file_name = dir.get_next()
	else:
		ES.print("An error occurred when trying to access the path.")
		return COMMAND_ERROR
	return OK
