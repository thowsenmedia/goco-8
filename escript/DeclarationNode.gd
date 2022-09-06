class_name DeclarationNode extends ESNode

var left
var right

func _init():
	self.name = "Declaration"

# var literal="string"
func parse_1(parser):
	return (
		parser.expect(Lexer.TOKEN.KEYWORD, "var")
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.ASSIGNMENT)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.STRING)
	)

# var literal=integer
func parse_2(parser):
	return (
		parser.expect(Lexer.TOKEN.KEYWORD, "var")
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.ASSIGNMENT)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.INTEGER)
	)

# var literal=float
func parse_3(parser):
	return (
		parser.expect(Lexer.TOKEN.KEYWORD, "var")
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.ASSIGNMENT)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.FLOAT)
	)

func cleanup():
	remove_all_tokens_of_type(Lexer.TOKEN.WHITESPACE)
	left = first_token(Lexer.TOKEN.IDENTIFIER)
	if production == 1:
		right = last_token(Lexer.TOKEN.STRING)
	elif production == 2:
		right = last_token(Lexer.TOKEN.INTEGER)
	elif production == 3:
		right = last_token(Lexer.TOKEN.FLOAT)

func compile(compiler):
	compiler.write("var " + left + " = " + right)
	compiler.newline()
