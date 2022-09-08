class_name ListFilesCommand extends ConsoleCommand

func run(args:Array = []):
	var dir = Directory.new()
	
	if dir.open(ES.console.dir) == OK:
		var list = ""
		
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				list += "[color=yellow]/" + file_name + "[/color]\n"
			else:
				list += file_name + "\n"
			file_name = dir.get_next()
		
		write(list.trim_suffix("\n"))
	else:
		ES.echo("An error occurred when trying to access the path.")
		return COMMAND_ERROR
	return OK
