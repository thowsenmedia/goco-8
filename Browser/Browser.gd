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
	gameList.connect("item_selected", self, "_game_selected")
	gameInfo.hide()
	
	gocoNet.connect("info_received", self, "_info_received")
	gocoNet.connect("games_received", self, "_games_received")
	gocoNet.connect("bad_response", self, "_on_bad_response")
	gocoNet.get_info()

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			ES.goto_scene("Editor.tscn")

func _bad_response(result, response_code, headers, body):
	print("oops. bad response!")
	print(body.get_string_as_utf8())

func _info_received(result):
	num_games = result.game_count
	pages = result.pages
	gocoNet.get_games(current_page)


func _games_received(result):
	games = result.games
	print(games)
	_clear_games()
	for game in result.games:
		gameList.add_item(game.title, null, true)


func _clear_games():
	for i in gameList.get_item_count():
		gameList.remove_item(i)

func _game_selected(game_id):
	var game = games[game_id]
	gameInfo.find_node("Title").text = game.title
	gameInfo.find_node("VersionValue").text = str(game.version)
	
	gameInfo.show()
