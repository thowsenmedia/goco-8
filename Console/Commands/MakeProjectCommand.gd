class_name MakeProjectCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() == 0:
		ES.echo("make command needs a project name!")
		return COMMAND_ERROR
	
	var dir = Directory.new()
	dir.open("user://")
	
	if not dir.dir_exists("projects"):
		var err = dir.make_dir("projects")
		if err != OK:
			ES.echo("Failed to make user://projects dir. Error:" + str(err))
			return COMMAND_ERROR
	
	var err = dir.make_dir("projects/" + args[0])
	if err != OK:
		ES.echo("Failed to make directory " + str(args[0]) + ". Err: " + str(err))
		return COMMAND_ERROR
	
	err = dir.open("user://projects/" + args[0])
	if err:
		ES.echo("Failed to open " + "projects/" + args[0] + ". Err: " + str(err))
	else:
		dir.make_dir("code")
		dir.make_dir("tilesets")
		dir.make_dir("sfx")
		dir.make_dir("music")
		dir.make_dir("memory")
	
	ES.echo("Project created in /projects/" + str(args[0]))
	
	return OK
