class_name ChangeDirCommand extends ConsoleCommand

func run(args:Array = []):
	# cd to "root" dir?
	if args.size() == 0:
		ES.console.dir = "user://"
		ES.console.write("/")
		return
	
	var to_dir = args[0]
	
	var dir = Directory.new()
	dir.open(ES.console.dir)
	dir.change_dir(to_dir)
	var new_dir = dir.get_current_dir()
	ES.console.write(new_dir.trim_prefix("user:/"))
	ES.console.dir = new_dir
	return OK
