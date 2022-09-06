class_name CodeEditor extends TextEdit

var file:String = ""
var dirty:bool = true

func save():
	var f = File.new()
	var err = f.open(file, File.WRITE)
	if err == OK:
		f.store_string(text)
		f.close()
		dirty = false
	else:
		ES.echo("Failed to save " + file + ". Err: " + str(err))
