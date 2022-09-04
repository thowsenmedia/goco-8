class_name ChangeDirCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() == 0:
		ES.console.dir = "user://"
		ES.echo("/")
		return
	var to_dir = args[0]
	
	var dir = Directory.new()
	dir.open(ES.console.dir)
	dir.change_dir(to_dir)
	var new_dir = dir.get_current_dir()
	ES.echo(new_dir)
	ES.console.dir = new_dir
	return OK
