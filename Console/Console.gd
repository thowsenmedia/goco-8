class_name Console extends PanelContainer

const ARGUMENT_PATTERN = '("(?:[^"\\\\]|\\\\.)*")|(\'(?:[^\'\\\\]|\\\\.)*\')|([^ ]+)'

var argument_regex = RegEx.new()

onready var output = $VBoxContainer/Output
onready var input = $VBoxContainer/HBoxContainer/Input
onready var gocoNet = $GocoNet

var commands := {}
var welcome_message = """[center]
[color=purple]/    G O C O - 8    \\[/color]

[color=gray]Copyright (c) 2022 - Thowsen Media
Version: 0.5.1[/color]
[color=gray]--------------------------------------------------[/color]
[/center]

Type [color=yellow]help[/color] for a list of commands, or [color=yellow]quickstart[/color] for a quick introduction.

Type [color=yellow]browse[/color] to browse games. To upload games, register for an account at [color=teal]goco8.thowsenmedia.com[/color],
then you can 'login [username] [password]', and 'upload [your_game]' (first you need to 'pack [the_game]').

Website: [color=teal]goco8.thowsenmedia.com[/color].
Source: [color=teal]github.com/thowsenmedia/goco-8[/color].
"""

var dir:String = "user://"

func _init():
	ES.console = self
	argument_regex.compile(ARGUMENT_PATTERN)
	

func _ready():
	add_command("help", HelpCommand.new())
	add_command("quickstart", QuickStartCommand.new())
	add_command("cd", ChangeDirCommand.new())
	add_command("ls", ListFilesCommand.new())
	add_command("cls", ClearScreenCommand.new())
	add_command("mkdir", MakeDirCommand.new())
	add_command("cat", CatConsoleCommand.new())
	add_command("make", MakeProjectCommand.new())
	add_command("open", OpenProjectCommand.new())
	add_command("close", CloseProjectCommand.new())
	add_command("pack", PackProjectCommand.new())
	add_command("run", RunGameCommand.new())
	add_command("browse", BrowseCommand.new())
	add_command("login", LoginCommand.new())
	add_command("upload", UploadCommand.new())
	
	output.write(welcome_message)
	input.grab_focus()

func grab_focus():
	input.grab_focus()

func add_command(command_name: String, command:ConsoleCommand):
	commands[command_name] = command


func write(text:String):
	output.write(text)


func _process(delta):
	if Input.is_action_pressed("ui_up"):
		output.scroll_vertical -= 1
	elif Input.is_action_pressed("ui_down"):
		output.scroll_vertical += 1
	
	if Input.is_action_just_released("ui_accept"):
		var command = input.text
		if command:
			input.text = ""
			process_command(command)

func run(command:String, args:Array):
	if commands.has(command):
		return commands[command].run(args)
	
	push_warning("Unknown command " + command)
	return null

func process_command(string:String):
	output.write("->" + string)
	var split = Array(string.split(" ", false, 1))
	var command = split.pop_front()
	
	var args = []
	if split.size() > 0:
		var matches:Array = argument_regex.search_all(split.pop_front())

		for m in matches:
			var argument:String = m.strings[0]
			argument = argument.trim_prefix('"').trim_prefix("'").trim_suffix('"').trim_suffix("'")
			args.append(argument)
	
	if commands.has(command):
		var err = run(command, args)
		if err:
			output.write("[color=red]Command failed.[/color]")
	else:
		output.write("[color=red]Unknown command '" + command + "'...[/color]")
