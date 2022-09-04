class_name AssignmentNode extends ESNode

var left
var right

func _init():
	self.name = "Assignment"

# literal=literal
func parse_1(parser):
	return (
		parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.ASSIGNMENT)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
	)

# literal=integer
func parse_2(parser):
	return (
		parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.ASSIGNMENT)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.INTEGER))


# literal="string"
func parse_3(parser):
	return (
		parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.IDENTIFIER)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.ASSIGNMENT)
		and parser.maybeSpaces()
		and parser.expect(Lexer.TOKEN.STRING))


func cleanup():
	remove_all_tokens_of_type(Lexer.TOKEN.WHITESPACE)
	left = str(children.pop_front())
	right = str(children.pop_back())


func compile(compiler):
	compiler.write(left + " = " + right)
	compiler.newline()
