class_name UnpackProjectCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() < 1:
		ES.error("unpack needs a project name.")
		return COMMAND_ERROR
	
	var file:String = args[0]
	if not file.ends_with(".g8"):
		file = file + ".g8"
	
	var path = ES.console.dir + "/" + file
	
	ES.echo("Unpacking " + path + "...")
	
	var f = File.new()
	var err = f.open(path, File.READ)
	if err:
		ES.error("Failed to open " + path + ". Err: " + str(err))
		return COMMAND_ERROR
	
	var packed_project = f.get_var(true)
	ES.echo("Project unpacked:")
	
	f.close()
	
	return OK
