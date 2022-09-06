class_name ClearScreenCommand extends ConsoleCommand

func run(args: Array = []):
	ES.console.output.clear()
	return OK
