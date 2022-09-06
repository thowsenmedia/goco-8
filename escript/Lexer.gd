class_name Lexer extends Reference

enum TOKEN {
	IDENTIFIER,
	WHITESPACE,
	INTEGER,
	FLOAT,
	PLUS,
	MINUS,
	MULTIPLY,
	DIVIDE,
	COLON,
	EQUALS,
	ASSIGNMENT,
	OPEN_PAREN,
	CLOSE_PAREN,
	KEYWORD,
	STRING,
}

const TOKEN_NAMES = [
	"IDENTIFIER",
	"WHITESPACE",
	"INTEGER",
	"FLOAT",
	"PLUS",
	"MINUS",
	"MULTIPLY",
	"DIVIDE",
	"COLON",
	"EQUALS",
	"ASSIGNMENT",
	"OPEN_PAREN",
	"CLOSE_PAREN",
	"KEYWORD",
	"STRING",
]

var patterns = {
	"^(function|func|for|while|if|true|false|and|or|break|continue|end)": TOKEN.KEYWORD,
	"^[a-zA-Z][a-zA-Z_]*(\\.[a-zA-Z_]+)*": TOKEN.IDENTIFIER,
	"^(\\t| )+": TOKEN.WHITESPACE,
	"^(0|([1-9][0-9]*))": TOKEN.INTEGER,
	"^([0-9]+\\.[0-9]+)|(\\.[0-9]+)": TOKEN.FLOAT,
	"^\\+": TOKEN.PLUS,
	"^-": TOKEN.MINUS,
	"^\\*": TOKEN.MULTIPLY,
	"^/": TOKEN.DIVIDE,
	"^:": TOKEN.COLON,
	"^==": TOKEN.EQUALS,
	"^=": TOKEN.ASSIGNMENT,
	"^\\(": TOKEN.OPEN_PAREN,
	"^\\)": TOKEN.CLOSE_PAREN,
	"^([\"'])((\\\\{2})*|(.*?[^\\\\](\\\\{2})*))\\1": TOKEN.STRING,
}

var source:String
var source_lines:Array

var tokens:Array = []

var line:int = 0
var pointer:int = 0

var errors := []

static func get_token_name(type:int):
	return TOKEN_NAMES[type]

func to_names(tokens:Array):
	var names = []
	for token in tokens:
		names.append(TOKEN_NAMES[token.type])
	return names

func tokenize(string:String):
	errors = []
	tokens = []
	source = string
	source_lines = Array(source.split("\n", true))
	pointer = 0
	
	while line < source_lines.size():
		pointer = 0
		while source_lines[line].substr(pointer).length() > 0:
			var token = get_next_token(source_lines[line].substr(pointer))
			if token:
				tokens.append(token)
			else:
				errors.append("Syntax error, unexpected character " + source_lines[line].substr(pointer) + " at line " + str(line) + ", position " + str(pointer) + ".")
				return null
		line += 1
	
	return tokens


func get_next_token(source:String):
	var pattern_tokens = patterns.values()
	var i = 0
	for pattern in patterns.keys():
		var token = pattern_tokens[i]
		var token_name = TOKEN_NAMES[token]
		
		var regex = RegEx.new()
		regex.compile(pattern)
		var m:RegExMatch = regex.search(source)

		if m:
			var value = m.strings[0]
			pointer += value.length()
			return Token.new(token, value)
		i += 1
	
	return null

func get_tokens() -> Array:
	return tokens
