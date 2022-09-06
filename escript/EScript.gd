class_name EScript extends Reference

var lexer:Lexer
var parser:Parser
var compiler:Compiler

func _init():
	lexer = Lexer.new()
	parser = Parser.new()
	compiler = Compiler.new()


func get_file_text(path:String):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err == OK:
		var text = f.get_as_text()
		f.close()
		return text
	
	return err


func compile(source:String):
	var tokens = lexer.tokenize(source)
	print(lexer.to_names(tokens))
	if tokens is Array:
		var root = parser.parse(tokens)
		parser.cleanup()
		if root is Object:
			return compiler.compile(root)
	
	ES.echo("Failed to compile ES source code")
	return false


func join(array:Array, separator:String):
	var s = ""
	var i = 0
	for segment in array:
		s += segment
		if i < array.size() - 1:
			s += separator
		i += 1
	return s

func compile_file(source_file:String, destination = null):
	var source = get_file_text(source_file)
	if not source is String:
		ES.echo("Failed to get source file at " + source_file + ". Error: " + str(source))
		return false
	
	var compiled = compile(source)
	
	if not compiled:
		ES.echo("Failed to compile " + source_file + ".", "red")
		
		for error in lexer.errors:
			ES.echo(error, "red")
		
		return false
	
	if destination == null:
		var file_name = Array(source_file.split("."))
		file_name.pop_back()
		destination = join(file_name, "/") + ".gd"
		destination = destination.replace("///", "//")
		print("destination:")
		print(destination)
		
	var f = File.new()
	var err = f.open(destination, File.WRITE)
	if err:
		ES.echo("Failed to save compiled gdscript to " + destination + ". Error: " + str(err))
		return false
	else:
		
		f.store_string(compiled)
		f.close()
		
		return destination
