class_name InstallDemosCommand extends ConsoleCommand

const DEMOS = [
	'breakout_demo'
]

func copy_dir_recursive(source_dir:String, target_dir:String):
	var dir := Directory.new()
	if dir.open(source_dir) == OK:
		# create this directory
		if not dir.dir_exists(target_dir):
			dir.make_dir(target_dir)
		
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				copy_dir_recursive(dir.get_current_dir() + "/" + file_name, target_dir + "/" + file_name)
			else:
				var err = dir.copy(dir.get_current_dir() + "/" + file_name, target_dir + "/" + file_name)
				if err:
					ES.error("Failed to copy " + file_name + ". Err: " + str(err))
			file_name = dir.get_next()




func run(args:Array = []):
	write("\nInstalling demos projects into /projects...")
	
	for demo_dir in DEMOS:
		var source_path = "res://demos/" + demo_dir
		var dest_path = "user://projects/" + demo_dir
		copy_dir_recursive(source_path, dest_path)
		write("\nInstalled " + demo_dir)
	
	write("\nDemos have been installed into your projects directory. Do 'cd projects' and 'ls' to take a look!\nTry 'open breakout_demo'!")
	
	return OK
