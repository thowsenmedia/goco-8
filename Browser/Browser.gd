class_name Browser extends MarginContainer

onready var gocoNet = $GocoNet
onready var gameList:ItemList = $HBoxContainer/GameList
onready var gameInfo = $HBoxContainer/GameInfo

var num_games:int
var pages:int
var current_page:int = 1

# the games from the current game list
var games = []

func _ready():
	# ensure games dir exists
	var dir = Directory.new()
	if not dir.dir_exists("user://games"):
		dir.make_dir("user://games")
	
	gameList.connect("item_selected", self, "_game_selected")
	gameList.connect("item_activated", self, "_game_activated")
	gameInfo.hide()
	
	gocoNet.connect("info_received", self, "_info_received")
	gocoNet.connect("games_received", self, "_games_received")
	gocoNet.connect("bad_response", self, "_on_bad_response")
	gocoNet.connect("download_success", self, "_on_download_success")
	gocoNet.get_info()

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			ES.goto_scene("Editor.tscn")

func _on_bad_response(result, response_code, headers, body):
	print("oops. bad response!")
	print(body.get_string_from_utf8())

func _info_received(result):
	num_games = result.game_count
	pages = result.pages
	gocoNet.get_games(current_page)


func _games_received(result:Dictionary):
	_clear_games()
	
	if result.games is Dictionary:
		games = result.games.values()
		print(games)
		for game in games:
			gameList.add_item(game.title, null, true)


func _clear_games():
	for i in gameList.get_item_count():
		gameList.remove_item(i)


func _game_selected(game_id):
	var game = games[game_id]
	gameInfo.find_node("Title").text = game.title
	gameInfo.find_node("VersionValue").text = str(game.version)
	gameInfo.find_node("AuthorValue").text = str(game.author)
	
	gameInfo.show()


func _game_activated(game_id):
	var game = games[game_id]
	ES.echo("Downloading " + game.title + "...")
	gocoNet.download(game.title)


func _on_download_success(result):
	run_game(result.filename)


func run_game(filename:String):
	var file = "user://games/" + filename
	
	var f = File.new()
	if not f.file_exists(file):
		ES.error("No file named " + file + ".")
		return false
	
	ES.echo("Running " + file + "...")
	
	var packed_project = ES.packer.unpack(file)
	
	ES.goto_scene("res://Runner/Runner.tscn", {
		"packed_project": packed_project,
	})
