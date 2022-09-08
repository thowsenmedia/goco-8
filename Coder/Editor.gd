class_name CodeEditor extends TextEdit

var file:String = ""
var dirty:bool = true

const COLORS = {
	"String": Color("99e550"),
	"Keyword": Color("fbf236"),
	"Constant": Color("d95763")
}

const KEYWORDS = [
	'var', 'func','return','void','break','continue',
	'class','class_name','extends',
	'if','elif','else','for','while','yield','enum'
]

const CONSTANTS = [
	"ESnode2D",
]

func _ready():
	add_color_region("\"", "\"", COLORS.String)
	
	for kw in KEYWORDS:
		add_keyword_color(kw, COLORS.Keyword)

func save():
	var f = File.new()
	var err = f.open(file, File.WRITE)
	if err == OK:
		f.store_string(text)
		f.close()
		dirty = false
	else:
		ES.echo("Failed to save " + file + ". Err: " + str(err))
