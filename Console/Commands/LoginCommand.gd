class_name LoginCommand extends ConsoleCommand

func run(args:Array = []):
	if args.size() < 2:
		ES.error("Login needs a username followed by a password.")
		return COMMAND_ERROR
	
	var username = args[0]
	var password = args[1]
	
	if not ES.console.gocoNet.is_connected("login_success", self, "_on_login_success"):
		ES.console.gocoNet.connect("login_success", self, "_on_login_success")
		
	if not ES.console.gocoNet.is_connected("login_failed", self, "_on_login_failed"):
		ES.console.gocoNet.connect("login_failed", self, "_on_login_failed")
	
	ES.console.gocoNet.login(username, password)
	
	return OK


func _on_login_success(status_code, message):
	ES.echo("Logged in.")


func _on_login_failed(result, response_code, headers, body):
	ES.error("Login failed")
	var text = body.get_string_from_utf8()
	var json = JSON.parse(text)
	if json.error:
		ES.error("Login failed. Json error: " + str(json.error))
		ES.error("response text: " + text)
	else:
		ES.error(json.result.error)
