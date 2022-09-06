class_name HelpCommand extends ConsoleCommand

func run(args:Array = []) -> int:
	write("Here are the available commands:")
	var names = ES.console.commands.keys()
	var msg = "| "
	for name in names:
		msg += name + " | "
	
	write(msg)
	
	write("For help about a given command, type 'help [command]'")
	
	return OK
