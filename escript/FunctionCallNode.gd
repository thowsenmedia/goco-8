class_name FunctionCallNode extends ESNode

var function:Token

func _init():
	self.name = "FunctionCall"

# function_call()
func parse_1(parser):
	return (
		parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.expect(Lexer.TOKEN.OPEN_PAREN)
		and parser.expect(Lexer.TOKEN.CLOSE_PAREN)
	)

# function_call(with, "parameters")
func parse_2(parser):
	return (
		parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.expect(Lexer.TOKEN.OPEN_PAREN)
		and parser.expectAnyNodes()
		and parser.expect(Lexer.TOKEN.CLOSE_PAREN)
	)


func cleanup():
	remove_all_tokens_of_type(Lexer.TOKEN.WHITESPACE)
	if production == 1:
		function = first_token(Lexer.TOKEN.IDENTIFIER)
	elif production == 2:
		function = first_token(Lexer.TOKEN.IDENTIFIER)
		

func compile(compiler):
	compiler.write(function.value + "(")
	for child in children:
		if child.has_method("compile"):
			child.compile()
	compiler.write(")")
