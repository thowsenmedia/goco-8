class_name BrowseCommand extends ConsoleCommand

func run(args:Array = []):
	ES.goto_scene("Browser/Browser.tscn")
	return OK
