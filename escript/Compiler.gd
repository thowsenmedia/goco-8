# this class takes a parse tree from the parser
# and generates gdscript code for the Epikus runtime
class_name Compiler extends Reference

var ESNode = load("res://escript/ESNode.gd")

var root

var gdscript:String

var indent_level:int = 0

func write(code:String):
	gdscript += code

func indent():
	indent_level += 1

func outdent():
	indent_level -= 1

func newline():
	write("\n" + "	".repeat(indent_level))

func compile(root):
	indent_level = 0
	gdscript = "extends ESNode2D\n\n"
	root.compile(self)
	return gdscript
