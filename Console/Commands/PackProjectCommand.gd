class_name PackProjectCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() == 0:
		ES.error("pack needs a valid project name!")
		return
	
	var project_name = args[0]
	
	var project = Project.new(project_name)
	
	project.load_data()
	
	var packed_project = ES.packer.pack(project)
	
	return OK
