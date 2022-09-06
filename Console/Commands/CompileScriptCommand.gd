class_name CompileScriptCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() == 0:
		ES.echo("compile expects 1 argument.", "red")
		return
	
	var source = args[0]
	var file = ES.console.dir + "/" + source
	var f = File.new()
	if f.file_exists(file):
		
		var compiled_file = ES.escript.compile_file(file)
		if compiled_file:
			ES.console.write("Compiled to " + compiled_file)
			return OK
		else:
			ES.console.write("Failed to compile.")
			return COMMAND_ERROR
