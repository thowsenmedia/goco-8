class_name GocoNet extends HTTPRequest

signal info_received(info)
signal games_received(games)

signal bad_response(result, response_code, headers, body)

signal login_failed(result, response_code, headers, body)
signal login_success(response_code, message)

signal upload_success(response_code, message)
signal upload_failed(result, response_code, headers, body)

signal download_success(response_code, message)
signal download_failed(result, response_code, headers, body)

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
	
	if is_connected("request_completed", self, "_game_downloaded"):
		disconnect("request_completed", self, "_game_downloaded")



func _prepare_query_string(data:Dictionary) -> String:
	var string = ""
	
	var i = 0
	for key in data.keys():
		string += key + "=" + str(data[key]).http_escape()
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


func upload(packed_project, game_data: String):
	_disconnect_all()
	connect("request_completed", self, "_upload_status")
	var game = {
		"username": credentials.username,
		"password": credentials.password,
		"title": packed_project.title,
		"version": packed_project.version,
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
	request(ADDRESS + "/games/info", PoolStringArray(), VERIFY_SSL)


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
	print("Getting games page " + str(page))
	connect("request_completed", self, "games_received")
	request(ADDRESS + "/games/" + str(page), PoolStringArray(), VERIFY_SSL)


func games_received(result, response_code, headers, body):
	if result != OK:
		print("failed, HTTPRequest Error: " + str(result))
		return
	
	if response_code == 200:
		var text = body.get_string_from_utf8()
		var data = JSON.parse(text)
		emit_signal("games_received", data.result)
		return
	
	emit_signal("bad_response", result, response_code, headers, body)


func download(file_name:String):
	file_name = file_name.replace(' ','_').to_lower()
	
	print("download " + file_name + "...")
	_disconnect_all()
	connect("request_completed", self, "_game_downloaded")
	var err = request(ADDRESS + "/download/" + file_name, PoolStringArray(), VERIFY_SSL)
	if err != OK:
		ES.error("HTTPRequest Error: " + str(err))


func _game_downloaded(result, response_code, headers, body):
	print("game downloaded, result = " + str(result))
	print("response_code = " + str(response_code))
	if response_code == 200:
		var text = body.get_string_from_utf8()
		var data = JSON.parse(text)
		
		if data.error:
			ES.error("Download failed. Invalid JSON response.")
			return
		
		if data.result.has("error"):
			ES.error("Download failed: " + str(data.result.error))
			return
		
		ES.echo("Saving game...")
		var err = _save_game(data.result)
		if err:
			ES.error("Failed to save game file. File error: " + str(err))
			return
		
		emit_signal("download_success", data.result)
		return
	
	emit_signal("bad_response", result, response_code, headers, body)


func _save_game(game:Dictionary) -> int:
	var filename = "user://games/" + game.filename
	var game_raw = Marshalls.base64_to_raw(game.data)
	
	var f = File.new()
	var err = f.open(filename, File.WRITE)
	
	if err:
		return err
	
	f.store_buffer(game_raw)
	f.close()
	return OK
