class_name  extends ESNode

func _init():
	self.name = 

# literal=literal
func parse_1(parser):
	return (
		parser.expect(Lexer.TOKEN.LITERAL)
	)
