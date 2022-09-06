class_name PackProjectCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() == 0:
		ES.error("pack needs a valid project name!")
		return
	
	var project_name = args[0]
	
	var project = Project.new(project_name)
	project.load_data()
	
	if not project.title:
		if args.size() < 2:
			ES.error("Please supply a title, for example: pack my_game \"My Awesome Game\"")
			return COMMAND_ERROR
		
		var title:String = args[1]
		if title.length() < 3 or title.length() > 24:
			ES.error("Title must be between 3 and 64 characters long.")
			return COMMAND_ERROR
		
		# set title and save for future packing use
		project.title = title
		project.save_data()
	
	# pack it
	var packed_project = ES.packer.pack(project)
	
	return OK
