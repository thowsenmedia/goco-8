class_name GocoNet extends HTTPRequest

signal info_received(info)
signal games_received(games)
signal bad_response(result, response_code, headers, body)
signal login_failed(result, response_code, headers, body)
signal login_success(response_code, message)
signal upload_success(response_code, message)
signal upload_failed(result, response_code, headers, body)

const ADDRESS := "http://goco-8.local/api"
const VERIFY_SSL := false

var logged_in := false
var credentials := {
	"username": null,
	"password": null
}

func _ready():
	pass

func _disconnect_all():
	if is_connected("request_completed", self, "info_received"):
		disconnect("request_completed", self, "info_received")
	
	if is_connected("request_completed", self, "games_received"):
		disconnect("request_completed", self, "games_received")
	
	if is_connected("request_completed", self, "_login_status"):
		disconnect("request_completed", self, "_login_status")
	
	if is_connected("request_completed", self, "_upload_status"):
		disconnect("request_completed", self, "_upload_status")



func _prepare_query_string(data:Dictionary) -> String:
	var string = ""
	
	var i = 0
	for key in data.keys():
		string += key + "=" + data[key]
		if i < data.size() - 1:
			string += "&"
		i+= 1
	
	return string


func login(username: String, password: String):
	_disconnect_all()
	connect("request_completed", self, "_login_status")
	credentials = {
		"username": username,
		"password": password
	}
	var query = _prepare_query_string(credentials)
	var err = request(ADDRESS + "/login", ['Content-Type: application/x-www-form-urlencoded'], VERIFY_SSL, HTTPClient.METHOD_POST, query)



func _login_status(result, response_code, headers, body):
	if result != OK:
		print("result = " + str(result))
		print("response code = " + str(response_code))
		print("headers " + str(headers))
		print("body " + body.get_string_from_utf8())
		ES.error("Failed to connect, HTTPRequest error: " + str(result))
		return

	var data = JSON.parse(body.get_string_from_utf8())
	if response_code == 200:
		logged_in = true
		emit_signal("login_success", response_code, data.result)
	else:
		logged_in = false
		emit_signal("login_failed", result, response_code, headers, body)


func upload(title: String, game_data: String):
	_disconnect_all()
	connect("request_completed", self, "_upload_status")
	var game = {
		"username": credentials.username,
		"password": credentials.password,
		"title": title,
		"data": game_data
	}
	var query = _prepare_query_string(game)
	
	var err = request(ADDRESS + "/upload", ['Content-Type: application/x-www-form-urlencoded'], VERIFY_SSL, HTTPClient.METHOD_POST, query)
	
	if err:
		ES.error("HTTPRequest error: " + str(err))
	else:
		ES.echo("Uploading...")


func _upload_status(result, response_code, headers, body):
	print("result = " + str(result))
	print("response_code = " + str(response_code))
	print("headers = " + str(headers))
	print("body = " + body.get_string_from_utf8())


func get_info():
	_disconnect_all()
	connect("request_completed", self, "info_received")
	request(ADDRESS + "/games", PoolStringArray(), VERIFY_SSL)


func info_received(result, response_code, headers, body):
	if response_code == 200:
		var text = body.get_string_from_utf8()
		var data = JSON.parse(text)
		
		if data.error == OK:
			emit_signal("info_received", data.result)
			return
	
	emit_signal("bad_response", result, response_code, headers, body)


func get_games(page:int):
	_disconnect_all()
	connect("request_completed", self, "games_received")
	request(ADDRESS + "/games/" + str(page), PoolStringArray(), VERIFY_SSL)


func games_received(result, response_code, headers, body):
	if response_code == 200:
		var text = body.get_string_from_utf8()
		var data = JSON.parse(text)
		if data.error == OK:
			emit_signal("games_received", data.result)
			return
	
	emit_signal("bad_response", result, response_code, headers, body)


func download_game(url:String):
	_disconnect_all()
	connect("request_completed", self, "_game_downloaded")
	request(url, PoolStringArray(), VERIFY_SSL)


func _game_downloaded(result, response_code, headers, body):
	if response_code == 200:
		var f = File.new()
		f.open()
	
	emit_signal("bad_response", result, response_code, headers, body)
