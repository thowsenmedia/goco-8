class_name MakeDirCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() == 0:
		ES.echo("mkdir needs a folder name!")
		return ERR_PARAMETER_RANGE_ERROR
	
	var name = args[0]
	var dir = Directory.new()
	dir.change_dir(ES.console.dir)
	var err = dir.make_dir(name)
	if err != OK:
		ES.echo(err)
		return err
	else:
		return OK
