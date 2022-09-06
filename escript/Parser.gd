class_name Parser extends Reference

var ESNode = load("res://escript/ESNode.gd")

var nodeClasses := [
	preload("res://escript/AssignmentNode.gd"),
	preload("res://escript/DeclarationNode.gd"),
	preload("res://escript/FunctionDeclarationNode.gd")
]
var tokens:Array
var numTokens:int
var pointer:int

var rootNode
var currentNode

var indent_owner:ESNode
var indent_level:int = 0

var lastExpectation = {
	"class": null,
	"value": null,
	"node": null
}

func next():
	if pointer < tokens.size():
		var next = tokens[pointer]
		pointer += 1
		return next
	else:
		return null


func expect(type:int, value = null):
	lastExpectation = {
		"type": type,
		"value": value
	}
	
	var next = next()
	
	var matched := false
	
	if next and next.type == type:
		matched = true
		if value != null and next.value != value:
			matched = false
	
	if matched:
		print("added " + str(next))
		currentNode.add(next)
	
	return matched


func expectIndent():
	var save = pointer
	var checking := true
	var tabs_required = indent_level + 1
	var tabs_found = 0
	while tabs_found < tabs_required:
		if expect(Lexer.TOKEN.TAB):
			tabs_found += 1
		else:
			pointer = save
			return false
	
	indent_level += 1
	print("indent_level = " + str(indent_level))
	
	indent_owner = currentNode
	
	return true


func maybeSome(type:int, value = null):
	var save = pointer
	var checking := true
	while checking:
		if expect(type, value):
			save = pointer
		else:
			pointer = save
			checking = false
	
	return true


func maybeSpaces():
	return maybeSome(Lexer.TOKEN.WHITESPACE)


func parse(tokens:Array):
	self.tokens = tokens
	numTokens = tokens.size()
	rootNode = ESNode.new()
	rootNode.name = "Root"
	currentNode = rootNode
	pointer = 0
	
	while pointer < numTokens:
		var found = false
		for nodeClass in nodeClasses:
			if expectNode(nodeClass.new()):
				found = true
				break
		
		if not found:
			return null
	
	return currentNode


func expectAnyNodes():
	while true:
		var found = false
		for nodeClass in nodeClasses:
			if expectNode(nodeClass.new()):
				found = true
		
		if not found:
			return true
	
	return true


func expectNode(node):
	lastExpectation = {
		"node": node.name,
	}
	
	var owner = currentNode
	
	var prevNode = currentNode
	
	currentNode = node
	var save = pointer
	var success = false
	var i = 1
	while success == false and node.has_method("parse_" + str(i)):
		if not node.call("parse_" + str(i), self):
			success = false
			currentNode.backtrack(pointer - save)
			pointer = save
			i += 1
		else:
			success = true
			node.production = i
	
	if success:
		prevNode.add(node)
	else:
		print(str(owner.name) + " NOT satisfied by " + node.name)
	
	# restore
	currentNode = prevNode
	
	return success

func cleanup_node(node):
	if node.has_method("cleanup"):
		node.cleanup()
		for child in node.children:
			cleanup_node(child)

# run cleanup recursively on all nodes in the tree
func cleanup():
	cleanup_node(rootNode)
