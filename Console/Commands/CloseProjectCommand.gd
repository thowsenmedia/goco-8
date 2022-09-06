class_name CloseProjectCommand extends ConsoleCommand

func run(args:Array = []):
	if ES.editor and ES.editor.project:
		var name = ES.editor.project.name
		ES.editor.close_project()
		ES.echo("Closed '" + name + "'.")
	else:
		ES.echo("No project is currently open.")
	return OK
