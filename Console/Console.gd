class_name Console extends PanelContainer

const ARGUMENT_PATTERN = '("(?:[^"\\\\]|\\\\.)*")|(\'(?:[^\'\\\\]|\\\\.)*\')|([^ ]+)'

var has_focus := false

var argument_regex = RegEx.new()

onready var scroll = $ScrollContainer
onready var output = $ScrollContainer/VBoxContainer/Output
onready var input = $ScrollContainer/VBoxContainer/Input/LineEdit
onready var inputPrefix = $ScrollContainer/VBoxContainer/Input/InputPrefix
onready var gocoNet = $GocoNet

var commands := {}
var welcome_message = """[center]
[color=purple]|    G O C O - 8    |[/color]

[color=gray]Copyright (c) 2022 - Thowsen Media
Version: 0.9.0[/color]
[color=teal]goco8.thowsenmedia.com[/color]
[color=gray]--------------------------------------------------[/color]
[/center]

Type [color=yellow]help[/color] for a list of commands, or [color=yellow]quickstart[/color] for a quick introduction.
Type [color=yellow]browse[/color] to browse games. To upload games, register for an account at [color=teal]goco8.thowsenmedia.com[/color],
then you can 'login [username] [password]', and 'upload [your_game]' (first you need to 'pack [the_game]')."""

var dir:String = "user://"

var shouldScroll := false
var scrollTimer := 0.0

func _init():
	ES.console = self
	argument_regex.compile(ARGUMENT_PATTERN)
	

func _ready():
	add_command("help", HelpCommand.new())
	add_command("quickstart", QuickStartCommand.new())
	add_command("install_demos", InstallDemosCommand.new())
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
	
	write(welcome_message)
	
	if not ES.editor:
		has_focus = true
	
	if has_focus:
		input.grab_focus()
	

func add_command(command_name: String, command:ConsoleCommand):
	commands[command_name] = command

func grab_focus():
	input.grab_focus()
	has_focus = true

func release_focus():
	.release_focus()
	has_focus = false

func write(text:String):
	output.write(text)
	shouldScroll = true
	scrollTimer = 0.0

func _input(event):
	if not has_focus:
		return
	
	var handled = false
	
	if event.is_action("ui_up") and event.pressed:
		scroll.scroll_vertical -= 14
		handled = true
		print("scrolling")
	elif event.is_action("ui_down") and event.pressed:
		scroll.scroll_vertical += 14
		handled = true
	elif event.is_action("ui_accept") and event.pressed:
		var command = input.text
		if command:
			input.text = ""
			process_command(command)
		handled = true
	
	if handled:
		get_tree().set_input_as_handled()

func _process(delta):
	if shouldScroll:
		scrollTimer += delta
		if scrollTimer >= 0.01:
			scroll.ensure_control_visible(input)
			shouldScroll = false

func run(command:String, args:Array):
	if commands.has(command):
		return commands[command].run(args)
	
	push_warning("Unknown command " + command)
	return null

func process_command(text:String):
	output.write("\n[color=yellow]->[/color] " + text + "\n")
	var split = Array(text.split(" ", false, 1))
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
	
	shouldScroll = true
	scrollTimer = 0


func _on_input_text_changed(new_text):
	scroll.ensure_control_visible(input)
