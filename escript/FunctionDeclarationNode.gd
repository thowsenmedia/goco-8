class_name FunctionDeclarationNode extends ESNode

var function_name:String

func _init():
	self.name = "Function Declaration"

# func name():
func parse_1(parser):
	return (
		parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.KEYWORD, "func")
		and parser.expect(Lexer.TOKEN.WHITESPACE)
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.expect(Lexer.TOKEN.OPEN_PAREN)
		and parser.expect(Lexer.TOKEN.CLOSE_PAREN)
		and parser.expect(Lexer.TOKEN.COLON)
		and parser.expectAnyNodes()
		and parser.expect(Lexer.TOKEN.KEYWORD, "end")
	)


func cleanup():
	remove_all_tokens_of_type(Lexer.TOKEN.WHITESPACE)
	function_name = first_token(Lexer.TOKEN.IDENTIFIER).value


func compile(compiler:Compiler):
	compiler.write("func " + function_name + "():")
	compiler.indent()
	compiler.newline()
	for child in children:
		if child.has_method("compile"):
			child.compile(compiler)
	compiler.outdent()
