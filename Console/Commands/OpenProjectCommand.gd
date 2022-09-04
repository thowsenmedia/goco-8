class_name OpenProjectCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() == 0:
		ES.echo("open expects a dir name.")
		return COMMAND_ERROR
	
	var project = str(args[0])
	
	if ES.project_folder_exists(project):
		if ES.open_project(project):
			return OK
	else:
		ES.echo("No project named " + project)
	
	return COMMAND_ERROR
