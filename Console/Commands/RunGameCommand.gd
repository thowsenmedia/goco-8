class_name RunGameCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() < 1:
		ES.error("Please specify a game file to run (.g8 file)")
		return COMMAND_ERROR
	
	var file_name:String = args[0]
	if not file_name.ends_with(".g8"):
		file_name = file_name + ".g8"
	
	var file = ES.console.dir + "/" + file_name
	
	var f = File.new()
	if not f.file_exists(file):
		ES.error("No file named " + file_name + ".")
		return COMMAND_ERROR
	
	ES.echo("Running " + file + "...")
	
	var packed_project = ES.packer.unpack(file)
	
	ES.goto_scene("res://Runner/Runner.tscn", {
		"packed_project": packed_project,
	})
