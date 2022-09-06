class_name ConsoleCommand extends Reference

const COMMAND_OK = 0
const COMMAND_ERROR = 1

func write(text:String):
	ES.console.write(text)

func run(args:Array = []) -> int:
	return COMMAND_ERROR

func get_help() -> String:
	return "This command has no help."
