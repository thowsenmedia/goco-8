class_name CatConsoleCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() == 0:
		ES.echo("Cat command expects 1 argument.")
		return COMMAND_ERROR
	var file:String = str(args[0])
	file = file.lstrip("/")
	file = (ES.console.dir + "/").replace("///", "//") + file
	var f = File.new()
	var err = f.open(file, File.READ)
	if err:
		ES.echo("Failed to open file at " + str(file) + ". Err: " + str(err))
		return COMMAND_ERROR
	else:
		var text = f.get_as_text()
		f.close()
		ES.echo("file at " + file, "gray")
		ES.echo(text)
	return OK
